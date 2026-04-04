//
//  CustomTabBar.swift
//  iBills
//
//  Created by Sebastian Yanni.
//

import SwiftUI

struct ContentView: View {
    @State private var activeTab: TabModel = .home
    @State private var isTabBarHidden = false
    @State private var floatingBottomInset: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack (alignment: .bottom) {
                Group {
                    if #available(iOS 18, *) {
                        TabView(selection: $activeTab) {
                            Tab.init(value: .home) {
                                HomeView()
                                    .toolbarVisibility(.hidden, for: .tabBar)
                            }
                            Tab.init(value: .balance) {
                                BalanceView()
                                    .toolbarVisibility(.hidden, for: .tabBar)
                            }
                            Tab.init(value: .graficos) {
                                GraphView()
                                    .toolbarVisibility(.hidden, for: .tabBar)
                            }
                        }
                    } else {
                        TabView(selection: $activeTab) {
                            HomeView()
                                .tag(TabModel.home)
                                .background {
                                    if !isTabBarHidden {
                                        HideTabBar {
                                            isTabBarHidden = true
                                        }
                                    }
                                }
                            BalanceView()
                                .tag(TabModel.balance)

                            GraphView()
                                .tag(TabModel.graficos)
                        }
                    }
                }
                CustomTabBarView(activeTab: $activeTab)
                    .background {
                        GeometryReader { proxy in
                            Color.clear
                                .preference(
                                    key: FloatingBottomInsetPreferenceKey.self,
                                    value: max(
                                        0,
                                        geometry.size.height - proxy.frame(in: .named("CONTENT_VIEW")).minY
                                    )
                                )
                        }
                    }
            }
            .coordinateSpace(name: "CONTENT_VIEW")
            .onPreferenceChange(FloatingBottomInsetPreferenceKey.self) { newValue in
                floatingBottomInset = newValue
            }
            .environment(\.floatingBottomInset, floatingBottomInset)
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
    }
}

struct HideTabBar: UIViewRepresentable {
    var result: () -> ()
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        
        DispatchQueue.main.async  {
            if let tabController = view.tabController {
                tabController.tabBar.isHidden = true
                result()
            }
        }
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
}

extension UIView {
    var tabController: UITabBarController? {
        if let controller = sequence(first: self, next: {
            $0.next
        }).first(where: { $0 is UITabBarController }) as? UITabBarController {
            return controller
        }
        return nil
    }
}

#Preview {
    ContentView()
}
