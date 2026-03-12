import 'dart:ui';

import 'package:doggylog/app/theme/app_skin_theme.dart';
import 'package:doggylog/features/shared/domain/models.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

abstract final class SeedCopyKey {
  static const taskMorningWalkTitle = 'seed.task.morning_walk.title';
  static const taskMorningWalkDescription =
      'seed.task.morning_walk.description';
  static const taskProductReviewTitle = 'seed.task.product_review.title';
  static const taskProductReviewDescription =
      'seed.task.product_review.description';
  static const taskVaccineDueTitle = 'seed.task.vaccine_due.title';
  static const taskVaccineDueDescription = 'seed.task.vaccine_due.description';
  static const countdownMochiBirthdayTitle =
      'seed.countdown.mochi_birthday.title';
  static const countdownAnnualCheckupTitle =
      'seed.countdown.annual_checkup.title';
  static const templateWalk30Title = 'seed.template.walk_30.title';
  static const templateFeedTitle = 'seed.template.feed.title';
  static const templateGroomingTitle = 'seed.template.grooming.title';
  static const templateFocusTitle = 'seed.template.focus.title';
  static const geofenceHomeName = 'seed.geofence.home.name';
  static const geofenceOfficeName = 'seed.geofence.office.name';
  static const geofenceParkName = 'seed.geofence.park.name';
}

Locale resolveAppLocale(AppLanguageMode mode, {Locale? systemLocale}) {
  final locale = systemLocale ?? PlatformDispatcher.instance.locale;
  return switch (mode) {
    AppLanguageMode.system => _supportedLocale(locale),
    AppLanguageMode.zh => const Locale('zh'),
    AppLanguageMode.en => const Locale('en'),
    AppLanguageMode.ja => const Locale('ja'),
  };
}

void syncGlobalLocale(AppLanguageMode mode) {
  Intl.defaultLocale = AppLocalizations.fromLocale(
    resolveAppLocale(mode),
  ).localeName;
}

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = [Locale('zh'), Locale('en'), Locale('ja')];

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
      return AppLocalizations.fromLocale(
        Locale(currentLocale.split('_').first),
      );
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
  String get unlockSheetTitle => _t(
    'DoggyLog 暂时锁住啦',
    'DoggyLog is taking a tiny lock break',
    'DoggyLog はちょっとだけロック中です',
  );
  String get unlockSheetSubtitle => _t(
    '用 Face ID / Touch ID 回来继续记吧。',
    'Use Face ID / Touch ID to hop back in.',
    'Face ID / Touch ID でふわっと戻ってきてください。',
  );
  String get unlockNow => _t('马上解锁', 'Unlock now', '今すぐロック解除');
  String get biometricReason => _t(
    '使用 Face ID / Touch ID 解锁 DoggyLog',
    'Use Face ID / Touch ID to unlock DoggyLog',
    'Face ID / Touch ID で DoggyLog のロックを解除します',
  );

  String get homeTabCountdown => _t('倒计时', 'Countdowns', 'カウントダウン');
  String get homeTabCalendar => _t('日历', 'Calendar', 'カレンダー');
  String get homeTabSettings => _t('我的', 'Me', 'わたし');

  String get settingsHeaderTitle => _t('我的', 'Me', 'わたし');
  String get petsSectionTitle => _t('毛孩子', 'Pup pal', 'わんこ');
  String get managePetSkins => _t('给小狗换装', 'Dress up your pup', 'わんこをお着替え');
  String get settingsSectionTitle => _t('设置', 'Settings', '設定');
  String get weekStartsOnMonday =>
      _t('每周从周一开始', 'Start weeks on Monday', '週のはじまりを月曜日にする');
  String get hapticsFeedback => _t('轻震反馈', 'Soft haptics', 'やさしい触覚フィードバック');
  String get systemCalendar => _t('系统日历', 'System calendars', 'システムカレンダー');
  String get language => _t('语言', 'Language', '言語');
  String get biometricUnlock => _t('生物识别解锁', 'Biometric unlock', '生体認証でロック解除');
  String get fontSize => _t('字体大小', 'Text size', '文字サイズ');
  String get fontSizeSubtitle => _t(
    '小、中、大三档都备好啦，选你看着最舒服的。',
    'Pick the text size that feels nicest: small, medium, or large.',
    '小・中・大から、いちばん読みやすいサイズを選べます。',
  );
  String get developmentDebug => _t('开发调试', 'Developer debug', '開発デバッグ');
  String get developmentDebugSubtitle => _t(
    '动效强度、提醒预览和 iOS 扩展能力都在这里。',
    'Motion tuning, reminder previews, and iOS extras live here.',
    '動きの強さ、通知プレビュー、iOS 拡張まわりをここで調整できます。',
  );
  String get allCalendars => _t('全部日历', 'All calendars', 'すべてのカレンダー');
  String get allCalendarsSubtitle => _t(
    '新出现的系统日历，也会默认自动带上。',
    'New system calendars join in automatically by default.',
    '新しく増えたシステムカレンダーも、基本は自動で含まれます。',
  );
  String get readOnlyCalendar =>
      _t('只读日历', 'Read-only calendar', '読み取り専用カレンダー');
  String get done => _t('完成', 'Done', '完了');
  String get reload => _t('重新加载', 'Reload', '再読み込み');
  String get emptySystemCalendarsTitle =>
      _t('还没读到系统日历', 'No system calendars yet', 'システムカレンダーがまだ見つかっていません');
  String get emptySystemCalendarsSubtitle => _t(
    '看看日历权限有没有打开，或者设备里有没有可用日历。',
    'Check calendar access, or make sure this device actually has calendars to show.',
    'カレンダー権限があるか、表示できるカレンダーが端末にあるか確認してください。',
  );
  String get systemCalendarGuide => _t(
    '勾选后，这些日历会显示在 DoggyLog 里，也会加入增量同步。',
    'Selected calendars will show up in DoggyLog and join incremental sync.',
    '選んだカレンダーは DoggyLog に表示され、差分同期にも入ります。',
  );
  String get animationIntensity => _t('动效强度', 'Motion intensity', '動きの強さ');
  String get animationIntensitySubtitle => _t(
    '柔和动效会保留，也给低性能设备留一点余量。',
    'Keep the soft feel while leaving a little breathing room for lower-end devices.',
    'やわらかな動きは残しつつ、軽めの端末でも余裕が出るようにします。',
  );
  String get renderTier => _t('渲染档位', 'Render tier', '描画モード');
  String get reminderDebugMode =>
      _t('提醒调试模式', 'Reminder preview mode', '通知プレビューモード');
  String get reminderDebugModeSubtitle => _t(
    '保存带提醒的任务后，会立刻来一条 App 内提醒预览。',
    'After saving a reminder task, show an in-app preview right away.',
    '通知つきタスクを保存したあと、アプリ内プレビューをすぐ表示します。',
  );
  String get iosCapabilities => _t('iOS 增强能力', 'iOS capabilities', 'iOS 拡張機能');
  String get eventKitSync => _t('EventKit 同步', 'EventKit sync', 'EventKit 同期');
  String get eventKitGranted => _t(
    '已经拿到日历权限啦，可以导入系统事件，也能把 DoggyLog 任务写回去。',
    'Calendar access is ready. You can pull in system events and send DoggyLog tasks back out.',
    'カレンダー権限はばっちりです。システム予定を取り込んだり、DoggyLog のタスクを書き戻したりできます。',
  );
  String get calendarPermissionDenied =>
      _t('还没有日历权限', 'Calendar access is still off', 'カレンダー権限はまだオフです');
  String get importSystemCalendar =>
      _t('导入系统日历', 'Import system calendars', 'システムカレンダーを取り込む');
  String get syncToIosCalendar =>
      _t('同步到 iOS 日历', 'Sync to iOS Calendar', 'iOS カレンダーへ同期');
  String get notificationReminders => _t('通知提醒', 'Notifications', '通知');
  String get notificationPermissionGranted => _t(
    '通知权限已经打开，保存任务后会自动安排提醒。',
    'Notifications are on. Reminders will be lined up automatically when you save.',
    '通知はオンです。保存したタスクのリマインドが自動でセットされます。',
  );
  String get notificationPermissionDenied =>
      _t('还没有通知权限', 'Notifications are still off', '通知権限はまだオフです');
  String get enableNotificationPermission =>
      _t('打开通知权限', 'Turn on notifications', '通知をオンにする');
  String get geofenceWalkingMode =>
      _t('地理围栏遛弯模式', 'Geofence walking mode', 'ジオフェンス散歩モード');
  String get locationPermissionDenied => _t(
    '还没有定位权限，宠物场景暂时没法自动切换。',
    'Location access is still off, so pet scenes cannot switch on their own yet.',
    '位置情報がまだオフなので、わんこのシーン切り替えは自動では動きません。',
  );
  String get geofenceInactive => _t(
    '定位权限已经打开，但现在还没进入任何预设围栏。',
    'Location access is on, but you are not inside any saved geofence right now.',
    '位置情報はオンですが、今はどのプリセット囲いにも入っていません。',
  );
  String geofenceActive(String placeName, SceneMode scene) {
    final localizedPlaceName = localizedStoredText(placeName);
    return _t(
      '你现在在 $localizedPlaceName，宠物状态是 ${sceneLabel(scene)}',
      'You are at $localizedPlaceName, and your pup is in ${sceneLabel(scene)} mode.',
      'いまは $localizedPlaceName にいて、わんこは ${sceneLabel(scene)} モードです。',
    );
  }

  String get refreshGeofenceStatus =>
      _t('刷新围栏状态', 'Refresh geofence status', '囲いの状態を更新');
  String get enableLocationPermission =>
      _t('打开定位权限', 'Turn on location access', '位置情報をオンにする');
  String get coreMotionParallax =>
      _t('Core Motion 视差', 'Core Motion parallax', 'Core Motion 視差');
  String get sensorStreamEnabled => _t(
    '传感器已经启动，液态玻璃和宠物动效会跟着设备轻轻摆动。',
    'Sensors are awake, so the glass and pet motion gently follow your tilt.',
    'センサーが動いているので、ガラスやわんこの動きが端末の傾きにふわっとついてきます。',
  );
  String get sensorStreamDisabled => _t(
    '这台设备没有开启传感器流，界面会自动切成静态效果。',
    'Sensors are off on this device, so the UI falls back to a calmer static look.',
    'この端末ではセンサーがオフなので、画面はおだやかな静止表現に切り替わります。',
  );
  String get cloudkitBackupRestore =>
      _t('CloudKit 备份恢复', 'CloudKit backup and restore', 'CloudKit バックアップ復元');
  String get cloudkitBackupRestoreSubtitle => _t(
    '共享快照和映射存储已经预留好啦。',
    'Shared snapshot and mapping storage are already set aside.',
    '共有スナップショットとマッピング保存先は、もう準備してあります。',
  );
  String get widgetDynamicIsland => _t(
    'Widget / Dynamic Island',
    'Widget / Dynamic Island',
    'Widget / Dynamic Island',
  );
  String get widgetDynamicIslandSubtitle => _t(
    '快照协议和原生扩展骨架还在接入中。',
    'Snapshot plumbing and native extension scaffolding are still being wired up.',
    'スナップショットまわりとネイティブ拡張の土台は、まだ接続中です。',
  );

  String get languageSystem => _t('跟随系统', 'Follow system', 'システムに合わせる');
  String get languageChinese => _t('中文', 'Chinese', '中国語');
  String get languageEnglish => 'English';
  String get languageJapanese => _t('日语', 'Japanese', '日本語');
  String get languagePickerTitle =>
      _t('切换界面语言', 'Choose app language', 'アプリの言語を選択');
  String get languagePickerSubtitle => _t(
    '选择后会立刻切换整套界面文案、日期格式和提醒文案。',
    'Switch the interface copy, date formatting, and reminder text instantly.',
    '選択すると、画面文言、日付形式、通知文言がすぐに切り替わります。',
  );
  String get languagePickerCurrentBadge => _t('当前使用', 'Current', '現在');
  String get languagePickerTapHint => _t(
    '点一下就生效，不需要再确认。',
    'Tap once to apply, no extra confirmation needed.',
    'タップするとすぐに反映され、追加の確認は不要です。',
  );
  String languageCurrentLabel(AppLanguageMode mode) => switch (mode) {
    AppLanguageMode.system => languageSystem,
    AppLanguageMode.zh => languageChinese,
    AppLanguageMode.en => languageEnglish,
    AppLanguageMode.ja => languageJapanese,
  };
  String languageNativeLabel(AppLanguageMode mode) => switch (mode) {
    AppLanguageMode.system => _t('Auto', 'Auto', '自動'),
    AppLanguageMode.zh => '简体中文',
    AppLanguageMode.en => 'English',
    AppLanguageMode.ja => '日本語',
  };
  String languageOptionDescription(AppLanguageMode mode) => switch (mode) {
    AppLanguageMode.system => _t(
      '自动跟着设备语言走。',
      'Match the device language automatically.',
      '端末の言語に自動で合わせます。',
    ),
    AppLanguageMode.zh => _t(
      '界面、日期和提醒都使用中文。',
      'Use Chinese for the interface, dates, and reminders.',
      '画面、日付、通知を中国語で表示します。',
    ),
    AppLanguageMode.en => _t(
      '界面、日期和提醒都使用英文。',
      'Use English for the interface, dates, and reminders.',
      '画面、日付、通知を英語で表示します。',
    ),
    AppLanguageMode.ja => _t(
      '界面、日期和提醒都使用日语。',
      'Use Japanese for the interface, dates, and reminders.',
      '画面、日付、通知を日本語で表示します。',
    ),
  };
  String get systemCalendarSummaryAll => _t(
    '默认会展示系统里所有可访问的日历事件。',
    'All accessible system calendars are showing by default.',
    'アクセスできるシステムカレンダーは、いま全部表示されています。',
  );
  String get systemCalendarSummaryNone => _t(
    '现在还没纳入任何系统日历。',
    'No system calendars are included yet.',
    'まだ取り込まれているシステムカレンダーはありません。',
  );
  String systemCalendarSummarySelected(int count) => _t(
    '已经选了 $count 个系统日历',
    '$count system calendars selected',
    '$count 件のシステムカレンダーを選択中',
  );

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
  String get countdownSubtitle => _t(
    '把值得期待的日子，排成一条闪闪发光的小清单。',
    'A tiny sparkly list for the days you cannot wait for.',
    '楽しみな日を、きらっと並べておけます。',
  );
  String get nextImportantMilestone =>
      _t('最近的期待', 'Coming up next', 'いちばん近い楽しみ');
  String get noCountdownYet => _t(
    '这里还没有倒计时，先放一个想期待的日子吧。',
    'No countdowns yet. Add a day worth looking forward to.',
    'まだカウントダウンはありません。楽しみな日をひとつ入れてみましょう。',
  );
  String get inProgress => _t('进行中', 'Active', '進行中');
  String get dueSoon => _t('快到了', 'Almost here', 'もうすぐ');
  String daysLabel(int count) => _t('$count 天', '$count d', '$count 日');
  String overdueHoursLabel(int count) =>
      _t('已经晚了 $count 小时', '$count h late', '$count 時間すぎています');
  String remainingDaysLabel(int count) =>
      _t('还有 $count 天', '$count days left', 'あと $count 日');
  String dueAtLabel(DateTime dateTime) => _t(
    '目标时间 ${DateFormat('yyyy/MM/dd HH:mm', localeName).format(dateTime)}',
    'Target time ${DateFormat('yyyy/MM/dd HH:mm', localeName).format(dateTime)}',
    '目標時間 ${DateFormat('yyyy/MM/dd HH:mm', localeName).format(dateTime)}',
  );
  String get restore => _t('恢复', 'Restore', '戻す');
  String get complete => _t('完成', 'Complete', '完了');
  String get delete => _t('删除', 'Delete', '削除');
  String get countdownDetail => _t('倒计时详情', 'Countdown details', 'カウントダウンの詳細');
  String get detail => _t('详情', 'Details', 'くわしく');
  String get titleLabel => _t('标题', 'Title', 'タイトル');
  String get targetDateTime => _t('目标时间', 'Target time', '目標時刻');
  String get remaining => _t('还剩', 'Left', 'あと');
  String get completed => _t('已完成', 'Completed', '完了済み');
  String get createdOn => _t('创建时间', 'Created on', '作成日');
  String get pinCountdown =>
      _t('置顶这个倒计时', 'Pin this countdown', 'このカウントダウンを上に置く');
  String get completeCountdown => _t('标记为完成', 'Mark as done', '完了にする');
  String get completedCountdown =>
      _t('这个倒计时已完成', 'This countdown is done', 'このカウントダウンは完了しました');
  String get enterTitle => _t('先写个标题吧', 'Start with a title', 'まずはタイトルを入れましょう');
  String get saveCountdown => _t('保存倒计时', 'Save countdown', 'カウントダウンを保存');

  String get save => _t('保存', 'Save', '保存');
  String get scheduleTab => _t('日程', 'Schedule', '予定');
  String get countdownTab => _t('倒计时', 'Countdown', 'カウントダウン');
  String get titleHintSchedule => _t(
    '比如：带 Mochi 去散散步',
    'For example: Sunset walk with Mochi',
    '例: Mochi と夕方さんぽ',
  );
  String get titleHintCountdown => _t(
    '比如：Mochi 生日 / 年度体检 / 疫苗补打',
    'For example: Mochi birthday / annual checkup / vaccine booster',
    '例: Mochi の誕生日 / 年次健診 / ワクチン追加',
  );
  String get startTime => _t('开始时间', 'Start time', '開始時間');
  String get endTime => _t('结束时间', 'End time', '終了時間');
  String get repeat => _t('重复', 'Repeat', '繰り返し');
  String get reminder => _t('提醒', 'Reminder', '通知');
  String get category => _t('分类', 'Category', '分類');
  String get countdownTargetTime =>
      _t('倒计时目标时间', 'Countdown target time', 'カウントダウン目標時刻');
  String get countdownSticker =>
      _t('倒计时贴纸', 'Countdown sticker', 'カウントダウンステッカー');
  String get chooseBestOption => _t(
    '先选一个最接近的就好，之后随时都能改。',
    'Pick the closest fit for now. You can always tweak it later.',
    'いま近いものを選べば大丈夫。あとでいつでも直せます。',
  );
  String get endTimeAfterStart => _t(
    '结束时间要晚于开始时间哦',
    'End time needs to be later than the start time.',
    '終了時間は開始時間よりあとにしてください。',
  );
  String get none => _t('不提醒', 'No reminder', '通知しない');
  String get atTime => _t('事件开始时', 'Right on time', 'ちょうどその時間');
  String minutesBefore(int minutes) =>
      _t('提前 $minutes 分钟', '$minutes min early', '$minutes分前にお知らせ');
  String hoursBefore(int hours) =>
      _t('提前 $hours 小时', '$hours h early', '$hours時間前にお知らせ');
  String daysBefore(int days) =>
      _t('提前 $days 天', '$days d early', '$days日前にお知らせ');
  String get everyDay => _t('每天', 'Every day', '毎日');
  String get everyWeek => _t('每周', 'Every week', '毎週');
  String get everyMonth => _t('每月', 'Every month', '毎月');
  String get personalCategory => _t('生活', 'Life', 'くらし');
  String get workCategoryShort => _t('工作', 'Work', '仕事');
  String get petCategoryShort => _t('毛孩子', 'Pup', 'わんこ');
  String get anniversaryCategoryShort => _t('纪念', 'Milestone', '記念');
  String get stickerEfficiency => _t('专注', 'Focus', 'しっかり');
  String get stickerRelaxed => _t('轻松', 'Easygoing', 'ゆるっと');
  String get stickerPinned => _t('置顶', 'Pinned', 'いちばん上');
  String get stickerCelebrate => _t('庆祝', 'Celebrate', 'お祝い');

  String get createTask => _t('记个日程', 'Add a schedule', '予定を入れる');
  String get editTask => _t('改改日程', 'Edit schedule', '予定を直す');
  String get reminderTime => _t('提醒时间', 'Reminder timing', '通知のタイミング');
  String get saveSchedule => _t('保存日程', 'Save schedule', '予定を保存');

  String get chooseDate => _t('选个日期', 'Pick a date', '日付を選ぶ');
  String get today => _t('今天', 'Today', '今日');
  String get chooseTime => _t('选个时间', 'Pick a time', '時間を選ぶ');

  String get calendarEmptyAgenda => _t(
    '今天还空空的，点右上角记一件吧',
    'Today is still wide open. Tap the top-right corner to add one.',
    '今日はまだまっさらです。右上からひとつ入れてみましょう。',
  );
  String get collapseMonthCalendar =>
      _t('上滑收起月历', 'Swipe up to collapse month view', '上にスワイプして月表示を閉じる');
  String get expandMonthCalendar =>
      _t('下拉展开月历', 'Pull down to expand month view', '下に引いて月表示を開く');
  String get add => _t('添加', 'Add', '追加');
  String get emptyAgendaDogIllustration =>
      _t('空日程狗狗插画', 'Empty agenda dog illustration', '空の予定の犬イラスト');
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

  String calendarTime(DateTime date) =>
      DateFormat('HH:mm', localeName).format(date);
  String shortDate(DateTime date) => switch (languageCode) {
    'en' => DateFormat('MMM d', localeName).format(date),
    'ja' => DateFormat('M月d日', localeName).format(date),
    _ => DateFormat('M月d日', localeName).format(date),
  };
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

  String get currentSkin => _t('现在这套', 'Wearing now', 'いまはこれ');
  String get noPetSelected =>
      _t('还没有选中宠物哦。', 'No pup selected yet.', 'まだわんこが選ばれていません。');
  String get currentHidden =>
      _t('这套先藏起来啦', 'Tucked away for now', 'いまはちょっと隠しています');
  String get currentSkinBadge => _t('现在这套', 'Wearing now', 'いまはこれ');
  String get tapToSwitchSkin => _t('点一下换装', 'Tap to change', 'タップで着替える');
  String petCompanionTitle(String name) => _t(
    '$name 今天也陪你呀',
    '$name is hanging out with you today',
    '$name が今日はそばで付き合ってくれます',
  );
  String get pickFirstPup =>
      _t('先选一只小狗搭子', 'Pick your first pup pal', '最初のわんこ相棒を選びましょう');
  String get noPetChosen => _t('还没选宠物', 'No pup selected', 'まだ選んでいません');
  String levelLabel(int level) => 'Lv.$level';
  String get longPressFetch =>
      _t('长按试试 Fetch 小球', 'Long press to try Fetch', '長押しで Fetch ボール');
  String get walkingModeCopy => _t(
    'Mochi 已经切到散步模式啦，准备好提醒你准时出门。',
    'Mochi is in walk mode and ready to nudge you out the door on time.',
    'Mochi はおさんぽモードで、出かける時間をやさしく教えてくれます。',
  );
  String moodCopy(PetMood mood) => switch (mood) {
    PetMood.excited => _t(
      '今天推进得很顺，完成关键待办时，狗狗会给你一点小奖励。',
      'Today is flowing nicely. Your pup will cheer you on when key tasks land.',
      '今日はいい流れです。大事なタスクが終わるたび、わんこがちょっと盛り上げてくれます。',
    ),
    PetMood.calm => _t(
      '今天节奏稳稳的，继续保持，就能解锁更多隐藏动作。',
      'The pace feels steady. Keep it up and you will unlock more hidden motions.',
      '今日はペースが安定しています。このままいくと、隠しモーションがもっと開きます。',
    ),
    PetMood.lazy => _t(
      '还有几件事在等你，长按宠物把小球拖到日期上，就能快速记一条。',
      'A few things are still waiting. Long press your pup and drag the ball onto a date to add one fast.',
      'まだいくつか待ちぼうけ中です。わんこを長押ししてボールを日付にのせると、さっと予定を追加できます。',
    ),
    PetMood.sad => _t(
      '有几件事拖住啦，先清清积压，狗狗也会跟着元气回来。',
      'A few overdue tasks are weighing things down. Clear the pile and your pup will perk back up.',
      'いくつか期限すぎがたまっています。先に片づけると、わんこも元気を取り戻します。',
    ),
  };

  String sceneLabel(SceneMode mode) => switch (mode) {
    SceneMode.home => _t('宅家', 'At home', 'おうち'),
    SceneMode.working => _t('工作中', 'Working', 'お仕事中'),
    SceneMode.walking => _t('散步中', 'On a walk', 'おさんぽ中'),
    SceneMode.resting => _t('休息中', 'Resting', 'ひと休み中'),
    SceneMode.caring => _t('陪伴中', 'Keeping you company', 'そばにいるよ'),
  };

  String categoryLabel(CalendarCategory category) => switch (category) {
    CalendarCategory.daily => _t('日常', 'Everyday', 'いつものこと'),
    CalendarCategory.work => _t('工作', 'Work', '仕事'),
    CalendarCategory.anniversary => _t('纪念日', 'Milestone', '記念日'),
    CalendarCategory.pet => _t('毛孩子', 'Pup', 'わんこ'),
  };

  String breedLabel(PetBreed breed) => switch (breed) {
    PetBreed.shiba => _t('柴犬', 'Shiba Inu', '柴犬'),
    PetBreed.goldenRetriever => _t('金毛', 'Golden Retriever', 'ゴールデンレトリバー'),
    PetBreed.beagle => _t('比格', 'Beagle', 'ビーグル'),
    PetBreed.husky => _t('哈士奇', 'Husky', 'ハスキー'),
    PetBreed.samoyed => _t('萨摩耶', 'Samoyed', 'サモエド'),
  };

  String performanceTierLabel(PerformanceTier tier) => switch (tier) {
    PerformanceTier.rich => _t('精致', 'Polished', 'しっかり'),
    PerformanceTier.balanced => _t('均衡', 'Balanced', 'ほどよく'),
    PerformanceTier.lite => _t('轻盈', 'Light', 'かるめ'),
  };

  String fallbackCalendarTitle() =>
      _t('还没命名的日历', 'Untitled calendar', 'まだ名前のないカレンダー');
  String fallbackCalendarSource() => _t('其他', 'Other', 'そのほか');

  String notificationDebugTitle(String title) =>
      _t('$title · 调试提醒', '$title · Preview ping', '$title ・おためし通知');
  String notificationDebugBody(int minutes) => _t(
    '先给你预览一下，原提醒设在提前 $minutes 分钟。',
    'Here is a quick preview. The original reminder is set for $minutes minutes early.',
    'まずはプレビューです。本番では $minutes 分前にお知らせします。',
  );
  String notificationDebugBodyWithDescription(
    String description,
    int minutes,
  ) => _t(
    '$description\n调试预览：提前 $minutes 分钟',
    '$description\nPreview: $minutes minutes early',
    '$description\nプレビュー: $minutes 分前にお知らせ',
  );
  String notificationStartingSoon(CalendarCategory category) => _t(
    '快开始啦 · ${categoryLabel(category)}',
    'Coming up soon · ${categoryLabel(category)}',
    'もうすぐです · ${categoryLabel(category)}',
  );
  String get notificationChannelName =>
      _t('DoggyLog 任务提醒', 'DoggyLog Tasks', 'DoggyLog タスク通知');
  String get notificationChannelDescription => _t(
    'DoggyLog 日历任务的提醒通知。',
    'Task reminders for DoggyLog calendar entries.',
    'DoggyLog カレンダー予定の通知です。',
  );

  String get messageBiometricUnsupportedSkipped => _t(
    '这台设备不支持 Face ID / Touch ID，所以先跳过应用解锁啦。',
    'This device does not support Face ID / Touch ID, so app lock was skipped.',
    'この端末は Face ID / Touch ID に対応していないため、アプリロックをスキップしました。',
  );
  String get messageBiometricUnsupported => _t(
    '这台设备不支持 Face ID / Touch ID',
    'This device does not support Face ID / Touch ID.',
    'この端末は Face ID / Touch ID に対応していません。',
  );
  String get messageBiometricFailed => _t(
    '生物识别验证没通过，应用解锁还没打开。',
    'Biometric verification did not go through, so app unlock stayed off.',
    '生体認証が通らなかったので、アプリのロック解除はまだオフです。',
  );
  String get messageBiometricEnabled => _t(
    'Face ID / Touch ID 解锁已经打开啦',
    'Face ID / Touch ID unlock is on now.',
    'Face ID / Touch ID での解除をオンにしました。',
  );
  String get messageBiometricDisabled =>
      _t('生物识别解锁已经关闭', 'Biometric unlock is off now.', '生体認証での解除をオフにしました。');
  String get messageUnlocked => _t(
    'DoggyLog 已经解锁啦',
    'DoggyLog is unlocked now.',
    'DoggyLog のロックを解除しました。',
  );
  String get messageUnlockFailed => _t(
    '解锁失败了，再试一次吧',
    'Unlock did not go through. Please try again.',
    '解除できませんでした。もう一度試してみてください。',
  );
  String get messageSyncedToIosCalendar =>
      _t('已经同步到 iOS 日历啦', 'Synced to iOS Calendar.', 'iOS カレンダーに同期しました。');
  String messageSyncedTasksToIosCalendar(int count) => _t(
    '已经同步了 $count 条任务到 iOS 日历',
    'Sent $count tasks to iOS Calendar.',
    '$count 件のタスクを iOS カレンダーへ送りました。',
  );
  String get messageNotificationPermissionOn =>
      _t('通知权限已经打开啦', 'Notifications are on now.', '通知はオンになりました。');
  String get messageNotificationPermissionOff =>
      _t('通知权限还没有打开', 'Notifications are still off.', '通知はまだオフです。');
  String get messageCalendarPermissionDenied =>
      _t('还没有拿到日历权限', 'Calendar access is still off.', 'カレンダー権限はまだオフです。');
  String get messageLocationPermissionEnabled => _t(
    '定位权限已经打开，地理围栏开始工作啦。',
    'Location access is on, and geofencing has started.',
    '位置情報をオンにして、ジオフェンスも動き始めました。',
  );
  String get messageLocationPermissionDenied =>
      _t('还没有拿到定位权限', 'Location access is still off.', '位置情報はまだオフです。');
  String get messageLocationOutsideGeofence => _t(
    '现在的位置还不在预设围栏里',
    'You are outside the saved geofences right now.',
    'いまは保存した囲いの外にいます。',
  );
  String messageEnteredGeofence(String placeName, SceneMode scene) {
    final localizedPlaceName = localizedStoredText(placeName);
    return _t(
      '已经进入 $localizedPlaceName · ${sceneLabel(scene)}',
      'Entered $localizedPlaceName · ${sceneLabel(scene)}',
      '$localizedPlaceName に入りました ・ ${sceneLabel(scene)}',
    );
  }

  String messagePrefixImportedSystemCalendarSnapshot() => _t(
    '已经导入系统日历快照',
    'Imported the system calendar snapshot',
    'システムカレンダーのスナップショットを取り込みました',
  );
  String messagePrefixSystemCalendarScopeUpdated() => _t(
    '系统日历展示范围已经更新',
    'Updated which system calendars are shown',
    '表示するシステムカレンダー範囲を更新しました',
  );
  String get messageIncrementalCalendarSyncFailed => _t(
    '系统日历增量同步失败了',
    'Incremental system calendar sync did not go through.',
    'システムカレンダーの差分同期に失敗しました。',
  );
  String get messageIncrementalCalendarSyncPrefix => _t(
    '系统日历已经完成增量同步',
    'System calendars synced incrementally',
    'システムカレンダーを差分同期しました',
  );
  String messageIncrementalCalendarSyncResult(
    String prefix,
    int changeCount,
    int visibleCount,
  ) => _t(
    '$prefix：这次有 $changeCount 条变更，当前可见 $visibleCount 条事件',
    '$prefix: $changeCount changes, $visibleCount events visible now',
    '$prefix: $changeCount 件変わって、いま見えている予定は $visibleCount 件です',
  );

  String localizedSkinStyleName(String value) {
    return switch (value) {
      '积木学堂' => _t('积木学堂', 'Studio Blocks', 'スタジオブロック'),
      '数据透明' => _t('数据透明', 'Glass Notes', 'ガラスノート'),
      'AI 对话' => _t('AI 对话', 'AI Glow', 'AI グロウ'),
      '健康轻灵' => _t('健康轻灵', 'Soft Wellness', 'やわらかウェルネス'),
      '云朵温柔' => _t('云朵温柔', 'Cloud Softness', 'くもやわらか'),
      _ => value,
    };
  }

  String localizedSkinDescription(AppSkinSpec spec) {
    if (spec.styleDescription.isNotEmpty) {
      return spec.styleDescription;
    }
    return switch (spec.styleName) {
      '积木学堂' => _t(
        '暖暖的、脆脆的，像贴纸手账一样清爽有活力。',
        'Warm, crisp, and cheerful like a sticker-filled study journal.',
        'あたたかくて軽やかで、シール手帳みたいに元気な雰囲気です。',
      ),
      '数据透明' => _t(
        '更冷静一点的玻璃感，适合信息多、节奏快的时候。',
        'A cooler glassy mood that works nicely when screens get busy.',
        '少しクールなガラス感で、情報量が多い場面でもすっきり見えます。',
      ),
      'AI 对话' => _t(
        '有点未来感的蓝紫层次，很适合聊天、记录和灵感冒泡。',
        'Blue-violet layers with a future glow, great for chats, notes, and little sparks of ideas.',
        '少し未来っぽい青紫レイヤーで、おしゃべりや記録、ひらめきメモにぴったりです。',
      ),
      '健康轻灵' => _t(
        '通透又轻盈，看起来很会照顾生活节奏。',
        'Clear and airy, with a rhythm that feels kind to everyday care.',
        '透け感があって軽やかで、毎日のケアにやさしく寄り添う感じです。',
      ),
      '云朵温柔' => _t(
        '柔柔的粉白色调，很适合陪伴感和小纪念。',
        'Soft pink-white tones that feel sweet for companionship and tiny milestones.',
        'やわらかなピンクホワイトで、寄り添い感や小さな記念日に似合います。',
      ),
      _ => spec.styleDescription,
    };
  }

  String localizedStoredText(String value) {
    return switch (value) {
      SeedCopyKey.taskMorningWalkTitle ||
      '早安遛遛' ||
      '晨间遛弯' ||
      'Morning walk' ||
      '朝の散歩' => _t('晨间遛弯', 'Morning stroll', '朝のおさんぽ'),
      SeedCopyKey.taskMorningWalkDescription ||
      '带 Mochi 出门透透气，回来前记得把水也添上。' ||
      '带 Mochi 出门散步，顺手补充饮水。' ||
      'Take Mochi out for a walk and refill water on the way.' ||
      'Mochi を散歩に連れ出し、そのついでに水を補充します。' => _t(
        '带 Mochi 出门散步，顺手补充饮水。',
        'Take Mochi out for a little stroll and top up the water on the way back.',
        'Mochi と少しおさんぽして、帰る前にお水も足しておきます。',
      ),
      SeedCopyKey.taskProductReviewTitle ||
      '产品小会' ||
      '产品评审' ||
      'Product review' ||
      'プロダクトレビュー' => _t('产品评审', 'Product check-in', 'プロダクトチェック'),
      SeedCopyKey.taskProductReviewDescription ||
      '看看 DoggyLog 首页交互和 Widget 数据有没有都准备好。' ||
      '确认 DoggyLog 首屏交互和 Widget 数据源。' ||
      'Review DoggyLog home interactions and widget data sources.' ||
      'DoggyLog のホーム画面操作とウィジェットデータソースを確認します。' => _t(
        '确认 DoggyLog 首屏交互和 Widget 数据源。',
        'Review DoggyLog home interactions and make sure widget data is all set.',
        'DoggyLog のホーム操作とウィジェット用データが整っているか確認します。',
      ),
      SeedCopyKey.taskVaccineDueTitle ||
      '疫苗补打提醒' ||
      '疫苗到期提醒' ||
      'Vaccine due reminder' ||
      'ワクチン期限リマインダー' => _t(
        '疫苗到期提醒',
        'Vaccine booster reminder',
        'ワクチン追加リマインダー',
      ),
      SeedCopyKey.taskVaccineDueDescription ||
      '记得再确认一下宠物医院预约时间。' ||
      '确认宠物医院预约时间。' ||
      'Confirm the veterinary appointment time.' ||
      '動物病院の予約時刻を確認します。' => _t(
        '确认宠物医院预约时间。',
        'Double-check the vet appointment time.',
        '動物病院の予約時間をもう一度確認します。',
      ),
      SeedCopyKey.countdownMochiBirthdayTitle ||
      'Mochi 生日' ||
      'Mochi Birthday' ||
      'Mochi の誕生日' => _t('Mochi 生日', 'Mochi’s birthday', 'Mochi のおたんじょうび'),
      SeedCopyKey.countdownAnnualCheckupTitle ||
      '年度体检小提醒' ||
      '年度体检' ||
      'Annual checkup' ||
      '年次健診' => _t('年度体检', 'Annual wellness check', '年に一度の健診'),
      SeedCopyKey.templateWalk30Title ||
      '遛遛 30 分钟' ||
      '遛弯 30 分钟' ||
      '30-minute walk' ||
      '30分の散歩' => _t('遛遛 30 分钟', '30-minute stroll', '30分のおさんぽ'),
      SeedCopyKey.templateFeedTitle ||
      '该喂饭啦' ||
      '喂食提醒' ||
      'Feeding reminder' ||
      '食事リマインダー' => _t('该喂饭啦', 'Time to feed', 'ごはんの時間'),
      SeedCopyKey.templateGroomingTitle ||
      '洗香香预约' ||
      '洗护预约' ||
      'Grooming appointment' ||
      'グルーミング予約' => _t('洗香香预约', 'Spa day appointment', 'お手入れ予約'),
      SeedCopyKey.templateFocusTitle ||
      '专注一下' ||
      '深度工作块' ||
      'Focus block' ||
      '集中ブロック' => _t('专注一下', 'Focus hour', '集中タイム'),
      SeedCopyKey.geofenceHomeName ||
      '在家' ||
      '家' ||
      'Home' => _t('在家', 'Home', '家'),
      SeedCopyKey.geofenceOfficeName ||
      '办公室' ||
      '办公地点' ||
      'Office' => _t('办公室', 'Office', 'オフィス'),
      SeedCopyKey.geofenceParkName ||
      '公园' ||
      'Park' ||
      '公園' => _t('公园', 'Park', '公園'),
      _ => value,
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

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => AppLocalizations.supportedLocales.any(
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
