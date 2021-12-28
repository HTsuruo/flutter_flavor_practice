import 'package:flutter/material.dart';
import 'package:flutter_flavor_practice/flavor_provider.dart';
import 'package:flutter_flavor_practice/package_info_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:simple_logger/simple_logger.dart';

final logger = SimpleLogger();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const flavorString = String.fromEnvironment('FLAVOR');
  final flavor = Flavor.values.byName(flavorString);
  logger.info('FLAVOR is [${flavor.name}]');
  late final PackageInfo packageInfo;
  await Future.wait<void>([
    Future(() async {
      packageInfo = await PackageInfo.fromPlatform();
    })
  ]);
  runApp(
    ProviderScope(
      overrides: [
        flavorProvider.overrideWithValue(flavor),
        packageInfoProvider.overrideWithValue(packageInfo),
      ],
      child: App(
        title: packageInfo.appName,
      ),
    ),
  );
}

class App extends StatelessWidget {
  const App({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      theme: ThemeData.from(
        colorScheme: const ColorScheme.light(),
      ),
      darkTheme: ThemeData.from(
        colorScheme: const ColorScheme.dark(),
      ).copyWith(
        dividerTheme: const DividerThemeData(
          space: 0,
        ),
      ),
      themeMode: ThemeMode.dark,
      home: const HomePage(),
    );
  }
}

class HomePage extends ConsumerWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packageInfo = ref.watch(packageInfoProvider);
    final info = <String, String>{
      'appName': packageInfo.appName,
      'packageName': packageInfo.packageName,
      'version': packageInfo.version,
      'buildNumber': packageInfo.buildNumber,
      'buildSignature': packageInfo.buildSignature,
      'flavor': ref.watch(flavorProvider).name,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(packageInfo.appName),
      ),
      body: ListView.separated(
        itemBuilder: (context, index) {
          final map = info.entries.toList()[index];
          return ListTile(
            title: Text(map.key),
            subtitle: Text(map.value),
          );
        },
        separatorBuilder: (context, _) => const Divider(),
        itemCount: info.entries.length,
      ),
    );
  }
}
