//
//  MessageComposeView.swift
//  Knock Example
//
//  Created by Diego on 16/05/23.
//

import SwiftUI
import Knock

struct MessageComposeView: View {
    private var knockClient: Knock = Utils.myKnockClient()
    @State private var feed: Knock.Feed
    
    @State private var showingSheet = false {
        didSet {
            if showingSheet {
                if feed.meta.unseen_count > 0 {
                    let feedOptions = Knock.FeedManager.FeedClientOptions(status: .all, tenant: selectedTeam.id, has_tenant: true, archived: nil)
                    knockClient.feedManager?.makeBulkStatusUpdate(type: .seen, options: feedOptions) { result in
                        print("marked all as seen")
                        
                        switch result {
                        case .success(_):
                            print("updating seen")
                            feed.meta.unseen_count = 0
                            feed.entries = feed.entries.map { item in
                                var newItem = item
                                newItem.seen_at = Date()
                                return newItem
                            }
                        case .failure(let error):
                            print(error.localizedDescription)
                        }
                    }
                }
            }
        }
    }
    @State private var message = ""
    @State private var showToast = false
    
    struct Team: Hashable {
        let id: String
        let name: String
    }
    
    let teams = [Team(id: "team-a", name: "Team A"), Team(id: "team-b", name: "Team B")]
    @State private var selectedTeam: Team
    
    init() {
        self.selectedTeam = teams.first!
        self.feed = Knock.Feed()
        
        maybeRegisterPushToken()
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("In-App Feed")
                    .font(.largeTitle)
                    .bold()
                
                Image(systemName: "globe")
                    .imageScale(.large)
            }
            
            HStack {
                Text("Send an in-app notification")
                    .font(.title2)
                
                Spacer()
            }
            .padding(.top)
            
            HStack {
                Spacer()
                
                Picker("Select a team", selection: $selectedTeam) {
                    ForEach(teams, id: \.self) {
                        Text($0.name)
                    }
                }
                .pickerStyle(.menu)
                .onChange(of: selectedTeam) {_ in
                    let options = Knock.FeedManager.FeedClientOptions(tenant: selectedTeam.id, has_tenant: true)
                    knockClient.feedManager?.getUserFeedContent(options: options) { result in
                        switch result {
                        case .success(let feed):
                            self.feed = feed
                        case .failure(let error):
                            print(error.localizedDescription)
                        }
                    }
                }
                
                Button {
                    showingSheet.toggle()
                } label: {
                    getBellIcon(unseenCount: feed.meta.unseen_count)
                }
                .sheet(isPresented: $showingSheet) {
                    SheetView(feed: $feed, archiveItem: self.archiveItem)
                }
            }
            
            HStack {
                Text("Message:")
                    .font(.title3)
                
                Spacer()
            }
            
            TextEditor(text: $message)
                .padding()
                .border(.gray)
            
            Toggle("Show a toast?", isOn: $showToast)
                .padding(.vertical)
            
            HStack {
                Button("Send notification") {
//                    DemoBackend.sendNotifyDemoMessage(message: message, tenant: selectedTeam.id, showToast: showToast, userId: knockClient.userId)
                    
                    // clear the message on send
                    message = ""
                }
                .bold()
                .disabled(message == "")
                
                Spacer()
            }
            .padding(.bottom)
            
            Divider()
            
            Spacer()
        }
        .padding()
        .onAppear{
            let options = Knock.FeedManager.FeedClientOptions(tenant: selectedTeam.id, has_tenant: true)
            knockClient.feedManager?.getUserFeedContent(options: options) { result in
                switch result {
                case .success(let feed):
                    self.feed = feed
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
            
            knockClient.feedManager?.connectToFeed()
            print("connected to feed")
            
            knockClient.feedManager?.on(eventName: "new-message") { _ in
                let options = Knock.FeedManager.FeedClientOptions(before: self.feed.page_info.before,tenant: selectedTeam.id, has_tenant: true)
                knockClient.feedManager?.getUserFeedContent(options: options) { result in
                    switch result {
                    case .success(let feed):
                        self.feed.entries.insert(contentsOf: feed.entries, at: 0)
                        
                        self.feed.meta.unseen_count = feed.meta.unseen_count
                        self.feed.meta.unread_count = feed.meta.unread_count
                        self.feed.meta.total_count = feed.meta.total_count
                        
                        self.feed.page_info.before = feed.entries.first?.__cursor
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            }
        }
        .onDisappear{
            knockClient.feedManager?.disconnectFromFeed()
            print("disconnected from feed")
        }
    }
    
    @ViewBuilder
    private func getBellIcon(unseenCount: Int) -> some View {
        if unseenCount == 0 {
            Image(systemName: "bell")
                .font(.largeTitle)
        }
        else {
            Image(systemName: "bell.badge")
                .symbolRenderingMode(.multicolor)
                .font(.largeTitle)
        }
    }
    
    func archiveItem(_ item: Knock.FeedItem) {
        knockClient.bulkUpdateMessageStatus(messageId: item.id, status: .archived) { result in
            switch result {
            case .success(let messages):
                if let message = messages.first {
                    // remove local message if update was successful
                    feed.entries = feed.entries.filter{ $0.id != message.id }
                    
                    // make a request to get the latest feed metadata
                    let options = Knock.FeedManager.FeedClientOptions(tenant: selectedTeam.id, has_tenant: true)
                    knockClient.feedManager?.getUserFeedContent(options: options) { result in
                        switch result {
                        case .success(let feed):
                            self.feed.meta = feed.meta
                        case .failure(let error):
                            print(error.localizedDescription)
                        }
                    }
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func maybeRegisterPushToken() {
        let defaults = UserDefaults.standard
        let token = defaults.string(forKey: "device_push_token") ?? ""
        
        let channelId = Utils.apnsChannelId
        
        if token != "" {
            knockClient.registerTokenForAPNS(channelId: channelId, token: token) { result in
                switch result {
                case .success(_):
                    print("success registering the push token with Knock")
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
}

struct MessageComposeView_Previews: PreviewProvider {
    static var previews: some View {
        MessageComposeView()
    }
}
