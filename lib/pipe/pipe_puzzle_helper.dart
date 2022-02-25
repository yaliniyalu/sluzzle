
import 'dart:math';

import 'package:very_good_slide_puzzle/models/models.dart';
import 'package:very_good_slide_puzzle/pipe/pipe_tile.dart';
import 'package:very_good_slide_puzzle/pipe/pipe_tile_openings.dart';
import 'package:very_good_slide_puzzle/theme/theme.dart';

class _PipeOpening {
  _PipeOpening(this.openedAt);

  String openedAt;
  bool isVisited = false;
}

class _Pipe {
  _Pipe(this.position, this.value, this.openings);

  final List<_PipeOpening> openings;
  final Position position;
  final int value;

  static _Pipe fromTile(PipeTile tile) {
    final openings = <_PipeOpening>[];

    tile.edges.getOpenEdges()
        .forEach((element) {openings.add(_PipeOpening(element));});

    return _Pipe(Position(
        x: tile.currentPosition.x,
        y: tile.currentPosition.y,
    ), tile.value, openings,);
  }

  bool isOpenedAt(String pos) {
    for (final opening in openings) {
      if (opening.openedAt == pos) return true;
    }
    return false;
  }

  _PipeOpening? getOpeningAt(String pos) {
    for (final opening in openings) {
      if (opening.openedAt == pos) return opening;
    }
    return null;
  }

  List<_PipeOpening> getUnvisitedOpenings() {
    return openings.where((element) => !element.isVisited).toList();
  }

  _Pipe? getNext(String pos, List<List<_Pipe>> pipes) {
    var next = <int>[pipes.length, pipes.length];

    switch (pos) {
      case 'left':  next = [position.x - 1, position.y]; break;
      case 'right': next = [position.x + 1, position.y]; break;
      case 'up':    next = [position.x, position.y - 1]; break;
      case 'down':  next = [position.x, position.y + 1]; break;
    }

    if (next[0] > pipes.length || next[1] > pipes.length) {
      return null;
    }

    if (next[0] < 1 || next[1] < 1) {
      return null;
    }

    return pipes[next[1] - 1][next[0] - 1];
  }

  @override
  String toString() {
    return '[${position.x}, ${position.y}] => [${openings.map((e) => e.openedAt).join(',')}]';
  }
}

class PipePuzzleHelper extends SimplePuzzleHelper {
  const PipePuzzleHelper();
  final Random? yaRandom = null;

  @override
  Puzzle generate(int size, {bool shuffle = true, Random? random}) {
    return _generatePuzzle(size, shuffle: shuffle, random: random);
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

  bool isPipeConnected(List<Tile> tiles, Tile tile) {
    final connections = _getConnections(tiles);
    final conn = connections.indexWhere((el) => el.value == tile.value);
    return conn != -1;
  }

  List<_Pipe> _getConnections(List<Tile> tiles) {
    tiles.sort((a, b) => a.currentPosition.compareTo(b.currentPosition));
    final size = sqrt(tiles.length).toInt();
    final pipes = _generateChunks(
      tiles.map((e) => _Pipe.fromTile(e as PipeTile)).toList(),
      size,
    );

    final first = pipes[0][0];
    if (!first.isOpenedAt('left')) {
      return [];
    }

    first.getOpeningAt('left')?.isVisited = true;
    final connected = <_Pipe>[first, ..._getConnectedPipes(first, pipes)];

    return connected;
  }

  List<_Pipe> _getConnectedPipes(
      _Pipe pipe,
      List<List<_Pipe>> pipes,
      ) {

    final unvisited = pipe.getUnvisitedOpenings();
    if (unvisited.isEmpty) {
      return [];
    }
    final connected = <_Pipe>[];
    for (final u in unvisited) {
      final next = pipe.getNext(u.openedAt, pipes);
      if (next == null) continue;
      u.isVisited = true;

      final opening = next.getOpeningAt(PipeTileOpenings.getLinkedSide(u.openedAt));
      if (opening == null) continue;

      opening.isVisited = true;

      connected
        ..add(next)
        ..addAll(_getConnectedPipes(next, pipes));
    }

    return connected;
  }

  List<List<T>> _generateChunks<T>(List<T> inList, int chunkSize) {
    final outList = <List<T>>[];
    final tmpList = <T>[];
    var counter = 0;

    for (var current = 0; current < inList.length; current++) {
      if (counter != chunkSize) {
        tmpList.add(inList[current]);
        counter++;
      }
      if (counter == chunkSize || current == inList.length - 1) {
        outList.add(tmpList.toList());
        tmpList.clear();
        counter = 0;
      }
    }

    return outList;
  }

  @override
  bool isComplete(List<Tile> tiles) {
    final connections = _getConnections(tiles);
    final size = sqrt(tiles.length).toInt();

    final bucket = tiles.where((element) => element.isWhitespace).toList()[0];
    if (bucket.currentPosition.x != size || bucket.currentPosition.y != size) {
      return false;
    }

    for (final pipe in connections) {

      if (pipe.position.x == size - 1
          && pipe.position.y == size
          && pipe.isOpenedAt('right')
      ) {
        return true;
      } else if (pipe.position.x == size
          && pipe.position.y == size - 1
          && pipe.isOpenedAt('down')
      ) {
        return true;
      }
    }

    return false;
  }

  @override
  Puzzle shuffle(Puzzle puzzle, Random? random) {
    final positions = TilePositions(puzzle.size);
    final correctPositions = positions.correctPositions;
    final currentPositions = positions.currentPositions;

    Puzzle puzzle2;

    puzzle.tiles.sort((a, b) => a.value.compareTo(b.value));
    final edges = puzzle.tiles.map((e) => (e as PipeTile).edges).toList();

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

  /// Build a randomized, solvable puzzle of the given size.
  Puzzle _generatePuzzle(int size, {bool shuffle = true, Random? random}) {
    final positions = TilePositions(size);
    final correctPositions = positions.correctPositions;
    final currentPositions = positions.currentPositions;
    var openings = <PipeTileOpenings>[];

    while (openings.isEmpty) {
      openings = _getPipes(size);
    }

    if (shuffle) {
      // Randomize only the current tile positions.
      currentPositions.shuffle(random);
    }

    var tiles = _getTileListFromPositions(
        size,
        correctPositions,
        currentPositions,
        openings
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
            openings
        );
        puzzle = puzzle.copyWithTiles(tiles);
      }
    }

    return puzzle;
  }

  /// Build a list of tiles - giving each tile their correct position and a
  /// current position.
  List<PipeTile> _getTileListFromPositions(
      int size,
      List<Position> correctPositions,
      List<Position> currentPositions,
      List<PipeTileOpenings> edges
      ) {
    final whitespacePosition = Position(x: size, y: size);
    return [
      for (int i = 1; i <= size * size; i++)
        if (i == size * size)
          PipeTile(
            edges: edges[i - 1],
            value: i,
            correctPosition: whitespacePosition,
            currentPosition: currentPositions[i - 1],
            isWhitespace: true,
          )
        else
          PipeTile(
            edges: edges[i - 1],
            value: i,
            correctPosition: correctPositions[i - 1],
            currentPosition: currentPositions[i - 1],
          )
    ];
  }

  List<PipeTileOpenings> _getPipes(int size,) {
    final edges = List.generate(
      size,
          (i) => List.generate(
        size,
            (j) =>
            PipeTileOpenings.getDefault(),
      ),
    );

    /// 1,1   1,2   1,3   1,4
    /// 2,1   2,2   2,3   2,4
    /// 3,1   3,2   3,3   3,4
    /// 4,1   4,2   4,3   4,4

    for (var y = 0; y < size; y++) {
      for (var x = 0; x < size; x++) {
        final edge = edges[x][y];

        if (x == size - 1 && y == size - 1) {
          edge.isBucket = true;
          continue;
        }

        if (x == 0) {
          edge.up = PipeTileOpenings.close;
        }

        if (y == 0) {
          edge.left = PipeTileOpenings.close;
        }

        if (x == (size - 1)) {
          edge.down = PipeTileOpenings.close;
        }

        if (y == (size - 1)) {
          edge.right = PipeTileOpenings.close;
        }
      }
    }

    var nextRC = [0, 0];
    edges[nextRC[0]][nextRC[1]].left = PipeTileOpenings.open;

    var found = false;
    while(true) {
      final next = edges[nextRC[0]][nextRC[1]];

      final op = next.getUndefinedEdges()
        ..shuffle();

      if (op.isEmpty) {
        break;
      }

      next.setValue(op[0], PipeTileOpenings.open);
      nextRC = PipeTileOpenings.findNextRC(nextRC, op[0]);

      if (!edges[nextRC[0]][nextRC[1]].isBucket) {
        edges[nextRC[0]][nextRC[1]]
            .setValue(
          PipeTileOpenings.getLinkedSide(op[0]),
          PipeTileOpenings.open,
        );
      }

      if (nextRC[0] == size - 1 && nextRC[1] == size - 1) {
        found = true;
        break;
      }
    }

    if (!found) {
      return [];
    }

    final newEdges = <PipeTileOpenings>[];
    for (var y = 0; y < size; y++) {
      for (var x = 0; x < size; x++) {
        newEdges.add(edges[y][x]);
      }
    }

    return newEdges;
  }
}
