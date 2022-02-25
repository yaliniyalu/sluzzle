import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:very_good_slide_puzzle/audio_control/audio_control.dart';
import 'package:very_good_slide_puzzle/dashatar/dashatar.dart';
import 'package:very_good_slide_puzzle/helpers/helpers.dart';
import 'package:very_good_slide_puzzle/layout/layout.dart';
import 'package:very_good_slide_puzzle/models/models.dart';
import 'package:very_good_slide_puzzle/pipe/pipe_puzzle_helper.dart';
import 'package:very_good_slide_puzzle/pipe/pipe_tile.dart';
import 'package:very_good_slide_puzzle/puzzle/puzzle.dart';
import 'package:very_good_slide_puzzle/theme/themes/themes.dart';

/// {@template dashatar_puzzle_tile}
/// Displays the puzzle tile associated with [tile]
/// based on the puzzle [state].
/// {@endtemplate}
class PipePuzzleTile extends StatefulWidget {
  /// {@macro dashatar_puzzle_tile}
  const PipePuzzleTile({
    Key? key,
    required this.tile,
    required this.state,
    AudioPlayerFactory? audioPlayer,
  })  : _audioPlayerFactory = audioPlayer ?? getAudioPlayer,
        super(key: key);

  /// The tile to be displayed.
  final PipeTile tile;

  /// The state of the puzzle.
  final PuzzleState state;

  final AudioPlayerFactory _audioPlayerFactory;

  @override
  State<PipePuzzleTile> createState() => PipePuzzleTileState();
}

/// The state of [PipePuzzleTile].
@visibleForTesting
class PipePuzzleTileState extends State<PipePuzzleTile>
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
    final puzzle = context.select((PuzzleBloc bloc) => bloc.state.puzzle);
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

    final isConnected = (puzzle.helper as PipePuzzleHelper)
        .isPipeConnected(puzzle.tiles, widget.tile);

    final image = isConnected && hasStarted
        ? widget.tile.edges.getFilledImage()
        : widget.tile.edges.getImage();

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
            key: Key('pipe_puzzle_tile_small_${widget.tile.value}'),
            dimension: TileSize.small,
            child: child,
          ),
          medium: (_, child) => SizedBox.square(
            key: Key('pipe_puzzle_tile_medium_${widget.tile.value}'),
            dimension: TileSize.medium,
            child: child,
          ),
          large: (_, child) => SizedBox.square(
            key: Key('pipe_puzzle_tile_large_${widget.tile.value}'),
            dimension: TileSize.large,
            child: child,
          ),
          child: (size) => MouseRegion(
            cursor: canPress ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
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
                key: Key('pipe_puzzle_tile_scale_${widget.tile.value}'),
                scale: _scale,
                child: GestureDetector(
                  onTap: canPress ? () {
                    context.read<PuzzleBloc>().add(TileTapped(widget.tile));
                    unawaited(_audioPlayer?.replay());
                  } : null,
                  child: AbsorbPointer(
                      child: DecoratedBox(
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage('assets/images/pipe/dirt_tile.png'),
                              fit: BoxFit.cover,
                          ),
                        ),
                        child: widget.tile.edges.image != null ? Image.asset(
                          image,
                          fit: BoxFit.fill,
                        ) : null,
                      )
                  ),
                )
            ),
          ),
        ),
      ),
    );
  }
}
