import ComposableArchitecture
import SwiftUI

// MARK: - GroupListDetailPage

struct GroupListDetailPage {
  @Bindable var store: StoreOf<GroupListDetailReducer>
}

extension GroupListDetailPage { }

// MARK: View

extension GroupListDetailPage: View {
  var body: some View {
    ScrollView {
      LazyVStack {
        ForEach(store.todoItemList.keys.sorted(), id: \.self) { categoryId in
          Text("\(categoryId)")
          ForEach(
            store.todoItemList.filter { $0.key == categoryId }.flatMap { $0.value }
              .sorted(by: { $0.dateCreated < $1.dateCreated }),
            id: \.id)
          { item in
            Text(item.title)
          }
        }
      }

      .padding(.top, 32)
    }
    .navigationTitle(store.groupItem.name)
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Button(action: { store.send(.routeToSelectCategory(store.groupItem)) }) {
          Image(systemName: "plus")
        }
      }
    }
    .onAppear {
      store.send(.getTodoItemList)
    }
  }
}
