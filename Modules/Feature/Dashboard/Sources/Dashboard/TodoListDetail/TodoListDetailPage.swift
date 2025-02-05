import ComposableArchitecture
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
      VStack {
        ForEach(store.todoItemList, id: \.id) { item in
          Text(item.title)
        }
      }
    }
    .navigationTitle(store.categoryItem.title)
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Button(action: { store.isShowAlert = true }) {
          Image(systemName: "plus")
        }
      }
    }
    .alert(
      "투두를 입력해주세요.",
      isPresented: $store.isShowAlert)
    {
      TextField("Todo", text: $store.todoTitleText)
        .autocorrectionDisabled(true)
        .textInputAutocapitalization(.never)

      Button(action: {
        store.send(
          .onTapAddTodoItem(
            .init(
              categoryId: store.categoryItem.id,
              title: store.todoTitleText)))
        store.todoTitleText = ""
      }) {
        Text("확인")
      }

      Button(role: .cancel, action: {
        store.todoTitleText = ""
        store.isShowAlert = false
      }) {
        Text("취소")
      }
    } message: {
      Text("추가하고 싶은 투두를 입력하고, 확인 버튼을 눌러주세요.")
    }
    .onAppear {
      store.send(.getCategoryItem(store.categoryItem))
      store.send(.getTodoItemList)
    }
  }
}
