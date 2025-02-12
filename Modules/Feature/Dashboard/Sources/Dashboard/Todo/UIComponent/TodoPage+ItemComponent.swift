import ComposableArchitecture
import Foundation
import SwiftUI

// MARK: - TodoPage.ItemComponent

extension TodoPage {
  struct ItemComponent {
    let viewState: ViewState

    let alertAction: () -> Void
    let deleteAction: () -> Void
    let updateAction: () -> Void

    @Bindable var store: StoreOf<TodoReducer>
  }
}

extension TodoPage.ItemComponent {
  @MainActor
  private var isActiveButton: Bool {
    !store.memoText.isEmpty
      || store.memoText != (store.fetchTodoItem.value?.memo ?? "")
  }
}

// MARK: - TodoPage.ItemComponent + View

extension TodoPage.ItemComponent: View {
  var body: some View {
    VStack(spacing: 40) {
      TextEditor(text: $store.memoText)
        .padding(15)
        .background(alignment: .topLeading) {
          if store.memoText.isEmpty {
            Text("남기고 싶은 메모를 작성해주세요.")
              .padding(20)
              .padding(.top, 2)
              .font(.system(size: 14))
              .foregroundColor(Color(UIColor.systemGray2))
          }
        }
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled()
        .background(Color(UIColor.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .scrollContentBackground(.hidden)
        .font(.system(size: 16))
        .frame(height: 300)
        .overlay(alignment: .bottomTrailing) {
          Text("\(store.memoText.count) / 200")
            .font(.system(size: 12))
            .foregroundColor(Color(UIColor.systemGray2))
            .padding(.trailing, 15)
            .padding(.bottom, 15)
            .onChange(of: store.memoText) { _, new in
              if new.count > 200 {
                store.memoText = String(new.prefix(200))
              }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 32)

      HStack {
        Button(action: { alertAction() }) {
          Text("메모 삭제")
            .foregroundStyle(.red)
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .alert(
          "메모 삭제를 삭제하겠습니까?",
          isPresented: $store.isShowAlert)
        {
          Button(
            role: .cancel,
            action: { })
          {
            Text("취소")
              .foregroundStyle(.red)
              .frame(height: 30)
              .frame(maxWidth: .infinity)
          }

          Button(
            role: .destructive,
            action: { deleteAction() })
          {
            Text("삭제")
              .foregroundStyle(.red)
              .frame(height: 30)
              .frame(maxWidth: .infinity)
          }
        } message: {
          Text("메모를 삭제하려면 삭제 버튼을 눌러주세요.")
        }

        Spacer()

        Button(action: { updateAction() }) {
          Text("메모 설정")
            .foregroundStyle(.white)
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .background(.blue)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .opacity(isActiveButton ? 1.0 : 0.3)
        }
        .disabled(!isActiveButton)
      }
      .padding(.horizontal, 16)
    }
  }
}

// MARK: - TodoPage.ItemComponent.ViewState

extension TodoPage.ItemComponent {
  struct ViewState: Equatable { }
}
