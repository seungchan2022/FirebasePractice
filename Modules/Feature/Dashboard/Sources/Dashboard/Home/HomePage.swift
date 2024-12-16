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
      Text(store.user.uid)
      Text(store.user.email ?? "22")
      Text(store.user.photoURL ?? "21")

      Button(action: { store.send(.onTapSignOut) }) {
        Text("로그아웃")
      }

      Spacer()
    }
    .onAppear {
      store.send(.getUser)
    }
  }
}
