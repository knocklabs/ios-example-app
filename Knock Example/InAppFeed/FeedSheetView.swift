//
//  SheetView.swift
//  Knock Example
//
//  Created by Diego on 16/05/23.
//

import SwiftUI
import Knock

struct FeedSheetView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var feedViewModel: InAppFeedViewModel
        
    struct TextCustom: UIViewRepresentable {
        let html: String
        
        func updateUIView(_ uiView: UITextView, context: UIViewRepresentableContext<Self>) {
            DispatchQueue.main.async {
                let data = Data(self.html.utf8)
                
                if let attributedString = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
                    uiView.isEditable = false
                    uiView.attributedText = attributedString
                }
            }
        }
        
        func makeUIView(context: UIViewRepresentableContext<Self>) -> UITextView {
            let label = UITextView()
            return label
        }
    }

    var body: some View {
        VStack{
            HStack {
                Spacer()
                
                Button {
                    dismiss()
                } label: {
                    Text("Close")
                    Image(systemName: "xmark.circle")
                }
                .font(.title2)
                .padding()
            }
            
            if (feedViewModel.feed.entries.isEmpty) {
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
                    ForEach(feedViewModel.feed.entries, id: \.id) {
                        notificationRow(item: $0)
                    }
                }
            }
        }
        .task {
            await feedViewModel.updateSeenStatus()
        }
    }
    
    @ViewBuilder
    private func notificationRow(item: Knock.FeedItem) -> some View {
        let markdown: String = item.blocks.first { block in
            block.name == "body"
        }?.rendered ?? ""
        
        if item.seen_at == nil {
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
//        Text(markdown)
        
        let modifiedFontString = "<span style=\"font-family: -apple-system, sans-serif; font-size: 20\">" + markdown + "</span>"
        TextCustom(html: modifiedFontString)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 130, maxHeight: .infinity)
    }
    
    @ViewBuilder
    private func archiveItemButton(item: Knock.FeedItem) -> some View {
        Button {
            Task {
                await feedViewModel.archiveItem(item)
            }
        } label: {
            Image(systemName: "x.circle")
        }
    }
}
