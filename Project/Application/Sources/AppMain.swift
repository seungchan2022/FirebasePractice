import Architecture
import LinkNavigator
import SwiftUI

@main
struct AppMain: App {

  @State private var appContainer = AppContainer()

  var body: some Scene {
    WindowGroup {
      LinkNavigationView(
        linkNavigator: appContainer.linkNavigator,
        item: .init(path: Link.Dashboard.Path.sample.rawValue, items: .none))
        .ignoresSafeArea()
    }
  }
}
