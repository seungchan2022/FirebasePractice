import FirebaseCore
import Foundation
import LinkNavigator
import UIKit
import GoogleSignIn

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

    return true
  }

  func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool
  {
    return GIDSignIn.sharedInstance.handle(url)
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
