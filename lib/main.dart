import 'package:doggylog/app/app.dart';
import 'package:doggylog/core/bootstrap.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final container = await bootstrap();
  runApp(
    UncontrolledProviderScope(container: container, child: const DoggyLogApp()),
  );
}
