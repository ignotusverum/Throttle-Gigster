
target 'Throttle' do
use_frameworks!

pod 'SwiftyJSON', '2.3.1'
pod 'Alamofire', '3.5.0'
pod 'Fabric'
pod 'Crashlytics'
pod 'MBProgressHUD'
pod 'SDWebImage'
pod 'ITRAirSideMenu', '~> 1.0.3'
pod 'TSMessages', :git => 'https://github.com/KrauseFx/TSMessages.git'
pod 'RealmSwift'
pod 'Locksmith', '2.0.8'

pod 'AWSCore'
pod 'AWSAutoScaling'
pod 'AWSCloudWatch'
pod 'AWSDynamoDB'
pod 'AWSEC2'
pod 'AWSElasticLoadBalancing'
pod 'AWSIoT'
pod 'AWSKinesis'
pod 'AWSLambda'
pod 'AWSMachineLearning'
pod 'AWSMobileAnalytics'
pod 'AWSS3'
pod 'AWSSES'
pod 'AWSSimpleDB'
pod 'AWSSNS'
pod 'AWSSQS'
pod 'AWSCognito'

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |configuration|
            configuration.build_settings['SWIFT_VERSION'] = "2.2"
        end
    end
end

end
