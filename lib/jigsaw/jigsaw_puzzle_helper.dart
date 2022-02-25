
import 'dart:math';

import 'package:very_good_slide_puzzle/jigsaw/jigsaw_tile.dart';
import 'package:very_good_slide_puzzle/models/models.dart';
import 'package:very_good_slide_puzzle/theme/theme.dart';

class JigSawPuzzleHelper extends SimplePuzzleHelper {
  const JigSawPuzzleHelper();
  final Random? yaRandom = null;

  @override
  Puzzle generate(int size, {bool shuffle = true, Random? random}) {
    return _generatePuzzle(size, shuffle: shuffle, random: random);
  }

  @override
  Puzzle shuffle(Puzzle puzzle, Random? random) {
    final positions = TilePositions(puzzle.size);
    final correctPositions = positions.correctPositions;
    final currentPositions = positions.currentPositions;

    Puzzle puzzle2;

    puzzle.tiles.sort((a, b) => a.value.compareTo(b.value));
    final edges = puzzle.tiles.map((e) => (e as JigSawTile).edges).toList();

    currentPositions.shuffle(random);

    var tiles = _getTileListFromPositions(
        puzzle.size,
        correctPositions,
        currentPositions,
        edges,
    );

    puzzle2 = puzzle.copyWithTiles(tiles);

    while (!puzzle2.isSolvable() || puzzle2.getNumberOfCorrectTiles() != 0) {
      currentPositions.shuffle(random);
      tiles = _getTileListFromPositions(
          puzzle2.size,
          correctPositions,
          currentPositions,
          edges,
      );
      puzzle2 = puzzle2.copyWithTiles(tiles);
    }

    return puzzle2;
  }

  @override
  int getNumberOfCorrectTiles(List<Tile> tiles) {
    final whitespaceTile = getWhitespaceTile(tiles);
    var numberOfCorrectTiles = 0;
    for (final tile in tiles) {
      if (tile != whitespaceTile) {
        if (tile.currentPosition == tile.correctPosition) {
          numberOfCorrectTiles++;
        }
      }
    }
    return numberOfCorrectTiles;
  }

  @override
  bool isComplete(List<Tile> tiles) {
    return (tiles.length - 1) - getNumberOfCorrectTiles(tiles) == 0;
  }

  List<Tile> bringTileToFront(List<Tile> tiles, Tile tile) {
    final i = tiles.indexWhere((element) => element == tile);
    tiles
      ..removeAt(i)
      ..insert(0, tile);
    return tiles;
  }

  /// Build a randomized, solvable puzzle of the given size.
  Puzzle _generatePuzzle(int size, {bool shuffle = true, Random? random}) {
    final positions = TilePositions(size);
    final correctPositions = positions.correctPositions;
    final currentPositions = positions.currentPositions;

    final edges = _getEdges(size);

    if (shuffle) {
      // Randomize only the current tile positions.
      currentPositions.shuffle(random);
    }

    var tiles = _getTileListFromPositions(
        size,
        correctPositions,
        currentPositions,
        edges
    );

    var puzzle = Puzzle(tiles: tiles, size: size, helper: this);

    if (shuffle) {
      // Assign the tiles new current positions until the puzzle is solvable and
      // zero tiles are in their correct position.
      while (!puzzle.isSolvable() || puzzle.getNumberOfCorrectTiles() != 0) {
        currentPositions.shuffle(random);
        tiles = _getTileListFromPositions(
            size,
            correctPositions,
            currentPositions,
            edges,
        );
        puzzle = puzzle.copyWithTiles(tiles);
      }
    }

    return puzzle;
  }

  /// Build a list of tiles - giving each tile their correct position and a
  /// current position.
  List<JigSawTile> _getTileListFromPositions(
      int size,
      List<Position> correctPositions,
      List<Position> currentPositions,
      List<JigSawTileEdges> edges
      ) {
    final whitespacePosition = Position(x: size, y: size);
    return [
      for (int i = 1; i <= size * size; i++)
        if (i == size * size)
          JigSawTile(
            edges: edges[i - 1],
            value: i,
            correctPosition: whitespacePosition,
            currentPosition: currentPositions[i - 1],
            acceptedPositions: [whitespacePosition],
            isWhitespace: true,
          )
        else
          JigSawTile(
              edges: edges[i - 1],
              value: i,
              correctPosition: correctPositions[i - 1],
              currentPosition: currentPositions[i - 1],
              acceptedPositions: _getAcceptedPositions(
                  i - 1,
                  correctPositions,
                  edges
              )
          )
    ];
  }

  List<JigSawTileEdges> _getEdges(int size,) {
    final edges = List.generate(
      size,
          (i) => List.generate(
        size,
            (j) =>
            JigSawTileEdges.getUndefined(),
      ),
    );

    /// 1,1   1,2   1,3   1,4
    /// 2,1   2,2   2,3   2,4
    /// 3,1   3,2   3,3   3,4
    /// 4,1   4,2   4,3   4,4

    for (var y = 0; y < size; y++) {
      for (var x = 0; x < size; x++) {
        if (x == size - 1 && y == size - 1) {
          continue;
        }

        final edge = edges[x][y];
        JigSawTileEdges? right;
        JigSawTileEdges? bottom;

        if (x < (size - 1)) {
          bottom = edges[x + 1][y];
        }

        if (y < (size - 1)) {
          right = edges[x][y + 1];
        }

        if (x == 0) {
          edge.top = JigSawTileEdges.none;
        }

        if (y == 0) {
          edge.left = JigSawTileEdges.none;
        }

        if (x == (size - 1)) {
          edge.bottom = JigSawTileEdges.none;
        }

        if (y == (size - 1)) {
          edge.right = JigSawTileEdges.none;
        }

        if (x == (size - 1) && y == (size - 2)) {
          edge.right = JigSawTileEdges.none;
        }

        if (x == (size - 2) && y == (size - 1)) {
          edge.bottom = JigSawTileEdges.none;
        }

        final pos = [JigSawTileEdges.bump, JigSawTileEdges.hole];
        if (edge.right == JigSawTileEdges.undefined) {
          pos.shuffle(yaRandom);
          edge.right = pos[0];
          right!.left = pos[1];
        }

        if (edge.bottom == JigSawTileEdges.undefined) {
          pos.shuffle(yaRandom);
          edge.bottom = pos[0];
          bottom!.top = pos[1];
        }
      }
    }

    final newEdges = <JigSawTileEdges>[];
    for (var y = 0; y < size; y++) {
      for (var x = 0; x < size; x++) {
        newEdges.add(edges[y][x]);
      }
    }

    return newEdges;
  }

  List<Position> _getAcceptedPositions(
      int index,
      List<Position> correctPositions,
      List<JigSawTileEdges> edges
      ) {
    final findEdge = edges[index];
    final acceptedPositions = <Position>[];

    for (var i = 0; i < edges.length; i++) {
      final edge = edges[i];

      if (edge == findEdge && index != i) {
        acceptedPositions.add(correctPositions[i]);
      }
    }

    return acceptedPositions;
  }
}
