import ComposableArchitecture
import Domain
import SwiftUI

// MARK: - TodoListDetailPage

struct TodoListDetailPage {
  @Bindable var store: StoreOf<TodoListDetailReducer>
}

extension TodoListDetailPage {
  @MainActor
  private var isActiveButton: Bool {
    guard
      let item = store.todoItem,
      let currentItem = store.todoItemList.first(where: { $0.id == item.id })
    else { return true }
    return store.todoTitleText.isEmpty || store.todoTitleText == currentItem.title
  }
}

// MARK: View

extension TodoListDetailPage: View {
  var body: some View {
    ScrollView {
      LazyVStack {
        ForEach(store.todoItemList, id: \.id) { item in
          ItemComponent(
            viewState: .init(item: item),
            tapAction: { store.send(.onTapTodoItem($0)) },
            updateAction: {
              store.send(.onTapUpdateItemStatus(item))
            },
            deleteAction: { store.send(.onTapDeleteTodoItem($0)) },
            editAction: {
              store.isShowEditAlert = true
              store.todoItem = item
              store.todoTitleText = item.title
            },
            shareAction: { })
        }
      }
      .padding(.top, 32)
    }
    .navigationTitle(store.categoryItem.title)
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        AddTodoItemComponent(
          viewState: .init(),
          store: store)
      }
    }
    .alert(
      "수정",
      isPresented: $store.isShowEditAlert,
      actions: {
        TextField("타이틀 설정", text: $store.todoTitleText)
          .autocorrectionDisabled(true)
          .textInputAutocapitalization(.never)

        Button(action: {
          store.isShowEditAlert = false
          store.todoItem = .none
          store.todoTitleText = ""
        }) {
          Text("취소")
            .foregroundStyle(.red)
        }

        Button(action: {
          if let item = store.todoItem {
            store.send(.onTapEditTodoItemTitle(item))
          }
          store.todoItem = .none
          store.todoTitleText = ""
        }) {
          Text("확인")
        }
        .disabled(isActiveButton)
      })
    .onAppear {
      store.send(.getCategoryItem(store.categoryItem))
      store.send(.getTodoItemList)
    }
  }
}
