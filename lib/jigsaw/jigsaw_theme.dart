import 'dart:ui';

import 'package:very_good_slide_puzzle/colors/colors.dart';
import 'package:very_good_slide_puzzle/jigsaw/jigsaw_puzzle_helper.dart';
import 'package:very_good_slide_puzzle/jigsaw/layout/layout.dart';
import 'package:very_good_slide_puzzle/layout/layout.dart';
import 'package:very_good_slide_puzzle/theme/themes/themes.dart';

/// {@template jigsaw_theme}
/// The jigsaw puzzle theme.
/// {@endtemplate}
class JigSawTheme extends PuzzleTheme {
  /// {@macro simple_theme}
  const JigSawTheme() : super();

  @override
  String get name => 'JigSaw';

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
      const JigSawPuzzleLayoutDelegate();

  /// The text color of the countdown timer.
  Color get countdownColor => PuzzleColors.blue50;

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
  Color get backgroundColor => PuzzleColors.bluePrimary;

  @override
  Color get defaultColor => PuzzleColors.blue90;

  @override
  Color get buttonColor => PuzzleColors.blue50;

  @override
  Color get menuInactiveColor => PuzzleColors.blue50;

  @override
  String get audioControlOffAsset =>
      'assets/images/audio_control/blue_dashatar_off.png';

  @override
  PuzzleHelper get puzzleHelper => const JigSawPuzzleHelper();
}
