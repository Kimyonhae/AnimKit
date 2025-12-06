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
                            .navigationDestination(isPresented: $nextPage) {
                                screen
                            }
                        }
                    }
                }
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
        ]
    }
}

#Preview {
    ExampleTestSample()
}
