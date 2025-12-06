import SwiftUI

@available(iOS 18, *)
public struct FullScreenSheet: View {
    @State private var isPresented: Bool = false
    
    public init() {}
    
    public var body: some View {
        Button("Start") {
            isPresented = true
        }
        .buttonStyle(.borderedProminent)
        .fullScreenSheet(hasSafeAreaInset: true ,isPresented: $isPresented) { safeArea in
            ScrollView {
                ForEach(0...50, id: \.self) { index in
                    Text("Row : \(index)")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                }
            }.frame(width: .infinity, height: .infinity)
        } background: {
            RoundedRectangle(cornerRadius: 20)
                .fill(.green)
        }
    }
}

extension View {
    @available(iOS 18, *)
    func fullScreenSheet<ContentArea: View ,Background: View>(
        hasSafeAreaInset: Bool,
        isPresented: Binding<Bool>,
        contentArea: @escaping(UIEdgeInsets) -> ContentArea ,
        background: @escaping() -> Background) -> some View {
        self
            .modifier(
                FullScreenSheetModifier(
                    hasSafeAreaInset: hasSafeAreaInset,
                    isPresented: isPresented,
                    contentArea: contentArea,
                    background: background
                )
            )
    }
}

@available(iOS 18, *)
fileprivate struct FullScreenSheetModifier<ContentArea: View, Background: View>: ViewModifier {
    let hasSafeAreaInset: Bool
    @ViewBuilder let contentArea: (UIEdgeInsets) -> ContentArea
    @ViewBuilder let background: () -> Background
    @Environment(\.dismiss) private var dismiss
    // View Properties
    @Binding var isPresented: Bool
    @State private var dragOffset: CGFloat = 0
    @State private var scrollDisabled: Bool = false
    init(hasSafeAreaInset: Bool = false, isPresented: Binding<Bool>, contentArea: @escaping (UIEdgeInsets) -> ContentArea, background: @escaping() -> Background) {
        self.hasSafeAreaInset = hasSafeAreaInset
        self._isPresented = isPresented
        self.contentArea = contentArea
        self.background = background
    }
    
    func body(content: Content) -> some View {
        content
            .fullScreenCover(isPresented: $isPresented) {
                contentArea(safeAreaInset)
                    .scrollDisabled(scrollDisabled)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .offset(y: dragOffset)
                    .gesture(
                        CustomPanGesture { gesture in
                            let state = gesture.state
                            let halfHeight: CGFloat = screenSize / 2
                            
                            let translation = min(max(gesture.translation(in: gesture.view).y, 0), screenSize)
                            let velocity = min(max(gesture.velocity(in: gesture.view).y, 0), halfHeight)
                            
                            switch state {
                                case .began:
                                    scrollDisabled = true
                                    dragOffset = translation
                                case .changed:
                                    guard scrollDisabled else { return }
                                    dragOffset = translation
                                case .ended, .cancelled, .failed:
                                    gesture.isEnabled = false
                                    if (translation + velocity) > halfHeight {
                                        // dismiss case
                                        withAnimation {
                                            dragOffset = screenSize
                                        }
                                        
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                            dismiss()
                                            scrollDisabled = false
                                        }
                                    } else {
                                        withAnimation {
                                            dragOffset = 0
                                        }
                                        
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                            scrollDisabled = false
                                            gesture.isEnabled = true
                                        }
                                    }
                                default: ()
                            }
                        }
                    )
                    .presentationBackground {
                        background()
                            .offset(y: dragOffset)
                    }
                    .ignoresSafeArea(.container, edges: hasSafeAreaInset ? [] : .all)
            }
    }
    
    var screenSize: CGFloat {
        if let screen =  (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.keyWindow {
            return screen.bounds.height
        }
        return .zero
    }
    
    var safeAreaInset: UIEdgeInsets {
        if let screen = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.keyWindow {
            return screen.safeAreaInsets
        }
        return .zero
    }
}


struct CustomPanGesture: UIGestureRecognizerRepresentable {
    let handle: (UIPanGestureRecognizer) -> Void
    func makeCoordinator(converter: CoordinateSpaceConverter) -> Coordinator {
        Coordinator()
    }
    
    func makeUIGestureRecognizer(context: Context) -> UIPanGestureRecognizer {
        let uIPanGestureRecognizer = UIPanGestureRecognizer()
        uIPanGestureRecognizer.delegate = context.coordinator
        
        return uIPanGestureRecognizer
    }
    
    func updateUIGestureRecognizer(_ recognizer: UIPanGestureRecognizer, context: Context) {
        
    }
    
    func handleUIGestureRecognizerAction(_ recognizer: UIPanGestureRecognizer, context: Context) {
        handle(recognizer)
    }
}

extension CustomPanGesture {
    class Coordinator: NSObject ,UIGestureRecognizerDelegate {
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            guard let panGesture = gestureRecognizer as? UIPanGestureRecognizer else { return false }
            
            let velocity = panGesture.velocity(in: panGesture.view).y
            var offset: CGFloat = 0
            
            if let cView = otherGestureRecognizer.view as? UICollectionView {
                offset = cView.contentOffset.y + cView.adjustedContentInset.top
            }
            
            if let sView = otherGestureRecognizer.view as? UIScrollView {
                offset = sView.contentOffset.y + sView.adjustedContentInset.top
            }
            
            return offset <= 0 && velocity > 0
        }
    }
}

//@available(iOS 18, *)
//#Preview {
//    FullScreenSheet()
//}
