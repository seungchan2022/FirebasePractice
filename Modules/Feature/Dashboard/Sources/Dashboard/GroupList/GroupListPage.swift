import ComposableArchitecture
import Domain
import SwiftUI

// MARK: - GroupListPage

struct GroupListPage {
  @Bindable var store: StoreOf<GroupListReducer>

  @State private var isShowAlert = false
  @State private var groupName = ""
}

extension GroupListPage {
  @MainActor
  private var itemList: [GroupListEntity.Group.Item] {
    store.groupList.sorted(by: { $0.dateCreated > $1.dateCreated })
  }
}

// MARK: View

extension GroupListPage: View {
  var body: some View {
    ScrollView {
      LazyVStack {
        ForEach(itemList, id: \.id) { item in
          ItemComponent(
            viewState: .init(item: item),
            tapAction: { store.send(.onTapGroupItem($0)) })
        }
      }
      .padding(.top, 32)
    }
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Button(action: {
          store.send(.routeToNewGroup)
        }) {
          Image(systemName: "square.and.pencil")
        }
      }
    }

    .alert("그룹 설정", isPresented: $isShowAlert) {
      TextField("그룹 이름", text: $groupName)
        .autocorrectionDisabled(true)
        .textInputAutocapitalization(.never)

      Button(action: {
        store.send(.onTapCreateGroup(groupName))

        groupName = ""
      }) {
        Text("그룹 생성")
      }

      Button(role: .cancel, action: {
        groupName = ""
        isShowAlert = false
      }) {
        Text("취소")
      }
    }
    .onAppear {
      store.send(.getGroupList)
    }
  }
}
