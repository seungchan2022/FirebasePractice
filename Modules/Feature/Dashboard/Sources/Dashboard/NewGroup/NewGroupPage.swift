import ComposableArchitecture
import DesignSystem
import Domain
import SwiftUI

// MARK: - NewGroupPage

struct NewGroupPage {
  @Bindable var store: StoreOf<NewGroupReducer>

  @State private var showAlert = false

}

extension NewGroupPage {

  // MARK: Internal

  @MainActor
  func handleUserSelection(_ user: UserEntity.User.Response) {
    // 12명 이상 선택되었는지 확인
    guard store.selectedUserList.count < 12 else {
      showAlert = true
      return
    }

    store.selectedUserList = isUserSelected(user)
      ? store.selectedUserList.filter { $0.uid != user.uid } // 이미 선택된 경우 삭제
      : store.selectedUserList + [user] // 선택되지 않은 경우 추가
  }

  @MainActor
  func isUserSelected(_ user: UserEntity.User.Response) -> Bool {
    store.selectedUserList.contains { $0.uid == user.uid }
  }

  // MARK: Private

  @MainActor
  private var showSelectedUser: Bool {
    !store.selectedUserList.isEmpty
  }

  @MainActor
  private var disableNextButton: Bool {
    store.selectedUserList.isEmpty || store.groupName.isEmpty
  }

  @MainActor
  private var isLoading: Bool {
    store.fetchUserList.isLoading
  }
}

// MARK: View

extension NewGroupPage: View {
  var body: some View {
    ScrollView {
      LazyVStack(spacing: 32) {
        TextField("그룹 이름", text: $store.groupName)
          .padding(.leading)
          .frame(maxWidth: .infinity)
          .frame(height: 60)
          .overlay {
            RoundedRectangle(cornerRadius: 16)
              .stroke(.black.opacity(0.2), lineWidth: 2)
          }
          .textInputAutocapitalization(.never)
          .autocorrectionDisabled(true)
          .padding(.horizontal, 16)

        Divider()

        if showSelectedUser {
          VStack(alignment: .leading, spacing: .zero) {
            Text("선택된 유저")
              .font(.headline)
              .foregroundStyle(Color(.black))
              .padding(.horizontal, 16)

            ScrollView(.horizontal) {
              HStack(spacing: 12) {
                ForEach(store.selectedUserList, id: \.uid) { item in
                  VStack {
                    Circle()
                      .fill(.gray)
                      .frame(width: 60, height: 60)
                      .overlay(alignment: .topTrailing) {
                        Button(action: {
                          handleUserSelection(item)
                        }) {
                          Image(systemName: "xmark")
                            .imageScale(.small)
                            .foregroundStyle(.white)
                            .fontWeight(.semibold)
                            .padding(5)
                            .background(Color(.systemGray2))
                            .clipShape(Circle())
                        }
                      }

                    Text(item.userName ?? "")
                  }
                }
              }
              .padding(12)
            }
            .scrollIndicators(.hidden)
            .overlay {
              RoundedRectangle(cornerRadius: 16)
                .stroke(.black.opacity(0.2), lineWidth: 2)
            }
            .padding(12)
          }

          Divider()
        }

        ForEach(store.userList, id: \.uid) { user in
          ItemComponent(
            viewState: .init(user: user),
            tapAction: {
              handleUserSelection(user)
            }) {
              Spacer()

              if isUserSelected(user) {
                Image(systemName: "checkmark.circle.fill")
                  .foregroundStyle(Color(.blue))
                  .imageScale(.large)
              } else {
                Image(systemName: "circle")
                  .foregroundStyle(Color(.systemGray4))
                  .imageScale(.large)
              }
            }
            .onAppear {
              guard let last = store.userList.last, last.uid == user.uid else { return }
              guard !store.fetchUserList.isLoading else { return }
              guard store.lastUser?.uid != last.uid else { return }
              store.lastUser = last
              store.send(.getUserList(10, store.userList.last))
            }
        }
      }
      .padding(.top, 32)
    }
    .animation(.easeInOut, value: showSelectedUser)
    .toolbar {
      leadingItem()
      titleView()
      trailingItem()
    }
    .setRequestFlightView(isLoading: isLoading)
    .onAppear {
      store.send(.getUserList(10, store.userList.last))
    }
    .alert(
      "최대 12명까지만 선택할 수 있습니다",
      isPresented: $showAlert)
    {
      Button(role: .cancel ,action: { showAlert = false }) {
        Text("확인")
      }
    }
  }
}

extension NewGroupPage {
  @ToolbarContentBuilder
  private func leadingItem() -> some ToolbarContent {
    ToolbarItem(placement: .topBarLeading) {
      Button(action: { store.send(.routeToClose) }) {
        Image(systemName: "xmark")
      }
    }
  }

  @ToolbarContentBuilder
  @MainActor
  private func titleView() -> some ToolbarContent {
    ToolbarItem(placement: .principal) {
      VStack {
        Text("Add Users")
          .bold()

        Text("\(store.selectedUserList.count)/\(12)")
          .foregroundStyle(.gray)
          .font(.footnote)
      }
    }
  }

  @ToolbarContentBuilder
  @MainActor
  private func trailingItem() -> some ToolbarContent {
    ToolbarItem(placement: .topBarTrailing) {
      Button(action: { store.send(.onTapNewGroup) }) {
        Text("완료")
          .bold()
      }
      .disabled(disableNextButton)
    }
  }
}
