import SwiftUI

public struct AccordionList<Content: View>: View {
    @State private var showView: Bool = false
    let title: String
    let icon: String?
    let content: () -> Content
    
    init(title: String = "Test Example", icon: String? = nil, content: @escaping() -> Content) {
        self.title = title
        self.icon = icon
        self.content = content
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                }
                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)
                Spacer()
                Image(systemName: "chevron.up")
                    .rotationEffect(.degrees(showView ? -180 : 0))
            }
            .padding()
            .background(.ultraThinMaterial) // 반투명 카드 느낌
            .clipShape(.rect(cornerRadius: 4))
            
            if showView {
                content()
                    .frame(maxWidth: .infinity)
                    .background(.ultraThinMaterial) // 반투명 카드 느낌
                    .opacity(showView ? 1 : 0)
                    .clipped()
                    .animation(.linear, value: showView)
            }
        }
        .padding(.vertical, 5)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation {
                showView.toggle()
            }
        }
    }
}
