import 'package:very_good_slide_puzzle/models/models.dart';
import 'package:very_good_slide_puzzle/pipe/pipe_tile_openings.dart';

class PipeTile extends Tile {
  /// constructor
  PipeTile({
    required this.edges,
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

  /// jig saw edges
  final PipeTileOpenings edges;

  @override
  Tile copyWith({required Position currentPosition}) {
    return PipeTile(
      edges: edges,
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
    edges
  ];
}
