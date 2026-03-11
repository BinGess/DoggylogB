import 'dart:ui';

import 'package:doggylog/app/theme/app_skin_theme.dart';
import 'package:doggylog/features/shared/domain/models.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Locale resolveAppLocale(
  AppLanguageMode mode, {
  Locale? systemLocale,
}) {
  final locale = systemLocale ?? PlatformDispatcher.instance.locale;
  return switch (mode) {
    AppLanguageMode.system => _supportedLocale(locale),
    AppLanguageMode.zh => const Locale('zh'),
    AppLanguageMode.en => const Locale('en'),
    AppLanguageMode.ja => const Locale('ja'),
  };
}

void syncGlobalLocale(AppLanguageMode mode) {
  Intl.defaultLocale = AppLocalizations
      .fromLocale(resolveAppLocale(mode))
      .localeName;
}

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = [
    Locale('zh'),
    Locale('en'),
    Locale('ja'),
  ];

  static const delegate = _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations.fromLocale(const Locale('zh'));
  }

  static AppLocalizations current({AppLanguageMode? mode}) {
    if (mode != null) {
      return AppLocalizations.fromLocale(resolveAppLocale(mode));
    }
    final currentLocale = Intl.getCurrentLocale();
    if (currentLocale.isNotEmpty) {
      return AppLocalizations.fromLocale(Locale(currentLocale.split('_').first));
    }
    return AppLocalizations.fromLocale(const Locale('zh'));
  }

  static AppLocalizations fromLocale(Locale locale) {
    return AppLocalizations(_supportedLocale(locale));
  }

  String get localeName => switch (languageCode) {
    'en' => 'en_US',
    'ja' => 'ja_JP',
    _ => 'zh_CN',
  };

  String get languageCode => locale.languageCode;
  bool get isEnglish => languageCode == 'en';
  bool get isJapanese => languageCode == 'ja';
  bool get isChinese => !isEnglish && !isJapanese;

  String get appTitle => 'DoggyLog';
  String get unlockSheetTitle => _t('DoggyLog 已锁定', 'DoggyLog is Locked', 'DoggyLogはロックされています');
  String get unlockSheetSubtitle => _t('使用 Face ID / Touch ID 恢复访问。', 'Use Face ID / Touch ID to unlock access.', 'Face ID / Touch ID でロックを解除してください。');
  String get unlockNow => _t('立即解锁', 'Unlock now', '今すぐロック解除');
  String get biometricReason => _t('使用 Face ID / Touch ID 解锁 DoggyLog', 'Use Face ID / Touch ID to unlock DoggyLog', 'Face ID / Touch ID で DoggyLog のロックを解除します');

  String get homeTabCountdown => _t('倒计时', 'Countdowns', 'カウントダウン');
  String get homeTabCalendar => _t('日历', 'Calendar', 'カレンダー');
  String get homeTabSettings => _t('我的', 'Me', 'マイ');

  String get settingsHeaderTitle => _t('我的', 'Me', 'マイ');
  String get petsSectionTitle => _t('宠物', 'Pets', 'ペット');
  String get managePetSkins => _t('管理宠物皮肤', 'Manage pet skins', 'ペットスキン管理');
  String get settingsSectionTitle => _t('设置', 'Settings', '設定');
  String get weekStartsOnMonday => _t('周一作为起始日', 'Start week on Monday', '週の開始を月曜日にする');
  String get hapticsFeedback => _t('震动反馈', 'Haptic feedback', '触覚フィードバック');
  String get systemCalendar => _t('系统日历', 'System calendars', 'システムカレンダー');
  String get language => _t('语言', 'Language', '言語');
  String get fontSize => _t('字号', 'Text size', '文字サイズ');
  String get fontSizeSubtitle => _t('切换小、中、大三档全局字体大小', 'Switch global text size between small, medium, and large.', 'アプリ全体の文字サイズを小・中・大で切り替えます。');
  String get developmentDebug => _t('开发调试', 'Developer debug', '開発デバッグ');
  String get developmentDebugSubtitle => _t('动画强度、提醒调试与 iOS 增强能力', 'Animation tuning, reminder preview, and iOS integrations.', 'アニメーション強度、通知デバッグ、iOS 拡張機能を調整します。');
  String get allCalendars => _t('全部日历', 'All calendars', 'すべてのカレンダー');
  String get allCalendarsSubtitle => _t('默认会自动纳入新出现的系统日历', 'New system calendars are included automatically by default.', '新しいシステムカレンダーは既定で自動的に含まれます。');
  String get readOnlyCalendar => _t('只读日历', 'Read-only calendar', '読み取り専用カレンダー');
  String get done => _t('完成', 'Done', '完了');
  String get reload => _t('重新加载', 'Reload', '再読み込み');
  String get emptySystemCalendarsTitle => _t('未读取到系统日历', 'No system calendars found', 'システムカレンダーが見つかりません');
  String get emptySystemCalendarsSubtitle => _t('请确认已授予日历权限，或当前设备确实存在可访问的日历。', 'Check calendar permission or confirm that the device has accessible calendars.', 'カレンダー権限、またはアクセス可能なカレンダーが存在するか確認してください。');
  String get systemCalendarGuide => _t('勾选后纳入 DoggyLog 展示与增量同步范围。', 'Selected calendars will be shown in DoggyLog and included in incremental sync.', '選択したカレンダーが DoggyLog の表示対象と差分同期対象になります。');
  String get animationIntensity => _t('动画强度', 'Animation intensity', 'アニメーション強度');
  String get animationIntensitySubtitle => _t('保留柔和动效，但给低性能设备留出缓冲。', 'Keep the soft motion, while leaving headroom for lower-end devices.', '柔らかな動きは保ちつつ、低性能端末でも余裕を持たせます。');
  String get renderTier => _t('渲染档位', 'Render tier', '描画モード');
  String get reminderDebugMode => _t('提醒调试模式', 'Reminder preview mode', '通知デバッグモード');
  String get reminderDebugModeSubtitle => _t('保存带提醒的任务后，立即触发一次 App 内提醒预览', 'Trigger an in-app reminder preview immediately after saving a task with reminders.', '通知付きタスク保存後にアプリ内プレビューをすぐ発火します。');
  String get iosCapabilities => _t('iOS 增强能力', 'iOS capabilities', 'iOS 拡張機能');
  String get eventKitSync => _t('EventKit 同步', 'EventKit sync', 'EventKit 同期');
  String get eventKitGranted => _t('日历已可访问，可导入系统事件并回写 DoggyLog 任务', 'Calendar access is available. System events can be imported and DoggyLog tasks can be written back.', 'カレンダーにアクセス可能です。システムイベントの取り込みと DoggyLog タスクの書き戻しができます。');
  String get calendarPermissionDenied => _t('尚未授予日历权限', 'Calendar permission not granted', 'カレンダー権限が未許可です');
  String get importSystemCalendar => _t('导入系统日历', 'Import system calendars', 'システムカレンダーを取り込む');
  String get syncToIosCalendar => _t('同步到 iOS 日历', 'Sync to iOS Calendar', 'iOS カレンダーへ同期');
  String get notificationReminders => _t('通知提醒', 'Notifications', '通知');
  String get notificationPermissionGranted => _t('通知权限已开启，任务保存后会自动调度提醒', 'Notifications are enabled. Reminders are scheduled automatically after task save.', '通知権限は有効です。タスク保存後に自動で通知が設定されます。');
  String get notificationPermissionDenied => _t('尚未授予通知权限', 'Notification permission not granted', '通知権限が未許可です');
  String get enableNotificationPermission => _t('开启通知权限', 'Enable notifications', '通知を有効化');
  String get geofenceWalkingMode => _t('地理围栏遛弯模式', 'Geofence walking mode', 'ジオフェンス散歩モード');
  String get locationPermissionDenied => _t('尚未授予定位权限，无法自动切换宠物场景', 'Location permission is not granted, so pet scenes cannot switch automatically.', '位置情報権限が未許可のため、ペットのシーンを自動切替できません。');
  String get geofenceInactive => _t('位置权限已开启，当前未进入任何预设围栏', 'Location permission is enabled, but no preset geofence is active right now.', '位置情報権限は有効ですが、現在どのプリセットジオフェンスにも入っていません。');
  String geofenceActive(String placeName, SceneMode scene) => _t('当前位于 $placeName，宠物状态为 ${sceneLabel(scene)}', 'Currently at $placeName, pet scene is ${sceneLabel(scene)}', '現在地は $placeName、ペットの状態は ${sceneLabel(scene)} です');
  String get refreshGeofenceStatus => _t('刷新地理围栏状态', 'Refresh geofence state', 'ジオフェンス状態を更新');
  String get enableLocationPermission => _t('开启定位权限', 'Enable location permission', '位置情報権限を有効化');
  String get coreMotionParallax => _t('Core Motion 视差', 'Core Motion parallax', 'Core Motion 視差');
  String get sensorStreamEnabled => _t('传感器流已启动，液态玻璃和宠物动效会跟随设备倾斜', 'Sensor stream is active, so the glass effect and pet motion react to device tilt.', 'センサーストリームが有効で、液体ガラスやペット演出が端末の傾きに追従します。');
  String get sensorStreamDisabled => _t('当前设备未启用传感器流，界面会自动降级为静态效果', 'Sensor stream is disabled on this device, so the UI falls back to a static presentation.', 'この端末ではセンサーストリームが無効のため、UI は静的表現にフォールバックします。');
  String get cloudkitBackupRestore => _t('CloudKit 备份恢复', 'CloudKit backup and restore', 'CloudKit バックアップ復元');
  String get cloudkitBackupRestoreSubtitle => _t('共享快照与映射存储已预留', 'Shared snapshot and mapping storage is already reserved.', '共有スナップショットとマッピング保存領域は確保済みです。');
  String get widgetDynamicIsland => _t('Widget / Dynamic Island', 'Widget / Dynamic Island', 'Widget / Dynamic Island');
  String get widgetDynamicIslandSubtitle => _t('快照协议与原生扩展骨架待接入', 'Snapshot protocol and native extension scaffolding are waiting to be integrated.', 'スナップショットプロトコルとネイティブ拡張の骨組みは未接続です。');

  String get languageSystem => _t('跟随系统', 'Follow system', 'システムに従う');
  String get languageChinese => _t('中文', 'Chinese', '中国語');
  String get languageEnglish => 'English';
  String get languageJapanese => _t('日语', 'Japanese', '日本語');
  String languageCurrentLabel(AppLanguageMode mode) => switch (mode) {
    AppLanguageMode.system => languageSystem,
    AppLanguageMode.zh => languageChinese,
    AppLanguageMode.en => languageEnglish,
    AppLanguageMode.ja => languageJapanese,
  };
  String get systemCalendarSummaryAll => _t('默认展示系统上所有可访问的日历事件', 'Show all accessible system calendar events by default.', 'アクセス可能なすべてのシステムカレンダーイベントを既定表示します。');
  String get systemCalendarSummaryNone => _t('当前未纳入任何系统日历', 'No system calendar is currently included.', '現在、含まれているシステムカレンダーはありません。');
  String systemCalendarSummarySelected(int count) => _t('已选择 $count 个系统日历', '$count system calendars selected', '$count 件のシステムカレンダーを選択中');

  String fontScaleLabel(double value) {
    if (value >= 1.19) {
      return _t('大', 'Large', '大');
    }
    if (value >= 1.09) {
      return _t('中', 'Medium', '中');
    }
    return _t('小', 'Small', '小');
  }

  String get countdownTitle => _t('倒计时', 'Countdowns', 'カウントダウン');
  String get countdownSubtitle => _t('把重要日期放进一个连续的期待列表里。', 'Keep important dates in one continuous list of anticipation.', '大切な日付を、期待が続くひとつのリストにまとめます。');
  String get nextImportantMilestone => _t('下一次重要节点', 'Next milestone', '次の大切な節目');
  String get noCountdownYet => _t('还没有倒计时，先放一个值得期待的日期。', 'No countdown yet. Add a date worth looking forward to first.', 'まだカウントダウンはありません。まずは楽しみにしたい日付を追加しましょう。');
  String get inProgress => _t('进行中', 'Active', '進行中');
  String get dueSoon => _t('最近到期', 'Due soon', 'まもなく期限');
  String daysLabel(int count) => _t('$count 天', '$count d', '$count 日');
  String overdueHoursLabel(int count) => _t('已逾期 $count 小时', '$count h overdue', '$count 時間超過');
  String remainingDaysLabel(int count) => _t('剩余 $count 天', '$count days left', '残り $count 日');
  String dueAtLabel(DateTime dateTime) => _t(
    '截止 ${DateFormat('yyyy/MM/dd HH:mm', localeName).format(dateTime)}',
    'Due ${DateFormat('yyyy/MM/dd HH:mm', localeName).format(dateTime)}',
    '期限 ${DateFormat('yyyy/MM/dd HH:mm', localeName).format(dateTime)}',
  );
  String get restore => _t('恢复', 'Restore', '戻す');
  String get complete => _t('完成', 'Complete', '完了');
  String get delete => _t('删除', 'Delete', '削除');
  String get countdownDetail => _t('倒计时详情', 'Countdown details', 'カウントダウン詳細');
  String get detail => _t('详情', 'Details', '詳細');
  String get titleLabel => _t('标题', 'Title', 'タイトル');
  String get targetDateTime => _t('目标时间', 'Target time', '目標時刻');
  String get remaining => _t('剩余', 'Remaining', '残り');
  String get completed => _t('已完成', 'Completed', '完了済み');
  String get createdOn => _t('创建于', 'Created', '作成日');
  String get pinCountdown => _t('置顶倒计时', 'Pin countdown', 'カウントダウンを固定');
  String get completeCountdown => _t('完成倒计时', 'Mark countdown complete', 'カウントダウンを完了にする');
  String get completedCountdown => _t('已完成倒计时', 'Countdown completed', '完了済みカウントダウン');
  String get enterTitle => _t('请输入标题', 'Please enter a title', 'タイトルを入力してください');
  String get saveCountdown => _t('保存倒计时', 'Save countdown', 'カウントダウンを保存');

  String get save => _t('保存', 'Save', '保存');
  String get scheduleTab => _t('日程', 'Schedule', '予定');
  String get countdownTab => _t('倒计时', 'Countdown', 'カウントダウン');
  String get titleHintSchedule => _t('例如：带 Mochi 晚间遛弯', 'For example: Evening walk with Mochi', '例: Mochi と夜の散歩');
  String get titleHintCountdown => _t('例如：Mochi 生日 / 年度体检 / 疫苗到期', 'For example: Mochi birthday / annual checkup / vaccine due', '例: Mochi の誕生日 / 年次健診 / ワクチン期限');
  String get startTime => _t('开始时间', 'Start time', '開始時間');
  String get endTime => _t('结束时间', 'End time', '終了時間');
  String get repeat => _t('重复', 'Repeat', '繰り返し');
  String get reminder => _t('提醒', 'Reminder', '通知');
  String get category => _t('分类', 'Category', '分類');
  String get countdownTargetTime => _t('倒计时目标时间', 'Countdown target time', 'カウントダウン目標時刻');
  String get countdownSticker => _t('倒计时贴纸', 'Countdown sticker', 'カウントダウンステッカー');
  String get chooseBestOption => _t('选择一个最接近当前场景的选项，之后还可以继续改。', 'Choose the closest option for the current situation. You can change it later.', '今の状況に最も近い項目を選んでください。後から変更できます。');
  String get endTimeAfterStart => _t('结束时间需要晚于开始时间', 'End time must be later than start time', '終了時間は開始時間より後である必要があります');
  String get none => _t('无', 'None', 'なし');
  String get atTime => _t('事件发生时', 'At time of event', '予定時刻');
  String minutesBefore(int minutes) => _t('$minutes 分钟前', '$minutes min before', '$minutes 分前');
  String hoursBefore(int hours) => _t('$hours 小时前', '$hours h before', '$hours 時間前');
  String daysBefore(int days) => _t('$days 天前', '$days d before', '$days 日前');
  String get everyDay => _t('每天', 'Every day', '毎日');
  String get everyWeek => _t('每周', 'Every week', '毎週');
  String get everyMonth => _t('每月', 'Every month', '毎月');
  String get personalCategory => _t('个人', 'Personal', '個人');
  String get workCategoryShort => _t('工作', 'Work', '仕事');
  String get petCategoryShort => _t('宠物', 'Pet', 'ペット');
  String get anniversaryCategoryShort => _t('纪念', 'Anniversary', '記念');
  String get stickerEfficiency => _t('效率', 'Focus', '集中');
  String get stickerRelaxed => _t('轻松', 'Relaxed', '気軽');
  String get stickerPinned => _t('置顶', 'Pinned', '固定');
  String get stickerCelebrate => _t('庆祝', 'Celebrate', 'お祝い');

  String get createTask => _t('新建日程', 'New schedule', '予定を作成');
  String get editTask => _t('编辑日程', 'Edit schedule', '予定を編集');
  String get reminderTime => _t('提醒时间', 'Reminder time', '通知タイミング');
  String get saveSchedule => _t('保存日程', 'Save schedule', '予定を保存');

  String get chooseDate => _t('选择日期', 'Choose date', '日付を選択');
  String get today => _t('今天', 'Today', '今日');
  String get datePickerHint => _t('直接点选日期即可，流程比系统双弹窗更短。', 'Pick a date directly for a shorter flow than the system double-sheet.', '日付を直接選べば、システムの二段階ダイアログより素早く操作できます。');
  String get chooseTime => _t('选择时间', 'Choose time', '時刻を選択');
  String get timePickerHint => _t('滚轮选择更适合单手快速调整小时和分钟。', 'The wheel picker is better for quick one-handed hour and minute changes.', 'ホイール操作は片手で時分を素早く調整するのに向いています。');

  String get calendarEmptyAgenda => _t('今日还没安排哦，点击右上角创建', 'Nothing planned for today yet. Tap the top-right button to create one.', '今日はまだ予定がありません。右上のボタンから作成できます。');
  String get collapseMonthCalendar => _t('上滑收起月历', 'Swipe up to collapse month view', '上にスワイプして月表示を閉じる');
  String get expandMonthCalendar => _t('下拉展开月历', 'Pull down to expand month view', '下に引いて月表示を開く');
  String get add => _t('添加', 'Add', '追加');
  String get emptyAgendaDogIllustration => _t('空日程狗狗插画', 'Empty agenda dog illustration', '空の予定の犬イラスト');
  List<String> weekdayLabels({required bool startsOnMonday}) {
    if (isEnglish) {
      return startsOnMonday
          ? const ['M', 'T', 'W', 'T', 'F', 'S', 'S']
          : const ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    }
    return startsOnMonday
        ? [
            _t('一', 'M', '月'),
            _t('二', 'T', '火'),
            _t('三', 'W', '水'),
            _t('四', 'T', '木'),
            _t('五', 'F', '金'),
            _t('六', 'S', '土'),
            _t('日', 'S', '日'),
          ]
        : [
            _t('日', 'S', '日'),
            _t('一', 'M', '月'),
            _t('二', 'T', '火'),
            _t('三', 'W', '水'),
            _t('四', 'T', '木'),
            _t('五', 'F', '金'),
            _t('六', 'S', '土'),
          ];
  }

  String monthLabel(DateTime date) => switch (languageCode) {
    'en' => DateFormat('MMMM yyyy', localeName).format(date),
    'ja' => DateFormat('yyyy年M月', localeName).format(date),
    _ => DateFormat('yyyy年MM月', localeName).format(date),
  };

  String dateWithWeekday(DateTime date) => switch (languageCode) {
    'en' => DateFormat('EEE, MMM d', localeName).format(date),
    'ja' => DateFormat('M月d日 EEEE', localeName).format(date),
    _ => DateFormat('M月d日 EEEE', localeName).format(date),
  };

  String calendarTime(DateTime date) => DateFormat('HH:mm', localeName).format(date);
  String shortDate(DateTime date) => DateFormat('M月d日', localeName).format(date);
  String datePickerPattern() => switch (languageCode) {
    'en' => 'yyyy/MM/dd',
    'ja' => 'yyyy/MM/dd',
    _ => 'yyyy/MM/dd',
  };
  String chipDatePattern() => switch (languageCode) {
    'en' => 'MMM dd, yyyy',
    'ja' => 'yyyy年MM月dd日',
    _ => 'yyyy 年 MM 月 dd 日',
  };

  String get currentSkin => _t('当前皮肤', 'Current skin', '現在のスキン');
  String get noPetSelected => _t('还没有选中宠物。', 'No pet selected yet.', 'まだペットが選択されていません。');
  String get currentHidden => _t('当前已隐藏', 'Currently hidden', '現在は非表示');
  String get currentSkinBadge => _t('当前皮肤', 'Current skin', '現在のスキン');
  String get tapToSwitchSkin => _t('点击切换', 'Tap to switch', 'タップして切替');
  String petCompanionTitle(String name) => _t('$name 今天陪你冲刺', '$name is keeping pace with you today', '$name が今日は一緒に走ってくれます');
  String get pickFirstPup => _t('先选一只狗狗伙伴', 'Pick your first pup', '最初の相棒を選びましょう');
  String get noPetChosen => _t('未选择宠物', 'No pet selected', 'ペット未選択');
  String levelLabel(int level) => 'Lv.$level';
  String get longPressFetch => _t('长按试试 Fetch', 'Long press to try Fetch', '長押しで Fetch');
  String get walkingModeCopy => _t('Mochi 已切换到遛弯姿态，随时准备提醒你按时出门。', 'Mochi is in walking mode and ready to remind you when it is time to head out.', 'Mochi はお散歩モードに切り替わり、出発のタイミングを知らせる準備ができています。');
  String moodCopy(PetMood mood) => switch (mood) {
    PetMood.excited => _t('今日任务推进顺利，宠物会在完成关键待办时给你奖励反馈。', 'Today is moving well. Your pet will celebrate when key tasks get done.', '今日は順調です。重要なタスクを終えるとペットがごほうび反応を返します。'),
    PetMood.calm => _t('节奏稳定，保持今天的完成率就能继续解锁隐藏动作。', 'The pace is steady. Keep up today’s completion rate to unlock more hidden motions.', 'ペースは安定しています。今日の達成率を保てば隠しモーションをさらに解放できます。'),
    PetMood.lazy => _t('还有待办没推进，长按宠物直接拖球到日期上创建任务。', 'There are still pending tasks. Long press the pet and drag the ball onto a date to create one.', 'まだ進んでいないタスクがあります。ペットを長押ししてボールを日付へドラッグすると作成できます。'),
    PetMood.sad => _t('存在逾期任务，优先清掉积压项让宠物恢复精神。', 'There are overdue tasks. Clear the backlog first to lift your pet’s mood.', '期限切れのタスクがあります。まずは滞留分を片付けて元気を取り戻しましょう。'),
  };

  String sceneLabel(SceneMode mode) => switch (mode) {
    SceneMode.home => _t('居家', 'Home', '家'),
    SceneMode.working => _t('工作中', 'Working', '仕事中'),
    SceneMode.walking => _t('遛弯模式', 'Walking', '散歩モード'),
    SceneMode.resting => _t('休息中', 'Resting', '休憩中'),
    SceneMode.caring => _t('守护中', 'Caring', '見守り中'),
  };

  String categoryLabel(CalendarCategory category) => switch (category) {
    CalendarCategory.daily => _t('日常', 'Daily', '日常'),
    CalendarCategory.work => _t('工作', 'Work', '仕事'),
    CalendarCategory.anniversary => _t('纪念日', 'Anniversary', '記念日'),
    CalendarCategory.pet => _t('宠物相关', 'Pet', 'ペット'),
  };

  String breedLabel(PetBreed breed) => switch (breed) {
    PetBreed.shiba => 'Shiba',
    PetBreed.goldenRetriever => 'Golden Retriever',
    PetBreed.beagle => 'Beagle',
    PetBreed.husky => 'Husky',
    PetBreed.samoyed => 'Samoyed',
  };

  String performanceTierLabel(PerformanceTier tier) => switch (tier) {
    PerformanceTier.rich => _t('高保真', 'Rich', '高品質'),
    PerformanceTier.balanced => _t('平衡', 'Balanced', 'バランス'),
    PerformanceTier.lite => _t('轻量', 'Lite', '軽量'),
  };

  String fallbackCalendarTitle() => _t('未命名日历', 'Untitled Calendar', '名称未設定のカレンダー');
  String fallbackCalendarSource() => _t('其他', 'Other', 'その他');

  String notificationDebugTitle(String title) => _t('$title · 调试提醒', '$title · Debug reminder', '$title ・デバッグ通知');
  String notificationDebugBody(int minutes) => _t('立即预览，原提醒设定为 $minutes 分钟前。', 'Preview now. The original reminder is set for $minutes minutes before.', '今すぐプレビューします。元の通知は $minutes 分前に設定されています。');
  String notificationDebugBodyWithDescription(String description, int minutes) => _t('$description\n调试预览：$minutes 分钟前', '$description\nDebug preview: $minutes minutes before', '$description\nデバッグプレビュー: $minutes 分前');
  String notificationStartingSoon(CalendarCategory category) => _t('即将开始 · ${categoryLabel(category)}', 'Starting soon · ${categoryLabel(category)}', 'まもなく開始 ・ ${categoryLabel(category)}');
  String get notificationChannelName => _t('DoggyLog 任务提醒', 'DoggyLog Tasks', 'DoggyLog タスク通知');
  String get notificationChannelDescription => _t('DoggyLog 日历任务的提醒通知。', 'Task reminders for DoggyLog calendar entries.', 'DoggyLog カレンダー予定の通知です。');

  String get messageBiometricUnsupportedSkipped => _t('当前设备不支持 Face ID / Touch ID，已跳过应用解锁', 'This device does not support Face ID / Touch ID, so app lock was skipped.', 'この端末は Face ID / Touch ID に対応していないため、アプリロックをスキップしました。');
  String get messageBiometricUnsupported => _t('当前设备不支持 Face ID / Touch ID', 'This device does not support Face ID / Touch ID.', 'この端末は Face ID / Touch ID に対応していません。');
  String get messageBiometricFailed => _t('生物识别验证失败，未开启应用解锁', 'Biometric verification failed, so app unlock was not enabled.', '生体認証に失敗したため、アプリロック解除は有効になりませんでした。');
  String get messageBiometricEnabled => _t('已开启 Face ID / Touch ID 解锁', 'Face ID / Touch ID unlock is enabled.', 'Face ID / Touch ID によるロック解除が有効になりました。');
  String get messageBiometricDisabled => _t('已关闭生物识别解锁', 'Biometric unlock is disabled.', '生体認証によるロック解除をオフにしました。');
  String get messageUnlocked => _t('已解锁 DoggyLog', 'DoggyLog unlocked.', 'DoggyLog のロックを解除しました。');
  String get messageUnlockFailed => _t('解锁失败，请重试', 'Unlock failed. Please try again.', 'ロック解除に失敗しました。再試行してください。');
  String get messageSyncedToIosCalendar => _t('已同步到 iOS 日历', 'Synced to iOS Calendar.', 'iOS カレンダーに同期しました。');
  String messageSyncedTasksToIosCalendar(int count) => _t('已同步 $count 条任务到 iOS 日历', 'Synced $count tasks to iOS Calendar.', '$count 件のタスクを iOS カレンダーへ同期しました。');
  String get messageNotificationPermissionOn => _t('通知权限已开启', 'Notifications enabled.', '通知権限を有効にしました。');
  String get messageNotificationPermissionOff => _t('通知权限未开启', 'Notifications not enabled.', '通知権限は有効ではありません。');
  String get messageCalendarPermissionDenied => _t('未授予日历权限', 'Calendar permission not granted.', 'カレンダー権限がありません。');
  String get messageLocationPermissionEnabled => _t('位置权限已开启，地理围栏已启动', 'Location permission enabled. Geofencing has started.', '位置情報権限を有効にし、ジオフェンスを開始しました。');
  String get messageLocationPermissionDenied => _t('未授予位置权限', 'Location permission not granted.', '位置情報権限がありません。');
  String get messageLocationOutsideGeofence => _t('当前位置不在预设围栏内', 'Current location is outside preset geofences.', '現在地はプリセットのジオフェンス外です。');
  String messageEnteredGeofence(String placeName, SceneMode scene) => _t('已进入 $placeName · ${sceneLabel(scene)}', 'Entered $placeName · ${sceneLabel(scene)}', '$placeName に入りました ・ ${sceneLabel(scene)}');
  String messagePrefixImportedSystemCalendarSnapshot() => _t('已导入系统日历快照', 'Imported system calendar snapshot', 'システムカレンダースナップショットを取り込みました');
  String messagePrefixSystemCalendarScopeUpdated() => _t('系统日历展示范围已更新', 'System calendar scope updated', 'システムカレンダーの表示範囲を更新しました');
  String get messageIncrementalCalendarSyncFailed => _t('系统日历增量同步失败', 'Incremental system calendar sync failed.', 'システムカレンダーの差分同期に失敗しました。');
  String get messageIncrementalCalendarSyncPrefix => _t('系统日历已增量同步', 'System calendar synced incrementally', 'システムカレンダーを差分同期しました');
  String messageIncrementalCalendarSyncResult(
    String prefix,
    int changeCount,
    int visibleCount,
  ) => _t(
    '$prefix：$changeCount 条变更，$visibleCount 条可见事件',
    '$prefix: $changeCount changes, $visibleCount visible events',
    '$prefix: $changeCount 件の変更、$visibleCount 件の表示イベント',
  );

  String localizedSkinStyleName(String value) {
    return switch (value) {
      '积木学堂' => _t('积木学堂', 'Studio Blocks', 'スタジオブロック'),
      '数据透明' => _t('数据透明', 'Data Glass', 'データグラス'),
      'AI 对话' => _t('AI 对话', 'AI Dialogue', 'AI ダイアログ'),
      '健康轻灵' => _t('健康轻灵', 'Healthy Lightness', 'ヘルシーライト'),
      '云朵温柔' => _t('云朵温柔', 'Cloud Softness', 'クラウドソフト'),
      _ => value,
    };
  }

  String localizedSkinDescription(AppSkinSpec spec) {
    if (spec.styleDescription.isNotEmpty) {
      return spec.styleDescription;
    }
    return switch (spec.styleName) {
      '积木学堂' => _t('偏暖、轻快、像课堂便签一样清晰。', 'Warm and brisk, with the clarity of classroom sticky notes.', 'あたたかく軽快で、教室の付箋のように整理された印象です。'),
      '数据透明' => _t('更冷静的玻璃质感，适合信息密度更高的工作状态。', 'A calmer glass treatment for denser, more focused work.', '情報密度が高い作業に向く、より落ち着いたガラス表現です。'),
      'AI 对话' => _t('偏科技感的蓝紫层次，适合持续对话和记录。', 'A layered tech-forward palette for continuous conversation and capture.', '対話や記録が続く場面に合う、テック感のあるレイヤーカラーです。'),
      '健康轻灵' => _t('通透而轻盈，适合健康与日常维护。', 'Airy and transparent, suited for wellness and routine maintenance.', '軽やかで透明感があり、健康管理や日常ケアに向いています。'),
      '云朵温柔' => _t('更柔软的粉白色调，适合陪伴与纪念。', 'A softer pink-white palette for companionship and milestones.', 'やわらかなピンクホワイトで、寄り添いと記念日に向いています。'),
      _ => spec.styleDescription,
    };
  }

  String _t(String zh, String en, String ja) {
    return switch (languageCode) {
      'en' => en,
      'ja' => ja,
      _ => zh,
    };
  }

  String text(String zh, String en, String ja) => _t(zh, en, ja);
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppLocalizations.supportedLocales.any(
        (item) => item.languageCode == locale.languageCode,
      );

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations.fromLocale(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

Locale _supportedLocale(Locale locale) {
  final code = locale.languageCode.toLowerCase();
  if (code == 'en' || code == 'ja') {
    return Locale(code);
  }
  return const Locale('zh');
}

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
