
import 'package:flutter/material.dart';
import 'package:very_good_slide_puzzle/colors/colors.dart';
import 'package:very_good_slide_puzzle/jigsaw/jigsaw_tile.dart';
import 'package:very_good_slide_puzzle/layout/layout.dart';
import 'package:very_good_slide_puzzle/models/models.dart';

///
class PuzzlePiece extends StatefulWidget {
  ///
  const PuzzlePiece(
      {Key? key,
        required this.tile,
        required this.layoutSize,
        required this.gameStarted,
      })
      : super(key: key);

  ///
  final JigSawTile tile;
  final ResponsiveLayoutSize layoutSize;
  final bool gameStarted;

  @override
  PuzzlePieceState createState() {
    return PuzzlePieceState();
  }
}

///
class PuzzlePieceState extends State<PuzzlePiece> {
  @override
  Widget build(BuildContext context) {
    final tileSize = TileSize.get(widget.layoutSize.name);

    final colorFill =
    widget.tile.currentPosition == widget.tile.correctPosition
        && widget.gameStarted
        ? PuzzleColors.greenPrimary
        : PuzzleColors.green50;

    final colorStroke =
    widget.tile.currentPosition == widget.tile.correctPosition
        && widget.gameStarted
        ? PuzzleColors.white2
        : PuzzleColors.white;

    return CustomPaint(
      painter: PuzzlePiecePainter(
        tile: widget.tile,
        tileSize: tileSize,
        background: true,
        colorStroke: colorStroke,
        colorFill: colorFill,
      ),
      foregroundPainter: PuzzlePiecePainter(
        tile: widget.tile,
        tileSize: tileSize,
        background: false,
        colorStroke: colorStroke,
        colorFill: colorFill,
      ),
    );
  }
}

/// this class is used to clip the image to the puzzle piece path
class PuzzlePieceClipper extends CustomClipper<Path> {

  /// constructor
  PuzzlePieceClipper(this.tile, this.tileSize);

  final JigSawTile tile;
  final double tileSize;

  @override
  Path getClip(Size size) {
    return getPiecePath(tile, tileSize);
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

/// this class is used to draw a border around the clipped image
class PuzzlePiecePainter extends CustomPainter {

  /// constructor
  PuzzlePiecePainter({
    required this.tile,
    required this.tileSize,
    required this.background,
    required this.colorStroke,
    required this.colorFill
  });

  final JigSawTile tile;
  final double tileSize;
  final bool background;

  final Color colorStroke;
  final Color colorFill;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = colorStroke
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    if (background) {
      paint
        ..style = PaintingStyle.fill
        ..color = colorFill;
    }

    canvas.drawPath(getPiecePath(tile, tileSize), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

/// this is the path used to clip the image and, then, to draw a border around
/// it; here we actually draw the puzzle piece
Path getPiecePath(JigSawTile tile, double tileSize) {
  final width = tileSize;
  final height = tileSize;
  final bumpSize = height / 3;

  final adjust = tileSize == TileSize.small ? 5 : 10;

  final path = Path()
    ..moveTo(0, 0);

  var edges = tile.edges;

  if (edges.top == JigSawTileEdges.none) {
    path.lineTo(width, 0);
  } else {
    /// default: hole
    var y1 = bumpSize;
    var startX = width / 3;
    var x3 = width / 3 * 2;

    if (edges.top == JigSawTileEdges.bump) {
      y1 = -bumpSize;
      startX = width / 3 + adjust;
      x3 = width / 3 * 2 - adjust;
    }

    path..lineTo(startX, 0)
      ..cubicTo(width / 6 + adjust, y1, width / 6 * 5 - adjust, y1, x3, 0)
      ..lineTo(width, 0);
  }

  if (edges.right == JigSawTileEdges.none) {
    path.lineTo(width, height);
  } else {
    // default: hole
    var startY = height / 3;
    var x1 = width - bumpSize;
    var y3 = height / 3 * 2;

    if (edges.right == JigSawTileEdges.bump) {
      startY = height / 3 + adjust;
      x1 = width + bumpSize;
      y3 = height / 3 * 2 - adjust;
    }

    path..lineTo(width, startY)
      ..cubicTo(x1, height / 6 + adjust, x1, height / 6 * 5 - adjust, width, y3)
      ..lineTo(width, height);
  }

  if (edges.bottom == JigSawTileEdges.none) {
    path.lineTo(0, height);
  } else {
    /// default: hole
    var startX = width / 3 * 2;
    var y1 = height - bumpSize;
    var x3 = width / 3;

    if (edges.bottom == JigSawTileEdges.bump) {
      y1 = height + bumpSize;
      startX = width / 3 * 2 - adjust;
      x3 = width / 3 + adjust;
    }

    path..lineTo(startX, height)
      ..cubicTo(width / 6 * 5 - adjust, y1, width / 6 + adjust, y1, x3, height)
      ..lineTo(0, height);
  }

  if (edges.left == JigSawTileEdges.none) {
    path.close();
  } else {
    /// default: hole
    var startY = height / 3 * 2;
    var x1 = bumpSize;
    var y3 = height / 3;

    if (edges.left == JigSawTileEdges.bump) {
      startY = height / 3 * 2 - adjust;
      x1 = -bumpSize;
      y3 = height / 3 + adjust;
    }

    path..lineTo(0, startY)
      ..cubicTo(x1, height / 6 * 5 - adjust, x1, height / 6 + adjust, 0, y3)
      ..close();
  }

  return path;
}