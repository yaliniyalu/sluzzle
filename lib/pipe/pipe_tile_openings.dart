import 'dart:math';

import 'package:equatable/equatable.dart';

class PipeTileOpenings extends Equatable {
  /// constructor
  PipeTileOpenings(this._left, this._right, this._up, this._down) {
    loadImage();
  }

  int _left;
  int _right;
  int _up;
  int _down;

  int get left => _left;
  int get right => _right;
  int get up => _up;
  int get down => _down;

  bool isBucket = false;

  String? image;

  set left(int val) {
    _left = val;
    loadImage();
  }

  set right(int val) {
    _right = val;
    loadImage();
  }

  set up(int val) {
    _up = val;
    loadImage();
  }

  set down(int val) {
    _down = val;
    loadImage();
  }

  static const open = 1;
  static const close = 0;
  static const undefined = 9;

  void loadImage() {
    final l = getOpenEdges();

    const variants = ['left_down', 'left_right_up_down', 'left_right'];

    if (l.length < 2) {
      image = null;
    } else {
      var name = l.join('_');
      if (variants.contains(name)) {
        final r = Random().nextInt(2);
        if (r == 1) {
          name = '${name}_x';
        }
      }

      image = name;
    }
  }

  String getImage() {
    return 'assets/images/pipe/empty/$image.png';
  }

  String getFilledImage() {
    return 'assets/images/pipe/filled/$image.png';
  }

  static PipeTileOpenings getDefault() {
    return PipeTileOpenings(undefined, undefined, undefined, undefined);
  }

  List<String> getUndefinedEdges() {
    final list = <String>[];

    if (left == undefined) list.add('left');
    if (right == undefined) list.add('right');
    if (up == undefined) list.add('up');
    if (down == undefined) list.add('down');

    return list;
  }

  List<String> getOpenEdges() {
    final list = <String>[];

    if (left == open) list.add('left');
    if (right == open) list.add('right');
    if (up == open) list.add('up');
    if (down == open) list.add('down');

    return list;
  }

  int getValue(String key) {
    switch (key) {
      case 'left': return left;
      case 'right': return right;
      case 'up': return up;
      case 'down': return down;
    }

    return undefined;
  }

  void setValue(String key, int val) {
    switch (key) {
      case 'left': left = val; break;
      case 'right': right = val; break;
      case 'up': up = val; break;
      case 'down': down = val; break;
    }
  }

  static List<int> findNextRC(List<int> curr, String key) {
    switch (key) {
      case 'left': return [curr[0], curr[1] - 1];
      case 'right': return [curr[0], curr[1] + 1];
      case 'up': return [curr[0] - 1, curr[1]];
      case 'down':return [curr[0] + 1, curr[1]];
    }
    return curr;
  }

  static String getLinkedSide(String key) {
    switch (key) {
      case 'left': return 'right';
      case 'right': return 'left';
      case 'up': return 'down';
      case 'down': return 'up';
    }
    return '';
  }

  @override
  List<Object?> get props => [
    left, right, up, down
  ];
}