import 'package:common/common.dart';

class Details {
  Details({
    required this.projectName,
  });

  factory Details.fromEnvironment() => Details(
        projectName: const String.fromEnvironment(kProjectName),
      );

  factory Details.merge(Details base, Details? overlay) => Details(
        projectName: overlay?.projectName ?? base.projectName,
      );

  final String projectName;
}
