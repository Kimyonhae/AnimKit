import SwiftUI

public struct AnimatedScaleMenu<Actions: View, Background: View>: View {
    @Binding var isPresented: Bool
    
    // View Properties
    let innerScale: CGFloat = 1
    var actions: () -> Actions
    var background: () -> Background
    var minimunSize: CGRect = .init(origin: .zero, size: CGSize(width: 48, height: 48))
    
    init(isPresented: Binding<Bool>, actions: @escaping () -> Actions, background: @escaping () -> Background) {
        self._isPresented = isPresented
        self.actions = actions
        self.background = background
    }
    
    public var body: some View {
        ZStack {
            actions()
                .allowsTightening(isPresented)
                .compositingGroup()
                .visualEffect({ [innerScale,minimunSize,isPresented] content, proxy in
                    let contentSize = proxy.size
                    let molecule = max(minimunSize.width, minimunSize.height) // 분자
                    let denominator = min(contentSize.width, contentSize.height) // 분모
                    let size = molecule / denominator
                    
                    return content.scaleEffect(isPresented ? innerScale : 0.45 * size)
                })
        }
        .overlay {
            if !isPresented {
                Capsule()
                    .foregroundStyle(.clear)
                    .frame(
                        width: minimunSize.width,
                        height: minimunSize.height
                    )
                    .contentShape(.capsule)
                    .onTapGesture {
                        isPresented = true
                    }
            }
        }
        .background {
            background()
                .frame(
                    width: isPresented ? nil : minimunSize.width,
                    height: isPresented ? nil :  minimunSize.height
                )
                .opacity(isPresented ? 0 : 1)
                .blur(radius: isPresented ? 30 : 0)
                .compositingGroup()
        }
        .fixedSize()
        .frame(
            width: isPresented ? nil : minimunSize.width,
            height: isPresented ? nil : minimunSize.height
        )
        .animation(animation, value: isPresented)
    }
    
    var animation: Animation {
        .snappy(duration: 0.5, extraBounce: 0.3)
    }
}



public struct AnimatedScaleMenuTestSample: View {
    @State private var isPresented: Bool = false
    
    public init() {}
    
    public var body: some View {
        VStack {
            
        }
        .navigationTitle("AnimatedScaleMenu")
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
    }
    
    @ViewBuilder
    private func sublineText(_ title: String , icon iconName: String) -> some View {
        Button(action: {
            
        }, label: {
            HStack {
                Text(title).font(.body).fontWeight(.medium)
                Spacer()
                Image(systemName: iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
            }
            .frame(height: 48)
            .foregroundStyle(.foreground)
            .padding(.horizontal)
            .background(.background)
            .clipShape(.rect(cornerRadius: 8))
            .overlay {
                isPresented ? nil : RoundedRectangle(cornerRadius: 12)
                    .fill(.background)
            }
        })
    }
    
    @ViewBuilder
    private func circleIcon(icon iconName: String) -> some View {
        Button(action: {
            
        }, label: {
            ZStack {
                Circle().fill(.background)
                
                Image(systemName: iconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .foregroundStyle(.foreground)
            }
            .frame(width: 48, height: 48)
            .overlay {
                isPresented ? nil : Circle()
                    .fill(.background)
            }
        })
    }
}

#Preview {
    NavigationStack {
        AnimatedScaleMenuTestSample()
    }
}
