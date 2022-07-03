import SwiftUI

struct FormField<Content: View>: View {
    let label: String
    @ViewBuilder let content: () -> Content
    
    init(_ label: String, content: @escaping () -> Content) {
        self.label = label
        self.content = content
    }
    
    var body: some View {
        HStack {
            Text(label)
            content()
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.trailing)
        }
    }
}
