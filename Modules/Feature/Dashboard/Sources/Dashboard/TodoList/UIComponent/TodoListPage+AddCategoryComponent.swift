import ComposableArchitecture
import Foundation
import SwiftUI

// MARK: - TodoListPage.AddCategoryComponent

extension TodoListPage {
  struct AddCategoryComponent {
    let viewState: ViewState

    @Bindable var store: StoreOf<TodoListReducer>
  }
}

extension TodoListPage.AddCategoryComponent {
  @MainActor
  private var isActive: Bool {
    store.categoryText.isEmpty ? true : false
  }
}

// MARK: - TodoListPage.AddCategoryComponent + View

extension TodoListPage.AddCategoryComponent: View {
  var body: some View {
    Button(action: { store.isShowAlert = true }) {
      Image(systemName: "plus")
    }
    .alert(
      "카테고리를 입력해주세요.",
      isPresented: $store.isShowAlert)
    {
      TextField("카테고리", text: $store.categoryText)
        .autocorrectionDisabled(true)
        .textInputAutocapitalization(.never)

      Button(action: {
        store.send(.onTapAddCategoryItem(.init(title: store.categoryText)))
        store.categoryText = ""
      }) {
        Text("확인")
      }
      .disabled(isActive)

      Button(role: .cancel, action: {
        store.categoryText = ""
        store.isShowAlert = false
      }) {
        Text("취소")
      }
    } message: {
      Text("추가하고 싶은 카테고리를 입력하고, 확인 버튼을 눌러주세요.")
    }
  }
}

// MARK: - TodoListPage.AddCategoryComponent.ViewState

extension TodoListPage.AddCategoryComponent {
  struct ViewState: Equatable { }
}
