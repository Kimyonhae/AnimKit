import SwiftUI

public struct ExampleTestSample: View {
    @State private var isPresented: Bool = false
    @State private var nextPage: Bool = false
    @State private var screen: AnyView? = nil
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(data) { card in
                        AccordionList(title: card.title) {
                            VStack {
                                Text("\(card.description)")
                                Button {
                                    guard let screen = card.screen else {
                                        isPresented = true
                                        return
                                    }
                                    // nextPage
                                    nextPage = true
                                    self.screen = screen
                                } label: {
                                    Text("Excute")
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.borderedProminent)
                            }
                            .sheet(isPresented: $isPresented) {
                                if let content = card.content {
                                    content()
                                }
                            }
                        }
                    }
                }
            }
            .navigationDestination(isPresented: $nextPage) {
                screen
            }
            .padding(.horizontal)
            .navigationTitle("Animkit Example")
        }
    }
}

extension ExampleTestSample{
    struct Card<Content: View>: Identifiable {
        let id = UUID()
        let title: String          // 제목
        let description: String    // code
        let screen: AnyView?       // Page가 필요한 경우
        let content: (() -> Content)? // 버튼 누르면 보여줄 UI
        
        init(title: String, description: String, screen: AnyView? = nil, content: (() -> AnyView)? = nil) {
            self.title = title
            self.description = description
            self.screen = screen
            self.content = content as? () -> Content
        }
    }
    
    var data: [Card<AnyView>] {
        [
            Card(
                title: "AccordionList",
                description: """
                    AccordionList(title: String) {
                        Detail Content 
                    }
                """,
                content: {
                    AnyView(
                        AccordionList {
                            Text("Test Demo!!")
                        }
                        .padding()
                    )
                },
            ),
            Card(
                title: "FullScreenSheet",
                description: """
                            Button("Start") {
                                isPresented = true
                            }
                            .buttonStyle(.borderedProminent)
                            .fullScreenSheet(hasSafeAreaInset: true ,isPresented: $isPresented) { safeArea in
                                ScrollView {
                                    ForEach(0...50, id: \\.self) { index in
                                        Text("Row : index")
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
                 """,
                screen: {
                    if #available(iOS 18, *) {
                        AnyView(FullScreenSheet())
                    } else {
                        AnyView(Text("iOS Version 18 Upgrade Required!"))
                    }
                }()
            ),
            Card(
                title: "Sticky Header",
                description: """
                    StickyList(
                        headerContent: { safeAreaTop in
                            Header(safeAreaTop)
                    },  content: {
                        EmptyView()
                    }, minHeight: 250)
                """,
                screen: {
                    AnyView(
                        StickyHeaderTestSample()
                    )
                }(),
            ),
            Card(
                title: "Animated Scale Menu",
                description: """
                    VStack {
                        
                    }
                    .navigationTitle("AnimatedScaleMenuTest")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                    .overlay {
                        ZStack(alignment: .bottomTrailing) {
                            Rectangle()
                                .fill(.primary.opacity(isPresented ? 0.1 : 0))
                                .allowsTightening(isPresented)
                                .onTapGesture {
                                    isPresented = false
                                }
                                .animation(.snappy(duration: 0.3, extraBounce: 0.3), value: isPresented)
                                .ignoresSafeArea()
                            
                            AnimatedScaleMenu(
                                isPresented: $isPresented,
                                actions: {
                                    VStack(spacing: 4) {
                                        sublineText("검색", icon: "magnifyingglass.circle")
                                        sublineText("분류", icon: "divide.circle")
                                        
                                        HStack(spacing: 0) {
                                            circleIcon(icon: "pencil.tip.crop.circle")
                                            Spacer()
                                            circleIcon(icon: "square.and.pencil.circle")
                                            Spacer()
                                            circleIcon(icon: "trash.circle")
                                            Spacer()
                                            circleIcon(icon: "folder.circle")
                                        }
                                    }
                                    .frame(width: 250)
                                },background: {
                                    ZStack {
                                        Capsule()
                                            .fill(.background)
                                        Capsule().fill(.ultraThinMaterial)
                                    }
                                    .shadow(color: .gray.opacity(0.5) ,radius: 1)
                                }
                            )
                            .padding(.trailing)
                            .padding(.bottom)
                        }
                    }
                    .background(Color.secondary.opacity(0.1))
                """,
                screen: {
                    AnyView(
                        AnimatedScaleMenuTestSample()
                    )
                }(),
            ),
        ]
    }
}

#Preview {
    ExampleTestSample()
}
