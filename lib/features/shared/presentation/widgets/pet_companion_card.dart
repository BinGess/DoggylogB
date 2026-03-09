import 'package:doggylog/features/shared/presentation/widgets/animated_pet_avatar.dart';
import 'package:doggylog/features/shared/domain/models.dart';
import 'package:doggylog/features/shared/presentation/widgets/liquid_glass_card.dart';
import 'package:flutter/material.dart';

class PetCompanionCard extends StatelessWidget {
  const PetCompanionCard({
    super.key,
    required this.pet,
    required this.mood,
    required this.sceneMode,
    required this.onLongPress,
  });

  final PetProfile? pet;
  final PetMood mood;
  final SceneMode sceneMode;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final pet = this.pet;
    return GestureDetector(
      onLongPress: onLongPress,
      child: LiquidGlassCard(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primary.withValues(alpha: 0.30),
            scheme.secondary.withValues(alpha: 0.16),
            Colors.white.withValues(alpha: 0.10),
          ],
        ),
        child: Row(
          children: [
            AnimatedPetAvatar(
              breed: pet?.breed ?? PetBreed.shiba,
              mood: mood,
              sceneMode: sceneMode,
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pet == null ? 'Pick your first pup' : '${pet.name} 今天陪你冲刺',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _moodCopy(mood, sceneMode),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _TinyPill(
                        label: pet == null ? '未选择宠物' : 'Lv.${pet.loyaltyLevel}',
                        icon: Icons.star_rounded,
                      ),
                      _TinyPill(
                        label: _sceneLabel(sceneMode),
                        icon: Icons.location_on_rounded,
                      ),
                      const _TinyPill(
                        label: '长按试试 Fetch',
                        icon: Icons.sports_baseball_rounded,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _sceneLabel(SceneMode mode) {
    return switch (mode) {
      SceneMode.home => '居家',
      SceneMode.working => '工作中',
      SceneMode.walking => '遛弯模式',
      SceneMode.resting => '休息中',
      SceneMode.caring => '守护中',
    };
  }

  static String _moodCopy(PetMood mood, SceneMode sceneMode) {
    if (sceneMode == SceneMode.walking) {
      return 'Mochi 已切换到遛弯姿态，随时准备提醒你按时出门。';
    }
    return switch (mood) {
      PetMood.excited => '今日任务推进顺利，宠物会在完成关键待办时给你奖励反馈。',
      PetMood.calm => '节奏稳定，保持今天的完成率就能继续解锁隐藏动作。',
      PetMood.lazy => '还有待办没推进，长按宠物直接拖球到日期上创建任务。',
      PetMood.sad => '存在逾期任务，优先清掉积压项让宠物恢复精神。',
    };
  }
}

class _TinyPill extends StatelessWidget {
  const _TinyPill({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 16), const SizedBox(width: 6), Text(label)],
      ),
    );
  }
}
