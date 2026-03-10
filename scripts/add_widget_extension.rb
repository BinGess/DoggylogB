#!/usr/bin/env ruby
# frozen_string_literal: true
#
# add_widget_extension.rb
# 将 DoggyLogWidgets Extension 正式注册到 Runner.xcodeproj，
# 同时创建 Info.plist、Entitlements，以便 iOS 桌面组件选择器能找到插件。

require 'xcodeproj'
require 'fileutils'

# ── 常量 ─────────────────────────────────────────────────────────────────────
PROJECT_PATH     = File.expand_path('../ios/Runner.xcodeproj', __dir__)
IOS_DIR          = File.expand_path('../ios', __dir__)
WIDGET_EXT_NAME  = 'DoggyLogWidgets'
TEAM_ID          = '742UUCBN9G'
MAIN_BUNDLE_ID   = 'com.example.doggylog'
WIDGET_BUNDLE_ID = "#{MAIN_BUNDLE_ID}.#{WIDGET_EXT_NAME}"
APP_GROUP        = 'group.com.example.doggylog'
DEPLOY_TARGET    = '14.0'

project = Xcodeproj::Project.open(PROJECT_PATH)

# ── Guard ────────────────────────────────────────────────────────────────────
if project.targets.any? { |t| t.name == WIDGET_EXT_NAME }
  puts "✅  Widget Extension target already exists — nothing to do."
  exit 0
end

runner_target = project.targets.find { |t| t.name == 'Runner' }
abort("❌  Runner target not found") unless runner_target

# ── 1. 创建目录（DoggyLogWidgets/）存放 Info.plist + Entitlements ─────────────
widget_dir = File.join(IOS_DIR, WIDGET_EXT_NAME)
FileUtils.mkdir_p(widget_dir)
puts "📁  #{widget_dir}"

# ── 2. 生成 Widget Extension Info.plist ──────────────────────────────────────
info_plist_path = File.join(widget_dir, 'Info.plist')
File.write(info_plist_path, <<~XML)
  <?xml version="1.0" encoding="UTF-8"?>
  <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
    "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
  <plist version="1.0">
  <dict>
    <key>NSExtension</key>
    <dict>
      <key>NSExtensionPointIdentifier</key>
      <string>com.apple.widgetkit-extension</string>
    </dict>
  </dict>
  </plist>
XML
puts "📝  Info.plist"

# ── 3. 生成 Widget Extension Entitlements（App Group）─────────────────────────
entitle_path = File.join(widget_dir, "#{WIDGET_EXT_NAME}.entitlements")
File.write(entitle_path, <<~XML)
  <?xml version="1.0" encoding="UTF-8"?>
  <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
    "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
  <plist version="1.0">
  <dict>
    <key>com.apple.security.application-groups</key>
    <array>
      <string>#{APP_GROUP}</string>
    </array>
  </dict>
  </plist>
XML
puts "📝  #{WIDGET_EXT_NAME}.entitlements"

# ── 4. 生成 Runner.entitlements（主 App 也需要 App Group）───────────────────
runner_entitle_path = File.join(IOS_DIR, 'Runner', 'Runner.entitlements')
File.write(runner_entitle_path, <<~XML)
  <?xml version="1.0" encoding="UTF-8"?>
  <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
    "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
  <plist version="1.0">
  <dict>
    <key>com.apple.security.application-groups</key>
    <array>
      <string>#{APP_GROUP}</string>
    </array>
  </dict>
  </plist>
XML
puts "📝  Runner/Runner.entitlements"

# ── 5. 在 Xcode project 中添加 Widget Extension Target ───────────────────────
widget_target = project.new_target(
  :app_extension,
  WIDGET_EXT_NAME,
  :ios,
  DEPLOY_TARGET,
  nil,
  :swift
)
puts "🎯  Created target: #{WIDGET_EXT_NAME}"

# ── 6. 配置所有 Build Configuration 的 Build Settings ────────────────────────
widget_target.build_configurations.each do |config|
  s = config.build_settings
  s.delete('ASSETCATALOG_COMPILER_APPICON_NAME')
  s['APPLICATION_EXTENSION_API_ONLY'] = 'YES'
  s['CODE_SIGN_ENTITLEMENTS']         = "#{WIDGET_EXT_NAME}/#{WIDGET_EXT_NAME}.entitlements"
  s['CODE_SIGN_STYLE']                = 'Automatic'
  s['DEVELOPMENT_TEAM']               = TEAM_ID
  s['GENERATE_INFOPLIST_FILE']        = 'NO'
  s['INFOPLIST_FILE']                 = "#{WIDGET_EXT_NAME}/Info.plist"
  s['IPHONEOS_DEPLOYMENT_TARGET']     = DEPLOY_TARGET
  s['LD_RUNPATH_SEARCH_PATHS']        = '$(inherited) @executable_path/../../Frameworks'
  s['PRODUCT_BUNDLE_IDENTIFIER']      = WIDGET_BUNDLE_ID
  s['PRODUCT_NAME']                   = '$(TARGET_NAME)'
  s['SKIP_INSTALL']                   = 'YES'
  s['SWIFT_VERSION']                  = '5.0'
  s['TARGETED_DEVICE_FAMILY']         = '1,2'
  s['ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES'] = 'NO'
  if config.name == 'Debug'
    s['SWIFT_OPTIMIZATION_LEVEL'] = '-Onone'
    s['DEBUG_INFORMATION_FORMAT']  = 'dwarf'
    s['ONLY_ACTIVE_ARCH']          = 'YES'
  else
    s['SWIFT_OPTIMIZATION_LEVEL'] = '-Owholemodule'
    s['DEBUG_INFORMATION_FORMAT']  = 'dwarf-with-dsym'
    s['VALIDATE_PRODUCT']          = 'YES'
  end
end
puts "⚙️   Build settings configured (#{widget_target.build_configurations.map(&:name).join(', ')})"

# ── 7. 添加 App Group Entitlements 到 Runner ──────────────────────────────────
runner_target.build_configurations.each do |config|
  config.build_settings['CODE_SIGN_ENTITLEMENTS'] = 'Runner/Runner.entitlements'
end
puts "🔐  Runner entitlements linked"

# ── 8. 创建 Extensions 文件组，添加 Swift 源文件 ─────────────────────────────
ext_group = project.main_group.new_group('Extensions', 'Extensions', '<group>')

swift_files = Dir.glob(File.join(IOS_DIR, 'Extensions', '*.swift')).sort.map { |f| File.basename(f) }
sources_phase = widget_target.source_build_phase

swift_files.each do |filename|
  ref = ext_group.new_file(filename)
  ref.last_known_file_type = 'sourcecode.swift'
  ref.source_tree = '<group>'
  sources_phase.add_file_reference(ref)
  puts "  📄  #{filename}"
end

# ── 9. 创建 DoggyLogWidgets 文件组（Info.plist + Entitlements）─────────────────
widget_group = project.main_group.new_group(WIDGET_EXT_NAME, WIDGET_EXT_NAME, '<group>')
widget_group.new_file('Info.plist')
widget_group.new_file("#{WIDGET_EXT_NAME}.entitlements")
puts "📂  #{WIDGET_EXT_NAME}/ group created"

# ── 10. 链接 WidgetKit + SwiftUI 系统框架 ────────────────────────────────────
fwk_phase = widget_target.frameworks_build_phase
fwk_group  = project.frameworks_group

[
  ['WidgetKit.framework',   'wrapper.framework'],
  ['SwiftUI.framework',     'wrapper.framework'],
].each do |name, type|
  ref = fwk_group.new_reference("System/Library/Frameworks/#{name}")
  ref.name = name
  ref.source_tree = 'SDKROOT'
  ref.last_known_file_type = type
  ref.path = "System/Library/Frameworks/#{name}"
  fwk_phase.add_file_reference(ref, true)
  puts "  🔗  #{name}"
end

# ── 11. Runner 依赖 DoggyLogWidgets ──────────────────────────────────────────
runner_target.add_dependency(widget_target)
puts "↩️   Runner → #{WIDGET_EXT_NAME} dependency added"

# ── 12. Runner 嵌入 Widget Extension（Embed App Extensions 阶段）──────────────
embed_phase = runner_target.build_phases.find do |p|
  p.is_a?(Xcodeproj::Project::Object::PBXCopyFilesBuildPhase) &&
    p.name == 'Embed App Extensions'
end

unless embed_phase
  embed_phase = project.new(Xcodeproj::Project::Object::PBXCopyFilesBuildPhase)
  embed_phase.name                               = 'Embed App Extensions'
  embed_phase.dst_subfolder_spec                 = '13'   # PlugIns
  embed_phase.build_action_mask                  = '2147483647'
  embed_phase.run_only_for_deployment_postprocessing = '0'
  runner_target.build_phases << embed_phase
  puts "➕  'Embed App Extensions' phase added to Runner"
end

embed_file = project.new(Xcodeproj::Project::Object::PBXBuildFile)
embed_file.file_ref = widget_target.product_reference
embed_file.settings = { 'ATTRIBUTES' => ['RemoveHeadersOnCopy'] }
embed_phase.files << embed_file
puts "📦  Widget .appex embedded into Runner"

# ── 13. 保存 ─────────────────────────────────────────────────────────────────
project.save
puts "\n✅  Runner.xcodeproj saved — DoggyLogWidgets target is now wired in!"
