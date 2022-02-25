import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:very_good_slide_puzzle/audio_control/audio_control.dart';
import 'package:very_good_slide_puzzle/colors/colors.dart';
import 'package:very_good_slide_puzzle/dashatar/dashatar.dart';
import 'package:very_good_slide_puzzle/helpers/helpers.dart';
import 'package:very_good_slide_puzzle/layout/layout.dart';
import 'package:very_good_slide_puzzle/math/math_tile.dart';
import 'package:very_good_slide_puzzle/models/models.dart';
import 'package:very_good_slide_puzzle/puzzle/puzzle.dart';
import 'package:very_good_slide_puzzle/theme/bloc/theme_bloc.dart';
import 'package:very_good_slide_puzzle/theme/themes/themes.dart';
import 'package:very_good_slide_puzzle/typography/text_styles.dart';

abstract class _TileFontSize {
  static double small = 16;
  static double medium = 22;
  static double large = 24;

  static double get(String name) {
    switch (name) {
      case 'large': return large;
      case 'medium': return medium;
      case 'small':
      default: return small;
    }
  }
}

/// {@template dashatar_puzzle_tile}
/// Displays the puzzle tile associated with [tile]
/// based on the puzzle [state].
/// {@endtemplate}
class MathPuzzleTile extends StatefulWidget {
  /// {@macro dashatar_puzzle_tile}
  const MathPuzzleTile({
    Key? key,
    required this.tile,
    required this.state,
    AudioPlayerFactory? audioPlayer,
  })  : _audioPlayerFactory = audioPlayer ?? getAudioPlayer,
        super(key: key);

  /// The tile to be displayed.
  final MathTile tile;

  /// The state of the puzzle.
  final PuzzleState state;

  final AudioPlayerFactory _audioPlayerFactory;

  @override
  State<MathPuzzleTile> createState() => MathPuzzleTileState();
}

/// The state of [MathPuzzleTile].
@visibleForTesting
class MathPuzzleTileState extends State<MathPuzzleTile>
    with SingleTickerProviderStateMixin {
  AudioPlayer? _audioPlayer;
  late final Timer _timer;

  /// The controller that drives [_scale] animation.
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: PuzzleThemeAnimationDuration.puzzleTileScale,
    );

    _scale = Tween<double>(begin: 1, end: 0.94).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 1, curve: Curves.easeInOut),
      ),
    );

    // Delay the initialization of the audio player for performance reasons,
    // to avoid dropping frames when the theme is changed.
    _timer = Timer(const Duration(seconds: 1), () {
      _audioPlayer = widget._audioPlayerFactory()
        ..setAsset('assets/audio/tile_move.mp3');
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _audioPlayer?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.state.puzzle.getDimension();
    final theme = context.select((ThemeBloc bloc) => bloc.state.theme);
    final status =
    context.select((DashatarPuzzleBloc bloc) => bloc.state.status);
    final hasStarted = status == DashatarPuzzleStatus.started;
    final puzzleIncomplete =
        context.select((PuzzleBloc bloc) => bloc.state.puzzleStatus) ==
            PuzzleStatus.incomplete;

    final movementDuration = status == DashatarPuzzleStatus.loading
        ? const Duration(milliseconds: 800)
        : const Duration(milliseconds: 370);

    final canPress = hasStarted && puzzleIncomplete;

    return AudioControlListener(
      audioPlayer: _audioPlayer,
      child: AnimatedAlign(
        alignment: FractionalOffset(
          (widget.tile.currentPosition.x - 1) / (size - 1),
          (widget.tile.currentPosition.y - 1) / (size - 1),
        ),
        duration: movementDuration,
        curve: Curves.easeInOut,
        child: ResponsiveLayoutBuilder(
          small: (_, child) => SizedBox.square(
            key: Key('jigsaw_puzzle_tile_small_${widget.tile.value}'),
            dimension: TileSize.small,
            child: child,
          ),
          medium: (_, child) => SizedBox.square(
            key: Key('jigsaw_puzzle_tile_medium_${widget.tile.value}'),
            dimension: TileSize.medium,
            child: child,
          ),
          large: (_, child) => SizedBox.square(
            key: Key('jigsaw_puzzle_tile_large_${widget.tile.value}'),
            dimension: TileSize.large,
            child: child,
          ),
          child: (size) => MouseRegion(
            onEnter: (_) {
              if (canPress) {
                _controller.forward();
              }
            },
            onExit: (_) {
              if (canPress) {
                _controller.reverse();
              }
            },
            child: ScaleTransition(
                key: Key('math_puzzle_tile_scale_${widget.tile.value}'),
                scale: _scale,
                child:  TextButton(
                  style: TextButton.styleFrom(
                    primary: PuzzleColors.white,
                    textStyle: PuzzleTextStyle.headline2.copyWith(
                      fontSize: _TileFontSize.get(size.name),
                    ),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(12),
                      ),
                    ),
                    backgroundColor: theme.hoverColor
                  ).copyWith(
                    foregroundColor: MaterialStateProperty.all(
                      PuzzleColors.white,
                    ),
                    backgroundColor:
                    MaterialStateProperty.resolveWith<Color?>((states) {
                        if (widget.tile.value == widget.state.lastTappedTile?.value) {
                          return theme.pressedColor;
                        } else if (states.contains(MaterialState.hovered)) {
                          return theme.hoverColor;
                        } else {
                          return theme.defaultColor;
                        }
                      },
                    ),
                  ),
                  onPressed: canPress ? () {
                    context.read<PuzzleBloc>().add(TileTapped(widget.tile));
                    unawaited(_audioPlayer?.replay());
                  } : null,
                  child: Text(
                    widget.tile.currentPosition == widget.tile.correctPosition
                        && hasStarted
                        ? widget.tile.value.toString()
                        : widget.tile.text,
                  ),
                )
            ),
          ),
        ),
      ),
    );
  }
}
