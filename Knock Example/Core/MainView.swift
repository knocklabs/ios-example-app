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
    @State private var feedViewModel = InAppFeedViewModel()    
    @State private var showingSheet = false

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                MessageComposeView(selectedTeam: $feedViewModel.selectedTeam)
                    .sheet(isPresented: $showingSheet) {
                        FeedSheetView()
                            .environment(feedViewModel)
                    }
                    .toolbar {
                        Button {
                            showingSheet.toggle()
                        } label: {
                            getBellIcon(unseenCount: feedViewModel.feed.meta.unseen_count)
                        }
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
                await feedViewModel.initializeFeed()
            }
        }
        .onChange(of: feedViewModel.selectedTeam, initial: false) { _, _  in
            let options = Knock.FeedClientOptions(tenant: feedViewModel.selectedTeam.id, has_tenant: true)
            Task {
                if let feed = try await Knock.shared.feedManager?.getUserFeedContent(options: options) {
                    self.feedViewModel.feed = feed
                }
            }
        }
        .onOpenURL(perform: { url in
            if url.host() == "preferences" {
                selectedTab = 1
            }
        })
    }
        
    
    @ViewBuilder
    private func getBellIcon(unseenCount: Int) -> some View {
        if unseenCount == 0 {
            Image(systemName: "bell")
                .tint(.gray)
                .font(.title2)
        }
        else {
            Image(systemName: "bell.badge")
                .tint(.gray)
                .symbolRenderingMode(.multicolor)
                .font(.title2)
        }
    }
}

struct MainMenuView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
