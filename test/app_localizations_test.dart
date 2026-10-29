import 'package:doggylog/app/localization/app_localizations.dart';
import 'package:doggylog/app/theme/app_skin_theme.dart';
import 'package:doggylog/features/shared/domain/models.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en_US');
    await initializeDateFormatting('ja_JP');
  });

  test('English localization uses softer playful copy for key surfaces', () {
    final l10n = AppLocalizations.fromLocale(const Locale('en'));

    expect(
      l10n.countdownSubtitle,
      'A tiny sparkly list for the days you cannot wait for.',
    );
    expect(l10n.nextImportantMilestone, 'Coming up next');
    expect(
      l10n.noCountdownYet,
      'No countdowns yet. Add a day worth looking forward to.',
    );
    expect(l10n.managePetSkins, 'Dress up your pup');
    expect(l10n.currentSkinBadge, 'Wearing now');
    expect(l10n.tapToSwitchSkin, 'Tap to change');
    expect(l10n.minutesBefore(15), '15 min early');
    expect(l10n.breedLabel(PetBreed.shiba), 'Shiba Inu');
    expect(l10n.shortDate(DateTime(2026, 3, 8)), 'Mar 8');
  });

  test('Japanese localization uses softer playful copy for key surfaces', () {
    final l10n = AppLocalizations.fromLocale(const Locale('ja'));

    expect(l10n.countdownSubtitle, '楽しみな日を、きらっと並べておけます。');
    expect(l10n.nextImportantMilestone, 'いちばん近い楽しみ');
    expect(l10n.noCountdownYet, 'まだカウントダウンはありません。楽しみな日をひとつ入れてみましょう。');
    expect(l10n.managePetSkins, 'わんこをお着替え');
    expect(l10n.currentSkinBadge, 'いまはこれ');
    expect(l10n.tapToSwitchSkin, 'タップで着替える');
    expect(l10n.minutesBefore(15), '15分前にお知らせ');
    expect(l10n.breedLabel(PetBreed.shiba), '柴犬');
    expect(l10n.shortDate(DateTime(2026, 3, 8)), '3月8日');
  });

  test(
    'new premium skins and purchase fallback are localized in every language',
    () {
      final expectations = <String, List<String>>{
        'zh': ['林间手账', '可可剧场', '黑白漫游'],
        'en': ['Forest Journal', 'Cocoa Theater', 'Monochrome Stroll'],
        'ja': ['森の手帳', 'ココアシアター', 'モノクロさんぽ'],
      };
      for (final entry in expectations.entries) {
        final l10n = AppLocalizations.fromLocale(Locale(entry.key));
        for (var i = 0; i < entry.value.length; i++) {
          final name = ['林间手账', '可可剧场', '黑白漫游'][i];
          expect(l10n.localizedSkinStyleName(name), entry.value[i]);
          expect(
            l10n.localizedSkinDescription(
              [
                AppSkinTheme.collieGarden,
                AppSkinTheme.dachshundCocoa,
                AppSkinTheme.dalmatianInk,
              ][i].spec,
            ),
            isNotEmpty,
          );
        }
        expect(
          l10n.messagePremiumSkinRequiresPurchase,
          isNot(contains('3 / 4')),
        );
      }
    },
  );
}
