import 'package:doggylog/app/theme/app_skin_theme.dart';
import 'package:doggylog/app/theme/app_theme.dart';
import 'package:doggylog/features/pets/presentation/widgets/pet_skin_gallery.dart';
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
            ),
          ),
        ),
      ),
    );

    expect(find.text('Mochi'), findsOneWidget);
    expect(find.text('Buddy'), findsOneWidget);

    await tester.tap(find.byKey(const Key('pet-skin-card-pet-2')));
    await tester.pumpAndSettle();

    expect(selectedPetId, 'pet-2');
    expect(find.textContaining('Beagle'), findsOneWidget);
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
        matching: find.text('当前皮肤'),
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
}
