import Foundation

private enum DoggyWidgetLanguage {
  case zh
  case en
  case ja

  static var current: DoggyWidgetLanguage {
    let identifier = (Locale.preferredLanguages.first ?? Locale.current.identifier).lowercased()
    if identifier.hasPrefix("en") {
      return .en
    }
    if identifier.hasPrefix("ja") {
      return .ja
    }
    return .zh
  }
}

func widgetText(_ zh: String, _ en: String, _ ja: String) -> String {
  switch DoggyWidgetLanguage.current {
  case .en:
    return en
  case .ja:
    return ja
  case .zh:
    return zh
  }
}

func widgetBreedLabel(_ value: String) -> String {
  switch value.lowercased() {
  case "shiba":
    return widgetText("柴犬", "Shiba Inu", "柴犬")
  case "goldenretriever", "golden retriever":
    return widgetText("金毛", "Golden Retriever", "ゴールデンレトリバー")
  case "beagle":
    return widgetText("比格", "Beagle", "ビーグル")
  case "husky":
    return widgetText("哈士奇", "Husky", "ハスキー")
  case "samoyed":
    return widgetText("萨摩耶", "Samoyed", "サモエド")
  default:
    return value
  }
}

func widgetMoodLabel(_ value: String) -> String {
  switch value.lowercased() {
  case "excited":
    return widgetText("开心", "Excited", "わくわく")
  case "calm":
    return widgetText("平静", "Calm", "おだやか")
  case "lazy":
    return widgetText("犯懒", "Sleepy", "のんびり")
  case "sad":
    return widgetText("有点丧", "Blue", "しょんぼり")
  default:
    return value
  }
}

func widgetSceneLabel(_ value: String) -> String {
  switch value.lowercased() {
  case "home":
    return widgetText("宅家", "At home", "おうち")
  case "working":
    return widgetText("工作中", "Working", "お仕事中")
  case "walking":
    return widgetText("散步中", "On a walk", "おさんぽ中")
  case "resting":
    return widgetText("休息中", "Resting", "ひと休み中")
  case "caring":
    return widgetText("陪伴中", "Keeping you company", "そばにいるよ")
  default:
    return value
  }
}

func widgetMonthLabel(for date: Date) -> String {
  let formatter = DateFormatter()
  formatter.locale = Locale.current
  switch DoggyWidgetLanguage.current {
  case .en:
    formatter.dateFormat = "MMMM yyyy"
  case .ja:
    formatter.dateFormat = "yyyy年M月"
  case .zh:
    formatter.dateFormat = "yyyy 年 MM 月"
  }
  return formatter.string(from: date)
}

func widgetDaysLeftLabel(_ days: Int) -> String {
  switch DoggyWidgetLanguage.current {
  case .en:
    return "\(days)d"
  case .ja:
    return "\(days)日"
  case .zh:
    return "\(days) 天"
  }
}

func widgetShortDateLabel(ms: Int) -> String {
  let date = Date(timeIntervalSince1970: Double(ms) / 1000.0)
  let formatter = DateFormatter()
  formatter.locale = Locale.current
  switch DoggyWidgetLanguage.current {
  case .en:
    formatter.dateFormat = "MMM d"
    return "Due \(formatter.string(from: date))"
  case .ja:
    formatter.dateFormat = "M月d日"
    return "\(formatter.string(from: date)) まで"
  case .zh:
    formatter.dateFormat = "M月d日"
    return "\(formatter.string(from: date)) 截止"
  }
}
