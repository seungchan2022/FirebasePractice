import ComposableArchitecture
import Domain
import SwiftUI

// MARK: - SelectCategoryPage

struct SelectCategoryPage {
  @Bindable var store: StoreOf<SelectCategoryReducer>
}

extension SelectCategoryPage {

  // MARK: Internal

  @MainActor
  func handleItemSelection(_ item: TodoListEntity.Category.Item) {
    store.selectedItemList = isItemSelected(item)
      ? store.selectedItemList.filter { $0.id != item.id }
      : store.selectedItemList + [item]
  }

  @MainActor
  func isItemSelected(_ item: TodoListEntity.Category.Item) -> Bool {
    store.selectedItemList.contains { $0.id == item.id }
  }

  // MARK: Private

  @MainActor
  private var disableNextButton: Bool {
    store.selectedItemList.isEmpty
  }
}

// MARK: View

extension SelectCategoryPage: View {
  var body: some View {
    ScrollView {
      LazyVStack(spacing: 32) {
        ForEach(store.categoryItemList, id: \.id) { item in

          ItemComponent(
            viewState: .init(item: item),
            tapAction: { handleItemSelection(item) })
          {
            Spacer()

            if isItemSelected(item) {
              Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Color(.blue))
                .imageScale(.large)
            } else {
              Image(systemName: "circle")
                .foregroundStyle(Color(.systemGray4))
                .imageScale(.large)
            }
          }
        }
      }
      .padding(.top, 32)
    }
    .toolbar {
      leadingItem()
      titleView()
      trailingItem()
    }

    .onAppear {
      store.send(.getCategoryItemList)
    }
  }
}

extension SelectCategoryPage {
  @ToolbarContentBuilder
  private func leadingItem() -> some ToolbarContent {
    ToolbarItem(placement: .topBarLeading) {
      Button(action: { store.send(.routeToClose) }) {
        Image(systemName: "xmark")
      }
    }
  }

  @ToolbarContentBuilder
  @MainActor
  private func titleView() -> some ToolbarContent {
    ToolbarItem(placement: .principal) {
      VStack {
        Text(store.groupItem.name)
          .bold()
      }
    }
  }

  @ToolbarContentBuilder
  @MainActor
  private func trailingItem() -> some ToolbarContent {
    ToolbarItem(placement: .topBarTrailing) {
      Button(action: {
        store.send(.onTapAddCategoryItemList)
      }) {
        Text("완료")
          .bold()
      }
      .disabled(disableNextButton)
    }
  }
}
