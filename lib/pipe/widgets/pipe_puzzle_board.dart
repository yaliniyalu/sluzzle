import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:very_good_slide_puzzle/audio_control/audio_control.dart';
import 'package:very_good_slide_puzzle/dashatar/dashatar.dart';
import 'package:very_good_slide_puzzle/helpers/helpers.dart';
import 'package:very_good_slide_puzzle/layout/layout.dart';
import 'package:very_good_slide_puzzle/models/models.dart';
import 'package:very_good_slide_puzzle/puzzle/puzzle.dart';
import 'package:very_good_slide_puzzle/timer/timer.dart';

abstract class _BoardSize {
  static double small = 312;
  static double medium = 424;
  static double large = 472;
}

abstract class _StartTileLeftPos {
  static double small = -78;
  static double medium = -105;
  static double large = -120;

  static double get(String val) {
    if (val == 'small') {
      return small;
    }

    if (val == 'medium') {
      return medium;
    }

    return large;
  }
}

/// {@template dashatar_puzzle_board}
/// Displays the board of the puzzle in a [Stack] filled with [tiles].
/// {@endtemplate}
class PipePuzzleBoard extends StatefulWidget {
  /// {@macro dashatar_puzzle_board}
  const PipePuzzleBoard({
    Key? key,
    required this.tiles,
  }) : super(key: key);

  /// The tiles to be displayed on the board.
  final List<Widget> tiles;

  @override
  State<PipePuzzleBoard> createState() => _PipePuzzleBoardState();
}

class _PipePuzzleBoardState extends State<PipePuzzleBoard> {
  Timer? _completePuzzleTimer;

  @override
  void dispose() {
    _completePuzzleTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status =
    context.select((DashatarPuzzleBloc bloc) => bloc.state.status);
    final hasStarted = status == DashatarPuzzleStatus.started;
    final puzzle = context.select((PuzzleBloc bloc) => bloc.state.puzzle);

    return BlocListener<PuzzleBloc, PuzzleState>(
      listener: (context, state) async {
        if (state.puzzleStatus == PuzzleStatus.complete) {
          _completePuzzleTimer =
              Timer(const Duration(milliseconds: 370), () async {
            await showAppDialog<void>(
              context: context,
              child: MultiBlocProvider(
                providers: [
                  BlocProvider.value(
                    value: context.read<DashatarThemeBloc>(),
                  ),
                  BlocProvider.value(
                    value: context.read<PuzzleBloc>(),
                  ),
                  BlocProvider.value(
                    value: context.read<TimerBloc>(),
                  ),
                  BlocProvider.value(
                    value: context.read<AudioControlBloc>(),
                  ),
                ],
                child: const DashatarShareDialog(),
              ),
            );
          });
        }
      },
      child: ResponsiveLayoutBuilder(
        small: (_, child) => SizedBox.square(
          key: const Key('dashatar_puzzle_board_small'),
          dimension: _BoardSize.small,
          child: child,
        ),
        medium: (_, child) => SizedBox.square(
          key: const Key('dashatar_puzzle_board_medium'),
          dimension: _BoardSize.medium,
          child: child,
        ),
        large: (_, child) => SizedBox.square(
          key: const Key('dashatar_puzzle_board_large'),
          dimension: _BoardSize.large,
          child: child,
        ),
        child: (size) => Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: _StartTileLeftPos.get(size.name),
              top: 0,
              child: SizedBox.square(
                dimension: TileSize.get(size.name),
                child: Image.asset(
                  hasStarted
                      ? 'assets/images/pipe/filled/tap.png'
                      : 'assets/images/pipe/empty/tap.png',
                  fit: BoxFit.fill,
                ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: SizedBox.square(
                dimension: TileSize.get(size.name),
                child: Image.asset(
                  hasStarted && puzzle.isComplete()
                      ? 'assets/images/pipe/dirt_watered.png'
                      : 'assets/images/pipe/dirt_unwatered.png',
                  fit: BoxFit.fill,
                ),
              ),
            ),
            Stack(
                clipBehavior: Clip.none,
                children: widget.tiles
            ),
          ],
        )
      ),
    );
  }
}
