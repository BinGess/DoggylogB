import 'package:doggylog/app/localization/app_localizations.dart';
import 'package:doggylog/features/shared/domain/models.dart';

class DefaultPetCompanion {
  const DefaultPetCompanion({
    required this.name,
    required this.breed,
    required this.loyaltyPoints,
  });

  final String name;
  final PetBreed breed;
  final int loyaltyPoints;
}

final defaultTemplates = <TaskTemplate>[
  const TaskTemplate(
    id: 'walk-30',
    title: SeedCopyKey.templateWalk30Title,
    category: CalendarCategory.pet,
    durationMinutes: 30,
  ),
  const TaskTemplate(
    id: 'feed',
    title: SeedCopyKey.templateFeedTitle,
    category: CalendarCategory.pet,
    durationMinutes: 10,
  ),
  const TaskTemplate(
    id: 'grooming',
    title: SeedCopyKey.templateGroomingTitle,
    category: CalendarCategory.pet,
    durationMinutes: 60,
  ),
  const TaskTemplate(
    id: 'focus',
    title: SeedCopyKey.templateFocusTitle,
    category: CalendarCategory.work,
    durationMinutes: 90,
  ),
];

final defaultSkins = <PetBreed, List<PetSkin>>{
  PetBreed.shiba: const [
    PetSkin(
      id: 'amber-shiba',
      name: SeedCopyKey.skinAmberShibaName,
      visualTag: 'amber',
      unlockLevel: 1,
    ),
    PetSkin(
      id: 'sunrise-shiba',
      name: SeedCopyKey.skinSunriseShibaName,
      visualTag: 'sunrise',
      unlockLevel: 3,
    ),
  ],
  PetBreed.goldenRetriever: const [
    PetSkin(
      id: 'golden-dawn',
      name: SeedCopyKey.skinGoldenDawnName,
      visualTag: 'golden',
      unlockLevel: 1,
    ),
    PetSkin(
      id: 'honey-wave',
      name: SeedCopyKey.skinHoneyWaveName,
      visualTag: 'honey',
      unlockLevel: 4,
    ),
  ],
  PetBreed.beagle: const [
    PetSkin(
      id: 'milk-jelly',
      name: SeedCopyKey.skinMilkJellyName,
      visualTag: 'milk',
      unlockLevel: 1,
    ),
    PetSkin(
      id: 'mint-jelly',
      name: SeedCopyKey.skinMintJellyName,
      visualTag: 'mint',
      unlockLevel: 4,
    ),
  ],
  PetBreed.husky: const [
    PetSkin(
      id: 'ice-crystal',
      name: SeedCopyKey.skinIceCrystalName,
      visualTag: 'ice',
      unlockLevel: 1,
    ),
    PetSkin(
      id: 'aurora-husky',
      name: SeedCopyKey.skinAuroraHuskyName,
      visualTag: 'aurora',
      unlockLevel: 5,
    ),
  ],
  PetBreed.samoyed: const [
    PetSkin(
      id: 'cloud-white',
      name: SeedCopyKey.skinCloudWhiteName,
      visualTag: 'cloud',
      unlockLevel: 1,
    ),
    PetSkin(
      id: 'rose-bloom',
      name: SeedCopyKey.skinRoseBloomName,
      visualTag: 'rose',
      unlockLevel: 3,
    ),
  ],
};

const defaultPetCompanions = <DefaultPetCompanion>[
  DefaultPetCompanion(
    name: SeedCopyKey.petMochiName,
    breed: PetBreed.shiba,
    loyaltyPoints: 120,
  ),
  DefaultPetCompanion(
    name: SeedCopyKey.petButtersName,
    breed: PetBreed.goldenRetriever,
    loyaltyPoints: 180,
  ),
  DefaultPetCompanion(
    name: SeedCopyKey.petBagelName,
    breed: PetBreed.beagle,
    loyaltyPoints: 150,
  ),
  DefaultPetCompanion(
    name: SeedCopyKey.petSkyeName,
    breed: PetBreed.husky,
    loyaltyPoints: 220,
  ),
  DefaultPetCompanion(
    name: SeedCopyKey.petLunaName,
    breed: PetBreed.samoyed,
    loyaltyPoints: 160,
  ),
];

List<GeofencePlace> defaultGeofences() => const [
  GeofencePlace(
    id: 'home',
    name: SeedCopyKey.geofenceHomeName,
    latitude: 31.2304,
    longitude: 121.4737,
    radiusMeters: 180,
    sceneMode: SceneMode.resting,
  ),
  GeofencePlace(
    id: 'office',
    name: SeedCopyKey.geofenceOfficeName,
    latitude: 31.2243,
    longitude: 121.4767,
    radiusMeters: 240,
    sceneMode: SceneMode.working,
  ),
  GeofencePlace(
    id: 'park',
    name: SeedCopyKey.geofenceParkName,
    latitude: 31.2333,
    longitude: 121.4622,
    radiusMeters: 150,
    sceneMode: SceneMode.walking,
  ),
];
