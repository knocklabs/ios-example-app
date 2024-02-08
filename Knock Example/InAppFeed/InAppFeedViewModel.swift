//
//  InAppFeedViewModel.swift
//  Knock Example
//
//  Created by Matt Gardner on 2/1/24.
//

import Foundation
import Knock
import OSLog

@Observable class InAppFeedViewModel {
    var feed: Knock.Feed = Knock.Feed()
    var selectedTeam: Team = Utils.teams.first!
    
    let logger = Logger(subsystem: "app.knock.ios-example", category: "InAppFeedViewModel")
    
    func initializeFeed() async {
        let options = Knock.FeedClientOptions(tenant: selectedTeam.id, has_tenant: true)
        do {
            guard let userFeed = try await Knock.shared.feedManager?.getUserFeedContent(options: options) else { return }
            await MainActor.run {
                self.feed = userFeed
                self.feed.page_info.before = feed.entries.first?.__cursor
            }
            
            Knock.shared.feedManager?.connectToFeed()
            
            Knock.shared.feedManager?.on(eventName: "new-message") { [weak self] _ in
                guard let self = self else { return }
                let options = Knock.FeedClientOptions(before: self.feed.page_info.before, tenant: self.selectedTeam.id, has_tenant: true)
                Knock.shared.feedManager?.getUserFeedContent(options: options) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let feed):
                            self.feed.entries.insert(contentsOf: feed.entries, at: 0)
                            
                            self.feed.meta.unseen_count = feed.meta.unseen_count
                            self.feed.meta.unread_count = feed.meta.unread_count
                            self.feed.meta.total_count = feed.meta.total_count
                            
                            self.feed.page_info.before = feed.entries.first?.__cursor
                        case .failure(let error):
                            self.logger.error("error in getUserFeedContent: \(error.localizedDescription)")
                        }
                    }
                }
            }
        } catch {
            logger.error("error in getUserFeedContent: \(error.localizedDescription)")
        }
    }
    
    func archiveItem(_ item: Knock.FeedItem) async {
        do {
            let messages = try await Knock.shared.batchUpdateStatuses(messageIds: [item.id], status: .archived)
            
            if let message = messages.first {
                // remove local message if update was successful
                await MainActor.run {
                    feed.entries = feed.entries.filter{ $0.id != message.id }
                }
                
                // make a request to get the latest feed metadata
                let options = Knock.FeedClientOptions(tenant: selectedTeam.id, has_tenant: true)
                if let feed = try await Knock.shared.feedManager?.getUserFeedContent(options: options) {
                    await MainActor.run {
                        self.feed.meta = feed.meta
                    }
                }
            } else {
                logger.error("Could not archive items at this time")
            }
        } catch {
            logger.error("Could not archive items at this time: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func updateSeenStatus() async {
        if feed.meta.unseen_count > 0 {
            let feedOptions = Knock.FeedClientOptions(status: .all, tenant: selectedTeam.id, has_tenant: true, archived: nil)
            do {
                let _ = try await Knock.shared.feedManager?.makeBulkStatusUpdate(type: .seen, options: feedOptions)
                logger.debug("marked all as seen")
                logger.debug("updating seen")
                await MainActor.run {
                    feed.meta.unseen_count = 0
                    
                    feed.entries = feed.entries.map { item in
                        var newItem = item
                        newItem.seen_at = Date()
                        return newItem
                    }
                }
            } catch {
                logger.error("error in makeBulkStatusUpdate: \(error.localizedDescription)")
            }
        }
    }
}

struct Team: Hashable {
    let id: String
    let name: String
}
