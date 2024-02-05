//
//  MainMenuView.swift
//  Knock Example
//
//  Created by Diego on 16/05/23.
//

import SwiftUI
import Knock


struct MainMenuView: View {
    @State private var selectedTab = 0
    @StateObject private var feedViewModel = InAppFeedViewModel()
    
    @State private var showingSheet = false

    var body: some View {
            TabView(selection: $selectedTab) {
                NavigationStack {
                    MessageComposeView(selectedTeam: $feedViewModel.selectedTeam)
                        .sheet(isPresented: $showingSheet) {
                            FeedSheetView()
                                .environmentObject(feedViewModel)
                        }
                        .toolbar {
                            ToolbarItem {
                                Button {
                                    showingSheet.toggle()
                                } label: {
                                    getBellIcon(unseenCount: feedViewModel.feed.meta.unseen_count)
                                }
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
                    Knock.shared.feedManager = try? Knock.FeedManager(feedId: Utils.inAppChannelId)
                    await feedViewModel.initializeFeed()
                }
            }
            .onChange(of: feedViewModel.selectedTeam) {_ in
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
                .font(.title)
        }
        else {
            Image(systemName: "bell.badge")
                .symbolRenderingMode(.multicolor)
                .font(.body)
        }
    }
}

struct MainMenuView_Previews: PreviewProvider {
    static var previews: some View {
        MainMenuView()
    }
}

struct SignInView: View {
    @Binding var isSignedIn: Bool
    @State var userId: String = ""

    var body: some View {
        VStack {
            TextField("UserId", text: $userId)
            Spacer()
            Button("SignIn") {
                Task {
                    try await Knock.shared.signIn(userId: userId, userToken: nil)
                    isSignedIn = true
                }
            }
        }
        .padding()
    }
}

//struct SignInView_Previews: PreviewProvider {
//    static var previews: some View {
//        SignInView(isSignedIn: .constant(false))
//    }
//}
