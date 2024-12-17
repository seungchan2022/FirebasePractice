import ComposableArchitecture
import SwiftUI

// MARK: - HomePage

struct HomePage {
  @Bindable var store: StoreOf<HomeReducer>
}

// MARK: View

extension HomePage: View {
  var body: some View {
    List {
      Section {
        Text("uid: \(store.user.uid)")
        Text("email: \(store.user.email ?? "No Email")")
      } header: {
        Text("프로필")
      }

      Section {
        Button(action: { store.isShowUpdatePassword = true }) {
          Text("비밀번호 변경")
        }
      } header: {
        Text("유저 정보 변경")
      }

      Button(action: { store.send(.onTapSignOut) }) {
        Text("로그아웃")
      }
    }
    .sheet(isPresented: $store.isShowUpdatePassword) {
      VStack(spacing: 48) {
        TextFieldComponent(
          viewState: .init(),
          text: $store.currPasswordText,
          isShowText: $store.isShowCurrPassword,
          placeholder: "현재 비밀번호",
          errorMessage: .none,
          isSecure: true)

        TextFieldComponent(
          viewState: .init(),
          text: $store.newPasswordText,
          isShowText: $store.isShowNewPassword,
          placeholder: "변경할 비밀번호",
          errorMessage: .none,
          isSecure: true)

        Button(action: { store.send(.onTapUpdatePassword) }) {
          Text("비밀번호 변경")
            .foregroundStyle(.white)
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .background(.blue)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
      }
      .padding(16)
      .presentationDetents([.fraction(0.45)])
    }
    .onAppear {
      store.send(.getUser)
    }
    .onDisappear {
      store.send(.teardown)
    }
  }
}
