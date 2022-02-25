import 'dart:math';

import 'package:very_good_slide_puzzle/models/models.dart';

class TilePositions {
  /// constructor
  TilePositions(int size) {
    _generate(size);
  }

  late final List<Position> correctPositions;
  late final List<Position> currentPositions;

  void _generate(int size) {
    correctPositions = <Position>[];
    currentPositions = <Position>[];
    final whitespacePosition = Position(x: size, y: size);

    // Create all possible board positions.
    for (var y = 1; y <= size; y++) {
      for (var x = 1; x <= size; x++) {
        if (x == size && y == size) {
          correctPositions.add(whitespacePosition);
          currentPositions.add(whitespacePosition);
        } else {
          final position = Position(x: x, y: y);
          correctPositions.add(position);
          currentPositions.add(position);
        }
      }
    }
  }
}

abstract class PuzzleHelper {
  const PuzzleHelper();

  /// Generate
  Puzzle generate(int size, {bool shuffle = true, Random? random});

  /// Gets the number of tiles that are currently in their correct position.
  int getNumberOfCorrectTiles(List<Tile> tiles);

  /// Determines if the puzzle is completed.
  bool isComplete(List<Tile> tiles);

  /// Shuffle and return new puzzle
  Puzzle shuffle(Puzzle puzzle, Random? random);

  /// Gets the single whitespace tile object in the puzzle.
  Tile getWhitespaceTile(List<Tile> tiles) {
    return tiles.singleWhere((tile) => tile.isWhitespace);
  }
}

class SimplePuzzleHelper extends PuzzleHelper {
  const SimplePuzzleHelper();

  @override
  Puzzle generate(int size, {bool shuffle = true, Random? random}) {
    return _generatePuzzle(size, shuffle: shuffle, random: random);
  }

  /// Build a randomized, solvable puzzle of the given size.
  Puzzle _generatePuzzle(int size, {bool shuffle = true, Random? random}) {
    final positions = TilePositions(size);
    final correctPositions = positions.correctPositions;
    final currentPositions = positions.currentPositions;

    if (shuffle) {
      // Randomize only the current tile positions.
      currentPositions.shuffle(random);
    }

    var tiles = _getTileListFromPositions(
      size,
      correctPositions,
      currentPositions,
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
        );
        puzzle = Puzzle(tiles: tiles, size: size, helper: this);
      }
    }

    return puzzle;
  }

  /// Build a list of tiles - giving each tile their correct position and a
  /// current position.
  List<Tile> _getTileListFromPositions(
      int size,
      List<Position> correctPositions,
      List<Position> currentPositions,
      ) {
    final whitespacePosition = Position(x: size, y: size);
    return [
      for (int i = 1; i <= size * size; i++)
        if (i == size * size)
          SimpleTile(
            value: i,
            correctPosition: whitespacePosition,
            currentPosition: currentPositions[i - 1],
            isWhitespace: true,
          )
        else
          SimpleTile(
            value: i,
            correctPosition: correctPositions[i - 1],
            currentPosition: currentPositions[i - 1],
          )
    ];
  }

  @override
  Puzzle shuffle(Puzzle puzzle, Random? random) {
    final positions = TilePositions(puzzle.size);
    final correctPositions = positions.correctPositions;
    final currentPositions = positions.currentPositions;

    Puzzle puzzle2;

    currentPositions.shuffle(random);

    var tiles = _getTileListFromPositions(
      puzzle.size,
      correctPositions,
      currentPositions
    );

    puzzle2 = puzzle.copyWithTiles(tiles);

    while (!puzzle.isSolvable() || puzzle.getNumberOfCorrectTiles() != 0) {
      currentPositions.shuffle(random);
      tiles = _getTileListFromPositions(
          puzzle.size,
          correctPositions,
          currentPositions
      );
      puzzle2 = puzzle2.copyWithTiles(tiles);
    }

    return puzzle;
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
}
