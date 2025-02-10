import ComposableArchitecture
import SwiftUI

// MARK: - TodoPage

struct TodoPage {
  @Bindable var store: StoreOf<TodoReducer>
}

extension TodoPage {
  @MainActor
  private var isActiveButton: Bool {
    store.memoText.isEmpty
      || store.memoText == (store.fetchTodoItem.value?.memo ?? "")
  }
}

// MARK: View

extension TodoPage: View {
  var body: some View {
    ScrollView {
      VStack {
        if let item = store.fetchTodoItem.value {
          Text(item.title)

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
            .frame(height: 200)
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
        }
      }
    }
    .toolbar {
      ToolbarItem(placement: .topBarLeading) {
        Button(action: { store.isShowAlert = true }) {
          Text("메모 삭제")
            .foregroundStyle(.red)
        }
        .alert(
          "메모 삭제를 삭제하겠습니까?",
          isPresented: $store.isShowAlert)
        {
          Button(
            role: .cancel,
            action: { store.send(.onTapClose) })
          {
            Text("취소")
              .foregroundStyle(.red)
              .frame(height: 30)
              .frame(maxWidth: .infinity)
          }
          .buttonStyle(.bordered)

          Button(
            role: .destructive,
            action: {
              store.memoText = ""
              store.send(.onTapUpdateMemo(store.todoItem.categoryId, store.todoItem.id))
              store.send(.onTapClose)
            }) {
              Text("삭제")
                .foregroundStyle(.red)
                .frame(height: 30)
                .frame(maxWidth: .infinity)
            }
        } message: {
          Text("메모를 삭제하려면 삭제 버튼을 눌러주세요.")
        }
      }

      ToolbarItem(placement: .topBarTrailing) {
        Button(action: {
          store.send(.onTapUpdateMemo(store.todoItem.categoryId, store.todoItem.id))
          store.send(.onTapClose)
        }) {
          Text("메모 설정")
        }
        .disabled(isActiveButton)
      }
    }
    .onChange(of: store.fetchTodoItem.value) { _, new in
      guard let item = new else { return }
      store.memoText = item.memo ?? ""
    }
    .onAppear {
      store.send(.getTodoItem(store.todoItem))
    }
  }
}
