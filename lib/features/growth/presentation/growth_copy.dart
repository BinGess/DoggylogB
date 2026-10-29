import 'package:doggylog/app/localization/app_localizations.dart';
import 'package:flutter/widgets.dart';

String growthText(BuildContext context, String zh, String en, String ja) {
  final l = context.l10n;
  return l.isEnglish
      ? en
      : l.isJapanese
      ? ja
      : zh;
}

String badgeName(BuildContext context, String id) {
  final names = <String, List<String>>{
    'lv1': ['第一根骨头', 'First Bone', 'はじめての骨'],
    'lv3': ['认真陪跑员', 'Devoted Companion', 'まじめな伴走者'],
    'lv5': ['习惯搭子', 'Habit Buddy', '習慣の相棒'],
    'lv7': ['默契伙伴', 'In Sync', '息ぴったりの仲間'],
    'lv10': ['亲密家人', 'Close Family', '大切な家族'],
    's3': ['三日小坚持', 'Three-Day Streak', '3日間の積み重ね'],
    's7': ['一周陪伴', 'A Week Together', '1週間の寄り添い'],
  };
  final n = names[id]!;
  return growthText(context, n[0], n[1], n[2]);
}

String signedXp(int value) => '${value > 0 ? '+' : ''}$value';

String growthReason(BuildContext context, String reason) => switch (reason) {
  'undo' => growthText(context, '取消完成', 'Undo completion', '完了取消'),
  'delete' => growthText(context, '删除', 'Deletion', '削除'),
  _ => growthText(context, '完成', 'Completion', '完了'),
};
