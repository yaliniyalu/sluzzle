
import 'dart:math';

import 'package:very_good_slide_puzzle/math/math_tile.dart';
import 'package:very_good_slide_puzzle/models/models.dart';
import 'package:very_good_slide_puzzle/theme/theme.dart';

class MathPuzzleHelper extends SimplePuzzleHelper {
  const MathPuzzleHelper();
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
    final formulas = puzzle.tiles.map((e) => (e as MathTile).text).toList();

    currentPositions.shuffle(random);

    var tiles = _getTileListFromPositions(
      puzzle.size,
      correctPositions,
      currentPositions,
      formulas,
    );

    puzzle2 = puzzle.copyWithTiles(tiles);

    while (!puzzle2.isSolvable() || puzzle2.getNumberOfCorrectTiles() != 0) {
      currentPositions.shuffle(random);
      tiles = _getTileListFromPositions(
        puzzle2.size,
        correctPositions,
        currentPositions,
        formulas,
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
    final formulas = _getFormulas(size);

    if (shuffle) {
      // Randomize only the current tile positions.
      currentPositions.shuffle(random);
    }

    var tiles = _getTileListFromPositions(
        size,
        correctPositions,
        currentPositions,
        formulas
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
            formulas
        );
        puzzle = puzzle.copyWithTiles(tiles);
      }
    }

    return puzzle;
  }

  /// Build a list of tiles - giving each tile their correct position and a
  /// current position.
  List<MathTile> _getTileListFromPositions(
      int size,
      List<Position> correctPositions,
      List<Position> currentPositions,
      List<String> formulas
      ) {
    final whitespacePosition = Position(x: size, y: size);
    return [
      for (int i = 1; i <= size * size; i++)
        if (i == size * size)
          MathTile(
            text: formulas[i - 1],
            value: i,
            correctPosition: whitespacePosition,
            currentPosition: currentPositions[i - 1],
            isWhitespace: true,
          )
        else
          MathTile(
            text: formulas[i - 1],
            value: i,
            correctPosition: correctPositions[i - 1],
            currentPosition: currentPositions[i - 1],
          )
    ];
  }

  int _getRandom(Random rnd, int min, int max) {
    return min + rnd.nextInt(max - min);
  }

  List<String> _getFormulas(int size,) {
    final list = <String>[];

    final rnd = Random();
    final max = (size * size) - 1;

    for (var y = 1; y <= size * size; y++) {
      if (y == size * size) {
         list.add('none');
      } else {
        list.add(_getFormula(rnd, y, max));
      }
    }

    return list;
  }

  String _getFormula(Random rnd, int val, int limit) {
    final ops = ['+', '-', '*', '/', 'sq', 'cb', 'nop'];
    ops.shuffle(rnd);

    for (var i = 0; i < ops.length; i ++) {
      switch (ops[i]) {
        case '+':
          if (val <= 2) {
            break;
          }

          final no = _getRandom(rnd, 1, val - 1);
          return '$no + ${val - no}';

        case '-':
          final no = _getRandom(rnd, limit ~/ 2, limit - 1);
          return '${val + no} - $no';

        case '*':
          final frm = <List<int>>[];
          for (var x = 2; x < val; x ++) {
            for (var y = val - 1; y > 1; y --) {
              if (x * y == val) {
                frm.add([x, y]);
              }
            }
          }

          if (frm.isEmpty) {
            break;
          }

          final v = frm[Random().nextInt(frm.length)];
          return '${v[0]} x ${v[1]}';

        case '/':
          if (val < 2) {
            break;
          }

          final no = _getRandom(rnd, 1, max(val, 10));
          final a = val * no;
          return '$a / $no';

        case 'sq':
          if (val < 2 || sqrt(val) % 1 != 0) {
            break;
          }

          return '${sqrt(val)}²';

        case 'cb':
          if (val < 2 || pow(val, 1/3) % 1 != 0) {
            break;
          }

          return '${pow(val, 1/3)}³';

        case 'nop':
        default:
          return val.toString();
      }
    }

    return val.toString();
  }
}
