import ComposableArchitecture
import SwiftUI

// MARK: - TodoDetailPage

struct TodoDetailPage {
  @Bindable var store: StoreOf<TodoDetailReducer>
}

extension TodoDetailPage { }

// MARK: View

extension TodoDetailPage: View {
  var body: some View {
    ScrollView {
      VStack {
        Text("\(store.categoryItem.id)")
        Text(store.categoryItem.title)
      }
    }
    .onAppear {
      store.send(.getCategoryItem(store.categoryItem))
    }
  }
}
