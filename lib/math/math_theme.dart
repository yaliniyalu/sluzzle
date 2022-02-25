import 'dart:ui';

import 'package:very_good_slide_puzzle/colors/colors.dart';
import 'package:very_good_slide_puzzle/layout/layout.dart';
import 'package:very_good_slide_puzzle/math/layout/layout.dart';
import 'package:very_good_slide_puzzle/math/math_puzzle_helper.dart';
import 'package:very_good_slide_puzzle/theme/themes/themes.dart';

/// {@template math_theme}
/// The jigsaw puzzle theme.
/// {@endtemplate}
class MathTheme extends PuzzleTheme {
  /// {@macro simple_theme}
  const MathTheme() : super();

  @override
  String get name => 'Math';

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
  Color get hoverColor => PuzzleColors.green50;

  @override
  Color get pressedColor => PuzzleColors.green90;

  @override
  bool get isLogoColored => false;

  @override
  Color get menuActiveColor => PuzzleColors.white;

  @override
  Color get menuUnderlineColor => PuzzleColors.white;

  @override
  PuzzleLayoutDelegate get layoutDelegate =>
      const MathPuzzleLayoutDelegate();

  /// The text color of the countdown timer.
  Color get countdownColor => PuzzleColors.yellow50;

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
  Color get backgroundColor => PuzzleColors.yellowPrimary;

  @override
  Color get defaultColor => PuzzleColors.greenPrimary;

  @override
  Color get buttonColor => PuzzleColors.yellow50;

  @override
  Color get menuInactiveColor => PuzzleColors.yellow50;

  @override
  String get audioControlOffAsset =>
      'assets/images/audio_control/green_dashatar_off.png';

  /// The path to the audio asset of this theme.
  @override
  String get audioAsset => 'assets/audio/skateboard.mp3';

  @override
  PuzzleHelper get puzzleHelper => const MathPuzzleHelper();
}
