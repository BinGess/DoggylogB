import 'package:doggylog/features/shared/application/doggylog_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest_all.dart' as tz;

Future<ProviderContainer> bootstrap() async {
  tz.initializeTimeZones();
  await initializeDateFormatting('zh_CN');
  await initializeDateFormatting('en_US');
  await initializeDateFormatting('ja_JP');
  final container = ProviderContainer();
  await container.read(appBootstrapProvider.future);
  return container;
}
