import SwiftUI

// MARK: - HomePage.TextFieldComponent

extension HomePage {
  struct TextFieldComponent {
    let viewState: ViewState

    @Binding var text: String
    @Binding var isShowText: Bool
    @FocusState private var isActive

    let placeholder: String
    let errorMessage: String?
    let isSecure: Bool

  }
}

extension HomePage.TextFieldComponent { }

// MARK: - HomePage.TextFieldComponent + View

extension HomePage.TextFieldComponent: View {
  var body: some View {
    VStack(alignment: .leading) {
      ZStack(alignment: .leading) {
        if isSecure, !isShowText {
          SecureField("", text: $text)
            .padding(.leading)
            .frame(maxWidth: .infinity)
            .frame(height: 55)
            .focused($isActive)
            .background(.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 16))
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled(true)
        } else {
          TextField("", text: $text)
            .padding(.leading)
            .frame(maxWidth: .infinity)
            .frame(height: 55)
            .focused($isActive)
            .background(.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 16))
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled(true)
        }

        Text(placeholder)
          .padding(.leading)
          .offset(y: (isActive || !text.isEmpty) ? -50 : .zero)
          .animation(.spring(), value: isActive)
          .foregroundStyle(isActive ? .blue : .secondary)
          .onTapGesture {
            isActive = true
          }
      }
      .overlay(alignment: .trailing) {
        if isSecure {
          Button(action: { isShowText.toggle() }) {
            Image(systemName: isShowText ? "eye.fill" : "eye.slash.fill")
              .padding(16)
              .foregroundStyle(isShowText ? .primary : .secondary)
          }
        }
      }

      if let errorMessage {
        Text(errorMessage)
          .font(.footnote)
          .foregroundColor(.red)
          .padding(.leading)
      }
    }
  }
}

// MARK: - HomePage.TextFieldComponent.ViewState

extension HomePage.TextFieldComponent {
  struct ViewState: Equatable { }
}
