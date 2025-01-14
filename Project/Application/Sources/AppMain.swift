import Architecture
import FirebaseAuth
import LinkNavigator
import SwiftUI

// MARK: - AppMain

struct AppMain {
  let viewModel: AppViewModel
}

// MARK: View

extension AppMain: View {
  var body: some View {
    TabLinkNavigationView(
      linkNavigator: viewModel.linkNavigator,
      isHiddenDefaultTabbar: false,
      tabItemList: [
        .init(
          tag: .zero,
          tabItem: .init(title: "Product", image: UIImage(systemName: "list.clipboard"), tag: .zero),
          linkItem: .init(path: Link.Dashboard.Path.product.rawValue, items: .none),
          prefersLargeTitles: true),
        .init(
          tag: 1,
          tabItem: .init(title: "Favorite", image: UIImage(systemName: "star"), tag: 1),
          linkItem: .init(
            path: Link.Dashboard.Path.favorite.rawValue,
            items: .none),
          prefersLargeTitles: true),
        .init(
          tag: 2,
          tabItem: .init(title: "Profile", image: UIImage(systemName: "person"), tag: 2),
          linkItem: .init(
            path: Auth.auth().currentUser != .none
              ? Link.Dashboard.Path.profile.rawValue
              : Link.Dashboard.Path.signIn.rawValue,
            items: .none),
          prefersLargeTitles: true),
      ])
      .ignoresSafeArea()
  }
}
