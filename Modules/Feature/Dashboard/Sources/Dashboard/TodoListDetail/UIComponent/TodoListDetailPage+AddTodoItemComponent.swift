import ComposableArchitecture
import Foundation
import SwiftUI

// MARK: - TodoListDetailPage.AddTodoItemComponent

extension TodoListDetailPage {
  struct AddTodoItemComponent {
    let viewState: ViewState

    @Bindable var store: StoreOf<TodoListDetailReducer>
  }
}

extension TodoListDetailPage.AddTodoItemComponent { }

// MARK: - TodoListDetailPage.AddTodoItemComponent + View

extension TodoListDetailPage.AddTodoItemComponent: View {
  var body: some View {
    Button(action: { store.isShowAlert = true }) {
      Image(systemName: "plus")
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
  }
}

// MARK: - TodoListDetailPage.AddTodoItemComponent.ViewState

extension TodoListDetailPage.AddTodoItemComponent {
  struct ViewState: Equatable { }
}
