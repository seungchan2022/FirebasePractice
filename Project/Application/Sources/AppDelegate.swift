import FirebaseCore
import Foundation
import GoogleSignIn
import KakaoSDKCommon
import LinkNavigator
import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
  let container: AppContainer = .init()

  var dependency: AppSideEffect { container.dependency }
  var navigator: SingleLinkNavigator { container.linkNavigayor }

  func application(
    _: UIApplication,
    didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil)
    -> Bool
  {
    FirebaseApp.configure()

    guard let kakaoAppKey = Bundle.main.infoDictionary?["KAKAO_NATIVE_APP_KEY"] as? String else { return false }
    KakaoSDK.initSDK(appKey: kakaoAppKey)

    return true
  }

  func application(
    _: UIApplication,
    open url: URL,
    options _: [UIApplication.OpenURLOptionsKey: Any] = [:])
    -> Bool
  {
    GIDSignIn.sharedInstance.handle(url)
  }

  func application(
    _: UIApplication,
    configurationForConnecting connectingSceneSession: UISceneSession,
    options _: UIScene.ConnectionOptions)
    -> UISceneConfiguration
  {
    let sceneConfig = UISceneConfiguration(name: .none, sessionRole: connectingSceneSession.role)
    sceneConfig.delegateClass = SceneDelegate.self
    return sceneConfig
  }
}
