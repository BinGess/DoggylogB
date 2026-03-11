import 'package:doggylog/app/localization/app_localizations.dart';
import 'package:doggylog/app/theme/app_skin_theme.dart';
import 'package:doggylog/features/pets/presentation/widgets/pet_skin_gallery.dart';
import 'package:doggylog/features/shared/application/doggylog_providers.dart';
import 'package:doggylog/features/shared/domain/models.dart';
import 'package:doggylog/features/shared/presentation/widgets/liquid_glass_card.dart';
import 'package:doggylog/features/shared/presentation/widgets/soft_backdrop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PetsScreen extends ConsumerWidget {
  const PetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateProvider);
    final controller = ref.read(appStateProvider.notifier);
    final activePet = state.selectedPet;
    final isHiddenActiveSkin =
        activePet != null && !isPetSkinVisibleInManagement(activePet.breed);
    final activeSkin = appSkinThemeForBreed(
      activePet?.breed ?? PetBreed.shiba,
    ).spec;
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.managePetSkins)),
      body: SoftBackdrop(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            LiquidGlassCard(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(
                    context,
                  ).colorScheme.secondary.withValues(alpha: 0.18),
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                  Theme.of(context).colorScheme.surface.withValues(alpha: 0.88),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.currentSkin,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    activePet == null
                        ? l10n.noPetSelected
                        : isHiddenActiveSkin
                        ? '${activePet.name} · ${l10n.breedLabel(activePet.breed)} · ${l10n.currentHidden}'
                        : '${activePet.name} · ${l10n.breedLabel(activePet.breed)} · ${l10n.localizedSkinStyleName(activeSkin.styleName)}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  // Text(
                  // activePet == null
                  // ? '进入下面的卡片后选择任意宠物，即可切换整套 App 视觉皮肤。'
                  //   : '切换宠物会同步切换按钮、文字、卡片、导航和背景风格，不再单独做设置页联动。',
                  //style: Theme.of(context).textTheme.bodyMedium,
                  //),
                ],
              ),
            ),
            const SizedBox(height: 16),
            PetSkinGallery(
              pets: state.pets,
              selectedPetId: activePet?.id,
              onPetSelected: controller.selectPet,
            ),
          ],
        ),
      ),
    );
  }
}
