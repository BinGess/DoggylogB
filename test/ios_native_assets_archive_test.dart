import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('iOS project keeps native-asset archive protection scripts', () {
    final project = File('ios/Runner.xcodeproj/project.pbxproj').readAsStringSync();

    expect(project, contains('[Codex] Clean iOS Native Assets'));
    expect(project, contains(r'rm -rf \"${BUILD_NATIVE_ASSETS_DIR}\"'));
    expect(
      project,
      contains(
        r'find \"${FLUTTER_BUILD_STATE_DIR}\" \\( -name native_assets.json -o -name install_code_assets.d \\) -delete',
      ),
    );

    expect(project, contains('[Codex] Generate Missing Framework dSYMs'));
    expect(project, contains(r'dsymutil \"${BINARY_PATH}\" -o \"${DSYM_PATH}\"'));
    expect(project, contains(r'NATIVE_ASSETS_DIR=\"${APP_PATH}/build/native_assets/ios\"'));
    expect(
      project,
      contains(r'FRAMEWORKS_DIR=\"${TARGET_BUILD_DIR}/${WRAPPER_NAME}/Frameworks\"'),
    );
  });
}
