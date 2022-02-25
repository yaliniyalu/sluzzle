abstract class TileSize {
  static double small = 75;
  static double medium = 100;
  static double large = 112;

  static double get(String val) {
    if (val == 'small') {
      return small;
    }

    if (val == 'medium') {
      return medium;
    }

    return large;
  }
}