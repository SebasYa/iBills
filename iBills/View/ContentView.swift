//
//  CustomTabBar.swift
//  iBills
//
//

import SwiftUI

struct ContentView: View {
    @State private var activeTab: TabModel = .home
    @State private var isTabBarHidden: Bool = false
    
    var body: some View {
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
                                        print("Hidden")
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
