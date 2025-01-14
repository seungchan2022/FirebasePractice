import ComposableArchitecture
import SwiftUI

// MARK: - FavoritePage

struct FavoritePage {
  @Bindable var store: StoreOf<FavoriteReducer>
}

// MARK: View

extension FavoritePage: View {
  var body: some View {
    VStack {
      Text("Favorite Page")
    }
  }
}
