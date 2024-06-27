//
//  MainView.swift
//  Knock Example
//
//  Created by Diego on 16/05/23.
//

import SwiftUI
import Knock

struct MainView: View {
    @State private var selectedTab = 0
    @State var feedViewModel = Knock.InAppFeedViewModel()
    @State private var showingSheet = false
    @State private var currentTenant = DemoTenant.select

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                MessageComposeView(selectedTenant: $currentTenant)
                    .sheet(isPresented: $showingSheet) {
                        Knock.InAppFeedView()
                            .padding(.top, 16)
                            .environmentObject(feedViewModel)
                    }
                    .toolbar {
                        Knock.InAppFeedNotificationIconButton() {
                            showingSheet.toggle()
                        }
                        .environmentObject(feedViewModel)
                    }
            }
            .tabItem {
                Label("Messages", systemImage: "envelope")
            }
            .tag(0)
            
            NavigationStack {
                PreferencesView()
            }
            .tabItem {
                Label("Preferences", systemImage: "gear")
            }
            .tag(1)
                
        }
        .task {
            if Knock.shared.feedManager == nil {
                Knock.shared.feedManager = try? await Knock.FeedManager(feedId: Utils.inAppChannelId)
                await feedViewModel.connectFeedAndObserveNewMessages()
            }
        }
        .onReceive(feedViewModel.didTapFeedItemButtonPublisher) { actionString in
            print("Button with action \(actionString) was tapped.")
        }
        .onReceive(feedViewModel.didTapFeedItemRowPublisher) { item in
            print("Row item was tapped")
        }
        .onChange(of: currentTenant, initial: false, {
            Task {
                feedViewModel.feedClientOptions.tenant = currentTenant.tenantId
                await feedViewModel.refreshFeed()
            }
        })
        .onOpenURL(perform: { url in
            if url.host() == "preferences" {
                selectedTab = 1
            }
        })
    }
}

struct MainMenuView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = Knock.InAppFeedViewModel()
        viewModel.feed.meta.unreadCount = 60
        return MainView(feedViewModel: viewModel)
    }
}
