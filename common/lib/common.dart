import 'dart:io';

const String kProjectName = 'projectName';

final Map<OS, String> glfwOutputFiles = {
  OS.linux: 'libglfw.so.3',
  OS.darwin: 'libglfw.dylib',
  OS.windows: 'glfw.dll',
};

enum OS {
  linux,
  darwin,
  windows,
}

extension OSName on OS {
  String get name {
    switch (this) {
      case OS.linux:
        return 'linux';
      case OS.darwin:
        return 'darwin';
      case OS.windows:
        return 'windows';
    }
  }
}

OS osFromPlatform() => osFromString(Platform.operatingSystem);

OS osFromString(String name) {
  switch (name) {
    case 'linux':
      return OS.linux;
    case 'macos':
    case 'darwin':
      return OS.darwin;
    case 'windows':
      return OS.windows;
    default:
      print('Unsupported OS "$name"');
      exit(1);
  }
}
