import ComposableArchitecture
import DesignSystem
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
        Text("userName: \(store.user.userName ?? "No Name")")
      } header: {
        Text("프로필")
      }

      Section {
        Button(action: { store.isShowUpdatePassword = true }) {
          Text("비밀번호 변경")
        }
      }

      Section {
        Button(action: { store.isShowSignOutAlert = true }) {
          Text("로그아웃")
        }
      }

      Section {
        Button(role: .destructive, action: {
          store.isShowDeleteUserAlert = true
          store.passwordText = ""
        }) {
          Text("계정 탈퇴")
        }
      }
    }
    .sheet(isPresented: $store.isShowUpdatePassword) {
      VStack(spacing: 48) {
        CustomTextField(
          placeholder: "현재 비밀번호",
          errorMessage: .none,
          isSecure: true,
          text: $store.currPasswordText,
          isShowText: $store.isShowCurrPassword)

        CustomTextField(
          placeholder: "변경할 비밀번호",
          errorMessage: .none,
          isSecure: true,
          text: $store.newPasswordText,
          isShowText: $store.isShowNewPassword)

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
    .alert(
      "로그아웃을 하시겠습니까?",
      isPresented: $store.isShowSignOutAlert)
    {
      Button(role: .destructive ,action: { store.send(.onTapSignOut) }) {
        Text("확인")
      }

      Button(role: .cancel, action: { store.isShowSignOutAlert = false }) {
        Text("취소")
      }
    } message: {
      Text("로그아웃을 하려면 확인 버튼을 눌러주세요.")
    }
    .alert(
      "계정을 탈퇴하시겟습니까?",
      isPresented: $store.isShowDeleteUserAlert)
    {
      SecureField("비밀번호", text: $store.passwordText)
        .autocorrectionDisabled(true)
        .textInputAutocapitalization(.never)

      Button(role: .destructive, action: { store.send(.onTapDeleteUser) }) {
        Text("확인")
      }

      Button(role: .cancel, action: { store.isShowDeleteUserAlert = false }) {
        Text("취소")
      }
    } message: {
      Text("계정을 탈퇴 하려면 현재 비밀번호를 입력하고, 확인 버튼을 눌러주세요.")
    }
    .onAppear {
      store.send(.getUser)
    }
    .onDisappear {
      store.send(.teardown)
    }
  }
}
