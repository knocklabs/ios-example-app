//
//  SheetView.swift
//  Knock Example
//
//  Created by Diego on 16/05/23.
//

import SwiftUI
import Knock

struct SheetView: View {
    @Environment(\.dismiss) var dismiss
    
    @Binding var feed: Knock.Feed
    
    var archiveItem: ((Knock.FeedItem) -> Void)?

    var body: some View {
        Button {
            dismiss()
        } label: {
            Text("Close")
            Image(systemName: "xmark.circle")
        }
        .font(.title2)
        .padding()
        
        Spacer()
        
        if (feed.entries.isEmpty) {
            VStack {
                Text("No notifications yet")
                    .font(.title2)
                    .bold()
                Text("We'll let you know when we've got something new for you.")
            }
            .padding()
            
            Spacer()
        }
        else {
            List {
                ForEach(feed.entries, id: \.id) {
                    notificationRow(item: $0)
                }
            }
        }
    }
    
    @ViewBuilder
    private func notificationRow(item: Knock.FeedItem) -> some View {
        let markdown: String = item.blocks.first { block in
            block.name == "body"
        }?.rendered ?? ""
        
        if item.read_at == nil {
            HStack {
                Image(systemName: "circle.fill")
                    .foregroundColor(.blue)
                renderNotificationContent(markdown: markdown)
                archiveItemButton(item: item)
            }
        }
        else {
            HStack {
                renderNotificationContent(markdown: markdown)
                archiveItemButton(item: item)
            }
        }
    }
    
    @ViewBuilder
    private func renderNotificationContent(markdown: String) -> some View {
//        let data = Data(markdown.utf8)
//        if let nsAttrString = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
//            Text(AttributedString(nsAttrString))
//        }
//        else {
//            Text(markdown)
//        }
        Text(markdown)
    }
    
    @ViewBuilder
    private func archiveItemButton(item: Knock.FeedItem) -> some View {
        Button {
            archiveItem?(item)
        } label: {
            Image(systemName: "x.circle")
        }
    }
}
