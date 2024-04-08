# Uncomment the next line to define a global platform for your project
platform :ios, '15.0'

use_frameworks!
workspace 'AttendanceKit'

# Comment the next line if you're not using Swift and don't want to use dynamic frameworks
def pods
  pod 'TensorFlow-experimental'
  pod 'FaceCropper'
  pod 'Alamofire'
  pod 'RealmSwift'
  pod 'Firebase/Core'
  pod 'Firebase/Database'
  pod 'Firebase/Storage'
  pod 'SDWebImage'
  pod 'RxSwift'
  pod 'RxCocoa'
end

target 'General' do
  project 'General'
  pods
end

target 'Student' do
  project 'Student'
  pods
end

target 'Institution' do
  project 'Institution'
  pods
end

target 'Lecturer' do
  project 'Lecturer'
  pods
end

# Script for the pod installer of the build configurations of each target in the project
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
    end
  end

  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      if config.base_configuration_reference
        xcconfig_path = config.base_configuration_reference.real_path
        xcconfig = File.read(xcconfig_path)
        xcconfig_mod = xcconfig.gsub(/DT_TOOLCHAIN_DIR/, "TOOLCHAIN_DIR")
        File.open(xcconfig_path, "w") { |file| file << xcconfig_mod }
      end
    end
  end
  
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= ['$(inherited)', '_LIBCPP_ENABLE_CXX17_REMOVED_UNARY_BINARY_FUNCTION']
    end
  end
end
