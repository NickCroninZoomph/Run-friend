import Foundation

enum AppRoute: Hashable {
    case stravaConnect
    case activityPicker
    case photoUpload(RunActivity)
    case styleAndGenerate(RunActivity, Data)
    case result(GeneratedAvatar)
    case paywall
    case settings
}
