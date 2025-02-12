import ComposableArchitecture
import SwiftUI

// MARK: - TodoPage

struct TodoPage {
  @Bindable var store: StoreOf<TodoReducer>
}

extension TodoPage { }

// MARK: View

extension TodoPage: View {
  var body: some View {
    ScrollView {
      ItemComponent(
        viewState: .init(),
        alertAction: { store.isShowAlert = true },
        deleteAction: {
          store.memoText = ""
          store.send(.onTapUpdateMemo(store.todoItem))
          store.send(.onTapClose)
        },
        updateAction: {
          store.send(.onTapUpdateMemo(store.todoItem))
          store.send(.onTapClose)
        },
        store: store)
    }
    .navigationTitle(store.todoItem.title)
    .toolbar {
      ToolbarItem(placement: .topBarLeading) {
        Button(action: { store.send(.onTapClose) }) {
          Image(systemName: "xmark")
        }
      }
    }
    .onChange(of: store.fetchTodoItem.value) { _, new in
      guard let item = new else { return }
      store.memoText = item.memo ?? ""
    }
    .onAppear {
      store.send(.getTodoItem(store.todoItem))
    }
  }
}
