import 'package:doggylog/features/shared/application/doggylog_providers.dart';
import 'package:doggylog/features/shared/domain/models.dart';
import 'package:doggylog/features/shared/presentation/widgets/liquid_glass_card.dart';
import 'package:doggylog/features/shared/presentation/widgets/soft_backdrop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = TextEditingController(text: 'Mochi');
  PetBreed _selected = PetBreed.shiba;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SoftBackdrop(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                Text('汪汪日历', style: theme.textTheme.displayMedium),
                const SizedBox(height: 12),
                Text(
                  '把日程、倒计时和宠物陪伴整合进一个更柔和、更有呼吸感的日历产品。',
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 28),
                LiquidGlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('选择你的初始陪伴宠物', style: theme.textTheme.titleLarge),
                      const SizedBox(height: 10),
                      Text(
                        'Soft UI 风格会贯穿后续首页、倒计时和复盘页。',
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 18),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: PetBreed.values.map((breed) {
                          final selected = breed == _selected;
                          return ChoiceChip(
                            label: Text(_breedLabel(breed)),
                            selected: selected,
                            onSelected: (_) =>
                                setState(() => _selected = breed),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 18),
                      TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          labelText: '宠物昵称',
                          hintText: '例如 Mochi / Cocoa / Lucky',
                        ),
                      ),
                      const SizedBox(height: 18),
                      FilledButton(
                        onPressed: () async {
                          await ref
                              .read(appStateProvider.notifier)
                              .completeOnboarding(
                                _selected,
                                _controller.text.trim(),
                              );
                        },
                        child: const Text('进入 DoggyLog'),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _breedLabel(PetBreed breed) {
    return switch (breed) {
      PetBreed.shiba => '柴犬',
      PetBreed.goldenRetriever => '金毛',
      PetBreed.beagle => '比格',
      PetBreed.husky => '哈士奇',
    };
  }
}
