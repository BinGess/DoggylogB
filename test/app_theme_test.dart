import 'package:doggylog/app/theme/app_theme.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  test('AppTheme increases text sizes when font scale grows', () {
    final small = AppTheme.light(fontScale: 1.0);
    final large = AppTheme.light(fontScale: 1.2);

    expect(
      large.textTheme.bodyMedium!.fontSize!,
      greaterThan(small.textTheme.bodyMedium!.fontSize!),
    );
    expect(
      large.textTheme.titleLarge!.fontSize!,
      greaterThan(small.textTheme.titleLarge!.fontSize!),
    );
  });
}
