import ComposableArchitecture
import SwiftUI

// MARK: - TodoListPage

struct TodoListPage {
  @Bindable var store: StoreOf<TodoListReducer>
}

extension TodoListPage {
  @MainActor
  private var isActive: Bool {
    store.categoryText.isEmpty ? true : false
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
            deleteAction: { },
            updateAction: { },
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
    .onAppear {
      store.send(.getCategoryItemList)
    }
  }
}
