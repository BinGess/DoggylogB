import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('iOS privacy usage descriptions include required location strings', () {
    final infoPlist = File('ios/Runner/Info.plist').readAsStringSync();
    expect(infoPlist, contains('NSLocationWhenInUseUsageDescription'));
    expect(infoPlist, contains('NSLocationAlwaysAndWhenInUseUsageDescription'));

    for (final path in const [
      'ios/Runner/en.lproj/InfoPlist.strings',
      'ios/Runner/ja.lproj/InfoPlist.strings',
      'ios/Runner/zh-Hans.lproj/InfoPlist.strings',
    ]) {
      final localizedStrings = File(path).readAsStringSync();
      expect(
        localizedStrings,
        contains('NSLocationWhenInUseUsageDescription'),
        reason: 'Missing when-in-use location copy in $path',
      );
      expect(
        localizedStrings,
        contains('NSLocationAlwaysAndWhenInUseUsageDescription'),
        reason: 'Missing always location copy in $path',
      );
    }
  });
}
