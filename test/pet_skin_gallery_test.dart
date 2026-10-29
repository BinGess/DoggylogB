import 'package:doggylog/app/theme/app_skin_theme.dart';
import 'package:doggylog/app/theme/app_theme.dart';
import 'package:doggylog/features/pets/presentation/widgets/pet_skin_gallery.dart';
import 'package:doggylog/features/pets/presentation/widgets/skin_purchase_overlay.dart';
import 'package:doggylog/features/shared/domain/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  testWidgets('PetSkinGallery reports the tapped pet id', (tester) async {
    String? selectedPetId;
    final pets = [
      PetProfile(
        id: 'pet-1',
        name: 'Mochi',
        breed: PetBreed.shiba,
        loyaltyPoints: 120,
        selectedSkinId: 'amber-shiba',
        unlockedSkinIds: const ['amber-shiba'],
        createdAt: DateTime(2025),
        isSelected: true,
      ),
      PetProfile(
        id: 'pet-2',
        name: 'Buddy',
        breed: PetBreed.beagle,
        loyaltyPoints: 240,
        selectedSkinId: 'ai-buddy',
        unlockedSkinIds: const ['ai-buddy'],
        createdAt: DateTime(2025, 2),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(skinTheme: AppSkinTheme.shibaJoy, fontScale: 1.0),
        home: Scaffold(
          body: SingleChildScrollView(
            child: PetSkinGallery(
              pets: pets,
              selectedPetId: 'pet-1',
              onPetSelected: (petId) => selectedPetId = petId,
              premiumSkinStore: const PremiumSkinStoreState(),
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('pet-skin-card-pet-1')), findsOneWidget);
    expect(find.byKey(const Key('pet-skin-card-pet-2')), findsOneWidget);

    await tester.tap(find.byKey(const Key('pet-skin-card-pet-2')));
    await tester.pumpAndSettle();

    expect(selectedPetId, 'pet-2');
    expect(find.textContaining('比格'), findsOneWidget);
  });

  testWidgets('PetSkinGallery keeps card positions fixed after selection', (
    tester,
  ) async {
    final pets = [
      PetProfile(
        id: 'pet-1',
        name: 'Mochi',
        breed: PetBreed.shiba,
        loyaltyPoints: 120,
        selectedSkinId: 'amber-shiba',
        unlockedSkinIds: const ['amber-shiba'],
        createdAt: DateTime(2025),
        isSelected: true,
      ),
      PetProfile(
        id: 'pet-2',
        name: 'Buddy',
        breed: PetBreed.beagle,
        loyaltyPoints: 240,
        selectedSkinId: 'ai-buddy',
        unlockedSkinIds: const ['ai-buddy'],
        createdAt: DateTime(2025, 2),
      ),
      PetProfile(
        id: 'pet-3',
        name: 'Luna',
        breed: PetBreed.husky,
        loyaltyPoints: 180,
        selectedSkinId: 'frost-husky',
        unlockedSkinIds: const ['frost-husky'],
        createdAt: DateTime(2025, 3),
      ),
    ];
    var selectedPetId = 'pet-1';

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(skinTheme: AppSkinTheme.shibaJoy, fontScale: 1.0),
        home: StatefulBuilder(
          builder: (context, setState) {
            return Scaffold(
              body: SingleChildScrollView(
                child: PetSkinGallery(
                  pets: pets,
                  selectedPetId: selectedPetId,
                  onPetSelected: (petId) {
                    setState(() => selectedPetId = petId);
                  },
                  premiumSkinStore: const PremiumSkinStoreState(),
                ),
              ),
            );
          },
        ),
      ),
    );

    double topFor(String petId) =>
        tester.getTopLeft(find.byKey(Key('pet-skin-card-$petId'))).dy;

    expect(topFor('pet-1'), lessThan(topFor('pet-2')));
    expect(topFor('pet-2'), lessThan(topFor('pet-3')));

    await tester.tap(find.byKey(const Key('pet-skin-card-pet-2')));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byKey(const Key('pet-skin-card-pet-2')),
        matching: find.text('现在这套'),
      ),
      findsOneWidget,
    );
    expect(topFor('pet-1'), lessThan(topFor('pet-2')));
    expect(topFor('pet-2'), lessThan(topFor('pet-3')));
  });

  testWidgets('PetSkinGallery hides the data transparent skin card', (
    tester,
  ) async {
    final pets = [
      PetProfile(
        id: 'pet-1',
        name: 'Mochi',
        breed: PetBreed.shiba,
        loyaltyPoints: 120,
        selectedSkinId: 'amber-shiba',
        unlockedSkinIds: const ['amber-shiba'],
        createdAt: DateTime(2025),
        isSelected: true,
      ),
      PetProfile(
        id: 'pet-2',
        name: 'Sunny',
        breed: PetBreed.goldenRetriever,
        loyaltyPoints: 240,
        selectedSkinId: 'golden-dawn',
        unlockedSkinIds: const ['golden-dawn'],
        createdAt: DateTime(2025, 2),
      ),
      PetProfile(
        id: 'pet-3',
        name: 'Luna',
        breed: PetBreed.husky,
        loyaltyPoints: 180,
        selectedSkinId: 'frost-husky',
        unlockedSkinIds: const ['frost-husky'],
        createdAt: DateTime(2025, 3),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(skinTheme: AppSkinTheme.shibaJoy, fontScale: 1.0),
        home: Scaffold(
          body: SingleChildScrollView(
            child: PetSkinGallery(
              pets: pets,
              selectedPetId: 'pet-1',
              onPetSelected: (_) {},
              premiumSkinStore: const PremiumSkinStoreState(),
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('pet-skin-card-pet-2')), findsNothing);
    expect(find.text('Sunny'), findsNothing);
    expect(find.text('数据透明'), findsNothing);
    expect(find.byKey(const Key('pet-skin-card-pet-1')), findsOneWidget);
    expect(find.byKey(const Key('pet-skin-card-pet-3')), findsOneWidget);
  });

  testWidgets('PetSkinGallery does not show skin description copy', (
    tester,
  ) async {
    final pets = [
      PetProfile(
        id: 'pet-1',
        name: 'Mochi',
        breed: PetBreed.shiba,
        loyaltyPoints: 120,
        selectedSkinId: 'amber-shiba',
        unlockedSkinIds: const ['amber-shiba'],
        createdAt: DateTime(2025),
        isSelected: true,
      ),
      PetProfile(
        id: 'pet-2',
        name: 'Buddy',
        breed: PetBreed.beagle,
        loyaltyPoints: 240,
        selectedSkinId: 'ai-buddy',
        unlockedSkinIds: const ['ai-buddy'],
        createdAt: DateTime(2025, 2),
      ),
      PetProfile(
        id: 'pet-3',
        name: 'Luna',
        breed: PetBreed.husky,
        loyaltyPoints: 180,
        selectedSkinId: 'frost-husky',
        unlockedSkinIds: const ['frost-husky'],
        createdAt: DateTime(2025, 3),
      ),
      PetProfile(
        id: 'pet-4',
        name: 'Maru',
        breed: PetBreed.samoyed,
        loyaltyPoints: 220,
        selectedSkinId: 'cloud-samoyed',
        unlockedSkinIds: const ['cloud-samoyed'],
        createdAt: DateTime(2025, 4),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(skinTheme: AppSkinTheme.shibaJoy, fontScale: 1.0),
        home: Scaffold(
          body: SingleChildScrollView(
            child: PetSkinGallery(
              pets: pets,
              selectedPetId: 'pet-1',
              onPetSelected: (_) {},
              premiumSkinStore: const PremiumSkinStoreState(),
            ),
          ),
        ),
      ),
    );

    expect(find.text('偏暖、轻快、像课堂便签一样清晰。'), findsNothing);
    expect(find.text('偏科技感的蓝紫层次，适合持续对话和记录。'), findsNothing);
    expect(find.text('通透而轻盈，适合健康与日常维护。'), findsNothing);
    expect(find.text('更柔软的粉白色调，适合陪伴与纪念。'), findsNothing);
  });

  testWidgets('PetSkinGallery shows purchase CTA for locked premium skins', (
    tester,
  ) async {
    String? tappedPetId;
    final pets = [
      PetProfile(
        id: 'pet-1',
        name: 'Mochi',
        breed: PetBreed.shiba,
        loyaltyPoints: 120,
        selectedSkinId: 'amber-shiba',
        unlockedSkinIds: const ['amber-shiba'],
        createdAt: DateTime(2025),
        isSelected: true,
      ),
      PetProfile(
        id: 'pet-3',
        name: 'Luna',
        breed: PetBreed.husky,
        loyaltyPoints: 180,
        selectedSkinId: 'frost-husky',
        unlockedSkinIds: const ['frost-husky'],
        createdAt: DateTime(2025, 3),
      ),
      PetProfile(
        id: 'pet-4',
        name: 'Maru',
        breed: PetBreed.samoyed,
        loyaltyPoints: 220,
        selectedSkinId: 'cloud-samoyed',
        unlockedSkinIds: const ['cloud-samoyed'],
        createdAt: DateTime(2025, 4),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(skinTheme: AppSkinTheme.shibaJoy, fontScale: 1.0),
        home: Scaffold(
          body: SingleChildScrollView(
            child: PetSkinGallery(
              pets: pets,
              selectedPetId: 'pet-1',
              onPetSelected: (petId) => tappedPetId = petId,
              premiumSkinStore: const PremiumSkinStoreState(
                didLoad: true,
                storeAvailable: true,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('¥3 解锁'), findsNWidgets(2));

    await tester.tap(find.text('¥3 解锁').first);
    await tester.pumpAndSettle();

    expect(tappedPetId, 'pet-3');
  });

  testWidgets(
    'PetSkinGallery keeps cards compact and disabled during purchase',
    (tester) async {
      final pets = [
        PetProfile(
          id: 'pet-1',
          name: 'Mochi',
          breed: PetBreed.shiba,
          loyaltyPoints: 120,
          selectedSkinId: 'amber-shiba',
          unlockedSkinIds: const ['amber-shiba'],
          createdAt: DateTime(2025),
          isSelected: true,
        ),
        PetProfile(
          id: 'pet-3',
          name: 'Luna',
          breed: PetBreed.husky,
          loyaltyPoints: 180,
          selectedSkinId: 'frost-husky',
          unlockedSkinIds: const ['frost-husky'],
          createdAt: DateTime(2025, 3),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(
            skinTheme: AppSkinTheme.shibaJoy,
            fontScale: 1.0,
          ),
          home: Scaffold(
            body: SingleChildScrollView(
              child: PetSkinGallery(
                pets: pets,
                selectedPetId: 'pet-1',
                onPetSelected: (_) {},
                premiumSkinStore: const PremiumSkinStoreState(
                  didLoad: true,
                  storeAvailable: true,
                  purchasePendingProductId: 'doggylog.skin.soft_wellness',
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('正在打开购买确认'), findsNothing);
      expect(find.text('系统弹窗出现前请稍等一下'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('¥3 解锁'), findsOneWidget);
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
      for (final pet in pets) {
        expect(
          tester
              .widget<InkWell>(find.byKey(Key('pet-skin-card-${pet.id}')))
              .onTap,
          isNull,
        );
      }
    },
  );

  testWidgets(
    'purchase overlay is centered, blocks taps and clears with state',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var taps = 0;
      Future<void> pumpOverlay(bool pending) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light(
              skinTheme: AppSkinTheme.shibaJoy,
              fontScale: 1.0,
            ),
            home: SkinPurchaseOverlay(
              isPurchasing: pending,
              child: Scaffold(
                appBar: AppBar(
                  title: const Text('换装'),
                  actions: [
                    IconButton(
                      key: const Key('background-action'),
                      onPressed: () => taps++,
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
                body: const SizedBox.expand(),
              ),
            ),
          ),
        );
        await tester.pump();
      }

      await pumpOverlay(true);
      final dialog = find.byKey(const Key('skin-purchase-dialog'));
      expect(dialog, findsOneWidget);
      expect(find.text('正在打开购买确认'), findsOneWidget);
      expect(find.text('系统弹窗出现前请稍等一下'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(
        tester.getCenter(dialog).dy,
        closeTo(
          tester.view.physicalSize.height / tester.view.devicePixelRatio / 2,
          1,
        ),
      );
      await tester.tapAt(
        tester.getCenter(find.byKey(const Key('background-action'))),
      );
      await tester.pump();
      expect(taps, 0);
      expect(dialog, findsOneWidget);

      await pumpOverlay(false);
      expect(dialog, findsNothing);
      expect(find.byKey(const Key('skin-purchase-barrier')), findsNothing);
      await tester.tap(find.byKey(const Key('background-action')));
      expect(taps, 1);
    },
  );
}
