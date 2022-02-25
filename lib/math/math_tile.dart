import 'package:very_good_slide_puzzle/models/models.dart';

class MathTile extends Tile {
  /// constructor
  MathTile({
    required this.text,
    required int value,
    required Position correctPosition,
    required Position currentPosition,
    bool isWhitespace = false
  })
      : super(
      value: value,
      correctPosition: correctPosition,
      currentPosition: currentPosition,
      isWhitespace: isWhitespace
  );

  /// math formula
  final String text;

  @override
  Tile copyWith({required Position currentPosition}) {
    return MathTile(
      text: text,
      value: value,
      correctPosition: correctPosition,
      currentPosition: currentPosition,
      isWhitespace: isWhitespace,
    );
  }

  @override
  List<Object> get props => [
    value,
    correctPosition,
    currentPosition,
    isWhitespace,
    text
  ];
}
