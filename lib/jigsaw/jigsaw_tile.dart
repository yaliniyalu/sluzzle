import 'package:very_good_slide_puzzle/models/models.dart';

class JigSawTile extends Tile {
  /// constructor
  JigSawTile({
    required this.edges,
    required this.acceptedPositions,
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
  final JigSawTileEdges edges;
  final List<Position> acceptedPositions;

  @override
  Tile copyWith({required Position currentPosition}) {
    return JigSawTile(
      edges: edges,
      value: value,
      correctPosition: correctPosition,
      currentPosition: currentPosition,
      acceptedPositions: acceptedPositions,
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
