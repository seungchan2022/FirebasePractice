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
      VStack {
        HStack {
          TextField("원하는 카테고리를 입력해주세요.", text: $store.categoryText)
            .padding(.leading)
            .frame(maxWidth: .infinity)
            .frame(height: 55)
            .background(.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 16))
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled(true)

          Spacer()

          Button(action: {
            store.send(.onTapAddCategoryItem(.init(title: store.categoryText)))
            store.categoryText = ""
          }) {
            Text("추가")
          }
          .frame(height: 55)
          .buttonStyle(.borderedProminent)
          .disabled(isActive)
        }
        .padding(.horizontal, 16)

        ForEach(store.categoryItemList, id: \.id) { item in
          Button(action: { store.send(.onTapCategoryItem(item)) }) {
            Text(item.title)
          }
        }
      }
    }
    .onAppear {
      store.send(.getCategoryItemList)
    }
  }
}
