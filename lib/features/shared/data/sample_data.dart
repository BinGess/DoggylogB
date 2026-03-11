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
    title: '遛弯 30 分钟',
    category: CalendarCategory.pet,
    durationMinutes: 30,
  ),
  const TaskTemplate(
    id: 'feed',
    title: '喂食提醒',
    category: CalendarCategory.pet,
    durationMinutes: 10,
  ),
  const TaskTemplate(
    id: 'grooming',
    title: '洗护预约',
    category: CalendarCategory.pet,
    durationMinutes: 60,
  ),
  const TaskTemplate(
    id: 'focus',
    title: '深度工作块',
    category: CalendarCategory.work,
    durationMinutes: 90,
  ),
];

final defaultSkins = <PetBreed, List<PetSkin>>{
  PetBreed.shiba: const [
    PetSkin(
      id: 'amber-shiba',
      name: '暖棕琥珀',
      visualTag: 'amber',
      unlockLevel: 1,
    ),
    PetSkin(
      id: 'sunrise-shiba',
      name: '朝霞琉璃',
      visualTag: 'sunrise',
      unlockLevel: 3,
    ),
  ],
  PetBreed.goldenRetriever: const [
    PetSkin(
      id: 'golden-dawn',
      name: '暖金琉璃',
      visualTag: 'golden',
      unlockLevel: 1,
    ),
    PetSkin(id: 'honey-wave', name: '蜂蜜波纹', visualTag: 'honey', unlockLevel: 4),
  ],
  PetBreed.beagle: const [
    PetSkin(id: 'milk-jelly', name: '奶白果冻', visualTag: 'milk', unlockLevel: 1),
    PetSkin(id: 'mint-jelly', name: '薄荷果冻', visualTag: 'mint', unlockLevel: 4),
  ],
  PetBreed.husky: const [
    PetSkin(id: 'ice-crystal', name: '冰晶液态', visualTag: 'ice', unlockLevel: 1),
    PetSkin(
      id: 'aurora-husky',
      name: '极光冰层',
      visualTag: 'aurora',
      unlockLevel: 5,
    ),
  ],
};

const defaultPetCompanions = <DefaultPetCompanion>[
  DefaultPetCompanion(name: 'Mochi', breed: PetBreed.shiba, loyaltyPoints: 120),
  DefaultPetCompanion(
    name: 'Butters',
    breed: PetBreed.goldenRetriever,
    loyaltyPoints: 180,
  ),
  DefaultPetCompanion(
    name: 'Bagel',
    breed: PetBreed.beagle,
    loyaltyPoints: 150,
  ),
  DefaultPetCompanion(name: 'Skye', breed: PetBreed.husky, loyaltyPoints: 220),
];

List<GeofencePlace> defaultGeofences() => const [
  GeofencePlace(
    id: 'home',
    name: '家',
    latitude: 31.2304,
    longitude: 121.4737,
    radiusMeters: 180,
    sceneMode: SceneMode.resting,
  ),
  GeofencePlace(
    id: 'office',
    name: '办公地点',
    latitude: 31.2243,
    longitude: 121.4767,
    radiusMeters: 240,
    sceneMode: SceneMode.working,
  ),
  GeofencePlace(
    id: 'park',
    name: '公园',
    latitude: 31.2333,
    longitude: 121.4622,
    radiusMeters: 150,
    sceneMode: SceneMode.walking,
  ),
];
