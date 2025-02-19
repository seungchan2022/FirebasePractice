import ComposableArchitecture
import DesignSystem
import Domain
import SwiftUI

// MARK: - NewGroupPage

struct NewGroupPage {
  @Bindable var store: StoreOf<NewGroupReducer>

  @State private var selectedUserList: [UserEntity.User.Response] = []

  @State private var groupName = ""
}

extension NewGroupPage {

  // MARK: Internal

  func handleUserSelection(_ user: UserEntity.User.Response) {
    selectedUserList = isUserSelected(user)
      ? selectedUserList.filter { $0.uid != user.uid } // 이미 선택된 경우 삭제
      : selectedUserList + [user] // 선택되지 않은 경우 추가
  }

  func isUserSelected(_ user: UserEntity.User.Response) -> Bool {
    selectedUserList.contains { $0.uid == user.uid }
  }

  // MARK: Private

  @MainActor
  private var showSelectedUser: Bool {
    !selectedUserList.isEmpty
  }

  private var disableNextButton: Bool {
    selectedUserList.isEmpty || groupName.isEmpty
  }
}

// MARK: View

extension NewGroupPage: View {
  var body: some View {
    ScrollView {
      LazyVStack(spacing: 32) {
        TextField("그룹 이름", text: $groupName)
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
                ForEach(selectedUserList, id: \.uid) { item in
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
    .onAppear {
      store.send(.getUserList)
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
  private func titleView() -> some ToolbarContent {
    ToolbarItem(placement: .principal) {
      VStack {
        Text("Add Users")
          .bold()

        Text("\(selectedUserList.count)/\(12)")
          .foregroundStyle(.gray)
          .font(.footnote)
      }
    }
  }

  @ToolbarContentBuilder
  private func trailingItem() -> some ToolbarContent {
    ToolbarItem(placement: .topBarTrailing) {
      Button(action: { }) {
        Text("완료")
          .bold()
      }
      .disabled(disableNextButton)
    }
  }
}
