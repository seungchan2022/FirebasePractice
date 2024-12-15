import ComposableArchitecture
import SwiftUI

// MARK: - SignUpPage

struct SignUpPage {
  @Bindable var store: StoreOf<SignUpReducer>
}

// MARK: View

extension SignUpPage: View {
  var body: some View {
    VStack {
      Spacer()

      Button(action: { store.send(.onTapBack) }) {
        Text("Go Back SignIn")
      }
      Spacer()
    }
  }
}
