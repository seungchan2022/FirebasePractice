import ComposableArchitecture
import SwiftUI

// MARK: - HomePage

struct HomePage {
  @Bindable var store: StoreOf<HomeReducer>
}

// MARK: View

extension HomePage: View {
  var body: some View {
    VStack(spacing: 40) {
      Spacer()
      Text("Second Page")

      Button(action: { store.send(.onTapBack) }) {
        Text("Go To Back!")
      }

      Spacer()
    }
  }
}
