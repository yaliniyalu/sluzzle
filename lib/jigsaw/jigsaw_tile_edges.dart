import 'package:equatable/equatable.dart';

class JigSawTileEdges extends Equatable {
  JigSawTileEdges(this.left, this.right, this.top, this.bottom);

  int left;
  int right;
  int top;
  int bottom;

  static const bump = 1;
  static const hole = -1;
  static const none = 0;
  static const undefined = 9;

  static JigSawTileEdges getUndefined() {
    return JigSawTileEdges(undefined, undefined, undefined, undefined);
  }

  @override
  List<Object?> get props => [
    left, right, top, bottom
  ];
}