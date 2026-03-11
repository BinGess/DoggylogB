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
        name: 'Sunny',
        breed: PetBreed.goldenRetriever,
        loyaltyPoints: 240,
        selectedSkinId: 'golden-dawn',
        unlockedSkinIds: const ['golden-dawn'],
        createdAt: DateTime(2025, 2),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(skinTheme: AppSkinTheme.shibaJoy, fontScale: 1.0),
        home: Scaffold(
          body: PetSkinGallery(
            pets: pets,
            selectedPetId: 'pet-1',
            onPetSelected: (petId) => selectedPetId = petId,
          ),
        ),
      ),
    );

    expect(find.text('Mochi'), findsOneWidget);
    expect(find.text('Sunny'), findsOneWidget);

    await tester.tap(find.byKey(const Key('pet-skin-card-pet-2')));
    await tester.pumpAndSettle();

    expect(selectedPetId, 'pet-2');
    expect(find.textContaining('Golden Retriever'), findsOneWidget);
  });
}
