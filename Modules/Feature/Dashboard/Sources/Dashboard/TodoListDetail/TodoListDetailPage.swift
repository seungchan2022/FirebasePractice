import ComposableArchitecture
import Domain
import SwiftUI

// MARK: - TodoListDetailPage

struct TodoListDetailPage {
  @Bindable var store: StoreOf<TodoListDetailReducer>
}

extension TodoListDetailPage { }

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
              store.send(.onTapUpdateItemStatus(item.categoryId, item.id))
            },
            deleteAction: { store.send(.onTapDeleteTodoItem($0)) },
            editAction: { },
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

    .onAppear {
      store.send(.getCategoryItem(store.categoryItem))
      store.send(.getTodoItemList)
    }
  }
}
