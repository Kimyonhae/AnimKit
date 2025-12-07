import SwiftUI

fileprivate struct StickyList<HeaderContent: View, Content: View>: View {
    @ViewBuilder var headerContent:(_ safeAreaTop: CGFloat) -> HeaderContent
    @ViewBuilder var content: Content
    // View Properties
    @State private var offset: CGFloat = 0
    @State private var safeAreaTop: CGFloat = 0
    let minHeight: CGFloat
    
    var body: some View {
        ScrollView(.vertical) {
            headerContent(safeAreaTop)
                .frame(minHeight: minHeight)
            content
        }
        .scrollIndicators(.hidden)
        .onGeometryChange(for: CGFloat.self) {
            $0.safeAreaInsets.top
        } action: { newValue in
            self.safeAreaTop = newValue
        }
    }
}

public struct StickyHeader: View {
    var imageName: String?
    
    public init(imageName: String? = nil) {
        self.imageName = imageName
    }
    
    public var body: some View {
        StickyList(
            headerContent: { safeAreaTop in
                Header(safeAreaTop)
        },  content: {
            EmptyView()
        }, minHeight: 250)
    }
    
    private func Header(_ safeAreaTop: CGFloat) -> some View {
        GeometryReader { geo in
            let size = geo.size
            let minY = geo.frame(in: .global).minY - safeAreaTop
            let height = size.height + (minY > 0 ? minY : 0)
            Group {
                if let imageName = imageName {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: size.width ,height: height + safeAreaTop)
                        .offset(y: minY > 0 ? -minY : 0)
                        .offset(y: -safeAreaTop)
                } else {
                    Image("test", bundle: .module)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: size.width ,height: height + safeAreaTop)
                        .offset(y: minY > 0 ? -minY : 0)
                        .offset(y: -safeAreaTop)
                }
            }
        }
    }
}

struct StickyHeaderTestSample: View {
    var body: some View {
        StickyHeader()
    }
}

#Preview {
    StickyHeaderTestSample()
}
