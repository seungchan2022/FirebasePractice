import Foundation
import LinkNavigator
import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
  let container: AppContainer = .init()

  var dependency: AppSideEffect { container.dependency }
  var navigator: SingleLinkNavigator { container.linkNavigayor }

  func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    true
  }

  func application(
    _: UIApplication,
    open _: URL,
    options _: [UIApplication.OpenURLOptionsKey: Any] = [:])
    -> Bool
  {
    false
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
