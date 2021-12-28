import 'package:flutter_riverpod/flutter_riverpod.dart';

final flavorProvider = Provider<Enum>(
  (ref) => throw UnimplementedError(),
);

enum Flavor {
  development,
  staging,
  production,
}
