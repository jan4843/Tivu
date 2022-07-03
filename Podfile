platform :ios, '15.4'

target 'Tivu' do
  use_frameworks!

  pod 'MobileVLCKit', '~> 3.4.0'

  target 'TivuTests' do
    inherit! :search_paths
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
    end
  end
end
