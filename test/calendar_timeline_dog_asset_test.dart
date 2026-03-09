import 'package:doggylog/features/calendar/presentation/calendar_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('calendar timeline dog animation asset paths stay stable', () {
    expect(
      calendarTimelineDogGifAsset,
      'assets/images/calendar/calendar_dog_timeline.gif',
    );
    expect(
      calendarTimelineDogFallbackAsset,
      'assets/images/calendar/calendar_dog_timeline.png',
    );
  });
}
