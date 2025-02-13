import ComposableArchitecture
import SwiftUI

// MARK: - TodoListPage

struct TodoListPage {
  @Bindable var store: StoreOf<TodoListReducer>
}

extension TodoListPage {
  @MainActor
  private var isActiveButton: Bool {
    guard
      let item = store.categoryItem,
      let currentItem = store.categoryItemList.first(where: { $0.id == item.id })
    else { return true }
    return store.categoryText.isEmpty || store.categoryText == currentItem.title
  }
}

// MARK: View

extension TodoListPage: View {
  var body: some View {
    ScrollView {
      LazyVStack(alignment: .leading, spacing: 20) {
        ForEach(store.categoryItemList, id: \.id) { item in
          ItemComponent(
            viewState: .init(item: item),
            tapAction: { store.send(.onTapCategoryItem($0)) },
            deleteAction: { store.send(.onTapDeleteCategoryItem($0)) },
            editAction: {
              store.isShowEditAlert = true
              store.categoryItem = item
              store.categoryText = item.title
            },
            shareAction: { })
        }
      }
      .padding(.top, 32)
    }
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        AddCategoryComponent(viewState: .init(), store: store)
      }
    }
    .alert(
      "수정",
      isPresented: $store.isShowEditAlert,
      actions: {
        TextField("타이틀 설정", text: $store.categoryText)
          .autocorrectionDisabled(true)
          .textInputAutocapitalization(.never)

        Button(action: {
          store.isShowEditAlert = false
          store.categoryItem = .none
          store.categoryText = ""
        }) {
          Text("취소")
            .foregroundStyle(.red)
        }

        Button(action: {
          if let item = store.categoryItem {
            store.send(.onTapEditCategoryItemTitle(item))
          }
          store.categoryItem = .none
          store.categoryText = ""
        }) {
          Text("확인")
        }
        .disabled(isActiveButton)
      })
    .onAppear {
      store.send(.getCategoryItemList)
    }
  }
}
