import 'dart:ui';

import 'package:very_good_slide_puzzle/colors/colors.dart';
import 'package:very_good_slide_puzzle/layout/layout.dart';
import 'package:very_good_slide_puzzle/pipe/layout/layout.dart';
import 'package:very_good_slide_puzzle/pipe/pipe_puzzle_helper.dart';
import 'package:very_good_slide_puzzle/theme/themes/themes.dart';

/// {@template pipe_theme}
/// The pipe puzzle theme.
/// {@endtemplate}
class PipeTheme extends PuzzleTheme {
  /// {@macro simple_theme}
  const PipeTheme() : super();

  @override
  String get name => 'Pipe';

  @override
  String get audioControlOnAsset =>
      'assets/images/audio_control/dashatar_on.png';

  @override
  bool get hasTimer => true;

  @override
  Color get nameColor => PuzzleColors.white;

  @override
  Color get titleColor => PuzzleColors.white;

  @override
  Color get hoverColor => PuzzleColors.black2;

  @override
  Color get pressedColor => PuzzleColors.white2;

  @override
  bool get isLogoColored => false;

  @override
  Color get menuActiveColor => PuzzleColors.white;

  @override
  Color get menuUnderlineColor => PuzzleColors.white;

  @override
  PuzzleLayoutDelegate get layoutDelegate =>
      const PipePuzzleLayoutDelegate();

  /// The text color of the countdown timer.
  Color get countdownColor => PuzzleColors.green50;

  /// The path to the audio asset of this theme.
  String get audioAsset => 'assets/audio/dumbbell.mp3';

  @override
  List<Object?> get props => [
    name,
    hasTimer,
    nameColor,
    titleColor,
    backgroundColor,
    defaultColor,
    buttonColor,
    hoverColor,
    pressedColor,
    isLogoColored,
    menuActiveColor,
    menuUnderlineColor,
    menuInactiveColor,
    audioControlOnAsset,
    audioControlOffAsset,
    layoutDelegate,
    countdownColor,
    audioAsset,
  ];

  @override
  Color get backgroundColor => PuzzleColors.greenPrimary;

  @override
  Color get defaultColor => PuzzleColors.green90;

  @override
  Color get buttonColor => PuzzleColors.green50;

  @override
  Color get menuInactiveColor => PuzzleColors.green50;

  @override
  String get audioControlOffAsset =>
      'assets/images/audio_control/blue_dashatar_off.png';

  @override
  PuzzleHelper get puzzleHelper => const PipePuzzleHelper();
}
