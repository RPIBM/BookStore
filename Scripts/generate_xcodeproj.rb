#!/usr/bin/env ruby
# Generates Bookstore.xcodeproj from the files on disk using the `xcodeproj` gem.
# Usage (from the repository root):  ruby Scripts/generate_xcodeproj.rb
require 'fileutils'
require 'xcodeproj'

ROOT = File.expand_path('..', __dir__)
PROJECT_PATH = File.join(ROOT, 'Bookstore.xcodeproj')
DEPLOYMENT_TARGET = '16.0'
BUNDLE_ID = 'com.example.Bookstore'

FileUtils.rm_rf(PROJECT_PATH)
project = Xcodeproj::Project.new(PROJECT_PATH)
project.root_object.attributes['LastUpgradeCheck'] = '1500'

app = project.new_target(:application, 'Bookstore', :ios, DEPLOYMENT_TARGET)
tests = project.new_target(:unit_test_bundle, 'BookstoreTests', :ios, DEPLOYMENT_TARGET)
tests.add_dependency(app)

def add_tree(project, group, dir, target, skip: [])
  Dir.children(dir).sort.each do |name|
    next if name.start_with?('.') || skip.include?(name)

    path = File.join(dir, name)
    if name.end_with?('.xcassets')
      ref = group.new_file(name)
      target.resources_build_phase.add_file_reference(ref)
    elsif File.directory?(path)
      add_tree(project, group.new_group(name, name), path, target, skip: skip)
    elsif name.end_with?('.swift')
      ref = group.new_file(name)
      target.add_file_references([ref])
    end
  end
end

app_group = project.main_group.new_group('Bookstore', 'Bookstore')
add_tree(project, app_group, File.join(ROOT, 'Bookstore'), app, skip: ['Info.plist'])
app_group.new_file('Info.plist')

tests_group = project.main_group.new_group('BookstoreTests', 'BookstoreTests')
add_tree(project, tests_group, File.join(ROOT, 'BookstoreTests'), tests)

common = {
  'SWIFT_VERSION' => '5.0',
  'IPHONEOS_DEPLOYMENT_TARGET' => DEPLOYMENT_TARGET,
  'TARGETED_DEVICE_FAMILY' => '1,2',
  'CODE_SIGN_STYLE' => 'Automatic',
  'CURRENT_PROJECT_VERSION' => '1',
  'MARKETING_VERSION' => '1.0',
  'GENERATE_INFOPLIST_FILE' => 'NO'
}

app.build_configurations.each do |config|
  config.build_settings.merge!(common)
  config.build_settings.merge!(
    'PRODUCT_BUNDLE_IDENTIFIER' => BUNDLE_ID,
    'INFOPLIST_FILE' => 'Bookstore/Info.plist',
    'ASSETCATALOG_COMPILER_APPICON_NAME' => 'AppIcon',
    'ENABLE_USER_SCRIPT_SANDBOXING' => 'YES'
  )
end

tests.build_configurations.each do |config|
  config.build_settings.merge!(common)
  config.build_settings.merge!(
    'PRODUCT_BUNDLE_IDENTIFIER' => "#{BUNDLE_ID}.Tests",
    'GENERATE_INFOPLIST_FILE' => 'YES',
    'TEST_HOST' => '$(BUILT_PRODUCTS_DIR)/Bookstore.app/Bookstore',
    'BUNDLE_LOADER' => '$(TEST_HOST)'
  )
end

project.save

# Shared scheme so `xcodebuild -scheme Bookstore` works and Xcode shows Run/Test immediately.
scheme = Xcodeproj::XCScheme.new
scheme.add_build_target(app)
scheme.add_test_target(tests)
scheme.set_launch_target(app)
scheme.save_as(PROJECT_PATH, 'Bookstore', true)

puts "Generated #{PROJECT_PATH}"
