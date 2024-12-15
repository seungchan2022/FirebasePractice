import ComposableArchitecture
import SwiftUI

// MARK: - SignInPage

struct SignInPage {
  @Bindable var store: StoreOf<SignInReducer>
}

// MARK: View

extension SignInPage: View {
  var body: some View {
    VStack {
      Spacer()

      Button(action: { store.send(.onTapSignUp) }) {
        Text("Go To SignUp")
      }
      Spacer()
    }
  }
}
