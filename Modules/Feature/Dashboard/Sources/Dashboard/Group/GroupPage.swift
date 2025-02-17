import ComposableArchitecture
import SwiftUI

// MARK: - GroupPage

struct GroupPage {
  @Bindable var store: StoreOf<GroupReducer>

  @State private var isShowAlert = false
  @State private var groupName = ""
}

// MARK: View

extension GroupPage: View {
  var body: some View {
    ScrollView {
      VStack {
        Text("Group Page")
      }
    }
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Button(action: { isShowAlert = true }) {
          Text("추가")
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
  }
}
