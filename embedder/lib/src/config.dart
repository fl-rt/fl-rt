import 'dart:typed_data';

class Config {
  const Config({
    this.flutterAssetsPath,
    this.icuDataPath,
    this.elfSnapshotPath,
    this.vmArguments,
    this.windowIconProvider,
    this.windowInitialDimensions,
    this.windowInitialLocation,
    this.windowDimensionLimits,
    this.windowMode,
    this.windowAlwaysOnTop,
    this.windowTransparent,
    this.forcePixelRatio,
    this.scrollAmount,
  });

  final String? flutterAssetsPath;

  final String? icuDataPath;

  final String? elfSnapshotPath;

  final List<String>? vmArguments;

  final Uint8List Function()? windowIconProvider;

  final WindowDimensions? windowInitialDimensions;

  final WindowLocation? windowInitialLocation;

  final WindowDimensionLimits? windowDimensionLimits;

  final WindowMode? windowMode;

  final bool? windowAlwaysOnTop;

  final bool? windowTransparent;

  final double? forcePixelRatio;

  final double? scrollAmount;
}

class WindowDimensions {
  WindowDimensions({
    required this.width,
    required this.height,
  });

  int width;

  int height;
}

class WindowLocation {
  const WindowLocation({
    required this.xPos,
    required this.yPos,
  });

  final int xPos;

  final int yPos;
}

class WindowDimensionLimits {
  const WindowDimensionLimits({
    required this.minWidth,
    required this.minHeight,
    required this.maxWidth,
    required this.maxHeight,
  });

  final int minWidth;

  final int minHeight;

  final int maxWidth;

  final int maxHeight;
}

enum WindowMode {
  windowModeDefault,
  windowModeMaximize,
  windowModeBorderlessMaximize,
  windowModeBorderless,
  windowModeBorderlessFullscreen,
}
