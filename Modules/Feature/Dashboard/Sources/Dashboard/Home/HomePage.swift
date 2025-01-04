import ComposableArchitecture
import DesignSystem
import SwiftUI

// MARK: - HomePage

struct HomePage {
  @Bindable var store: StoreOf<HomeReducer>
}

extension HomePage {
  @MainActor
  private var isLoading: Bool {
    store.fetchDBUser.isLoading
      || store.fetchUpdateStatus.isLoading
  }

  @MainActor
  private var isActiveUpdatePassword: Bool {
    !store.currPasswordText.isEmpty && !store.newPasswordText.isEmpty
  }

  @MainActor
  private var isSelectedItem: (String) -> Bool {
    { item in
      store.dbUser?.wishList?.contains(item) == true
    }
  }

}

// MARK: View

extension HomePage: View {
  var body: some View {
    List {
      if let user = store.dbUser {
        Section {
          Text("uid: \(user.uid)")
          Text("email: \(user.email ?? "No Email")")
          Text("user_name: \(user.userName ?? "No Name")")
          Text("created: \(user.created ?? Date())")
          Text("photoURL: \(user.photoURL ?? "No PhotoURL")")

          Button(action: { store.send(.onTapUpdateStatus) }) {
            Text("User is Premium: \((user.isPremium ?? false).description.capitalized)")
          }
        } header: {
          Text("프로필")
        }

        Section {
          HStack {
            ForEach(store.wishList, id: \.self) { item in
              Button(action: {
                if isSelectedItem(item) {
                  store.send(.onTapRemoveItem(item))
                } else {
                  store.send(.onTapWishItem(item))
                }
              }) {
                Text(item)
              }
              .font(.headline)
              .buttonStyle(.borderedProminent)
              .tint(isSelectedItem(item) ? Color.red : Color.green)
            }
          }

          Text("WishList \((user.wishList ?? []).joined(separator: ", "))")
        } header: {
          Text("WishList")
        }

        Section {
          Button(action: {
            if user.movie == .none {
              store.send(.onTapAddMovieItem)
            } else {
              store.send(.onTapRemoveMovieItem)
            }
          }) {
            Text("Favorite Movie \(user.movie?.title ?? "")")
          }
        } header: {
          Text("Favorite Movie")
        }

        if store.providerList.contains(.email) {
          Section {
            Button(action: {
              store.currPasswordText = ""
              store.newPasswordText = ""
              store.isShowUpdatePassword = true
            }) {
              Text("비밀번호 변경")
            }
          }
        }

        Section {
          Button(action: { store.isShowSignOutAlert = true }) {
            Text("로그아웃")
          }
        }

        if store.providerList.contains(.email) {
          Section {
            Button(role: .destructive, action: {
              store.isShowDeleteUserAlert = true
              store.passwordText = ""
            }) {
              Text("이메일 계정 탈퇴")
            }

            Button(role: .destructive, action: {
              store.isShowDeleteKakaoUserAlert = true

            }) {
              Text("카카오 계정 탈퇴")
            }
          }
        }

        if store.providerList.contains(.google) {
          Section {
            Button(role: .destructive, action: {
              store.isShowDeleteGoogleUserAlert = true
            }) {
              Text("구글 계정 탈퇴")
            }
          }
        }

        if store.providerList.contains(.apple) {
          Section {
            Button(role: .destructive, action: {
              store.isShowDeleteAppleUserAlert = true
            }) {
              Text("애플 계정 탈퇴")
            }
          }
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
            .opacity(isActiveUpdatePassword ? 1.0 : 0.3)
        }
        .disabled(!isActiveUpdatePassword)
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
    .alert(
      "카카오 계정을 탈퇴하시겟습니까?",
      isPresented: $store.isShowDeleteKakaoUserAlert)
    {
      Button(role: .destructive, action: { store.send(.onTapDeleteKakaoUser) }) {
        Text("확인")
      }

      Button(role: .cancel, action: { store.isShowDeleteKakaoUserAlert = false }) {
        Text("취소")
      }
    } message: {
      Text("계정을 탈퇴 하려면, 확인 버튼을 눌러주세요.")
    }
    .alert(
      "구글 계정을 탈퇴하시겟습니까?",
      isPresented: $store.isShowDeleteGoogleUserAlert)
    {
      Button(role: .destructive, action: { store.send(.onTapDeleteGoogleUser) }) {
        Text("확인")
      }

      Button(role: .cancel, action: { store.isShowDeleteGoogleUserAlert = false }) {
        Text("취소")
      }
    } message: {
      Text("계정을 탈퇴 하려면, 확인 버튼을 눌러주세요.")
    }
    .alert(
      "애플 계정을 탈퇴하시겟습니까?",
      isPresented: $store.isShowDeleteAppleUserAlert)
    {
      Button(role: .destructive, action: { store.send(.onTapDeleteAppleUser) }) {
        Text("확인")
      }

      Button(role: .cancel, action: { store.isShowDeleteAppleUserAlert = false }) {
        Text("취소")
      }
    } message: {
      Text("계정을 탈퇴 하려면, 확인 버튼을 눌러주세요.")
    }
    .onAppear {
      store.send(.getDBUser)
      store.send(.getProvider)
    }
    .setRequestFlightView(isLoading: isLoading)
    .onDisappear {
      store.send(.teardown)
    }
  }
}
