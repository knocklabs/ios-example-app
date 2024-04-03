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
    @Environment(InAppFeedViewModel.self) var feedViewModel

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
                    ForEach(feedViewModel.feed.entries, id: \.id) { item in
                        FeedNotificationRowView(item: item) {
                            Task {
                                await feedViewModel.archiveItem(item)
                            }
                        }
                    }
                }
            }
        }
        .onDisappear {
            Task {
                await feedViewModel.updateSeenStatus()
            }
        }
    }
}

struct FeedNotificationRowView: View {
    var item: Knock.FeedItem
    var didTapArchive: () -> Void
    
    var body: some View {
        HStack {
            if item.seen_at == nil {
                Image(systemName: "circle.fill")
                    .foregroundColor(.blue)
            }
            VStack(alignment: .leading, spacing: .zero) {
                ForEach(Array(item.blocks.enumerated()), id: \.offset) { _, block in
                    Group {
                        switch block {
                        case let block as Knock.MarkdownContentBlock:
                            markdownContent(block: block)
                        case let block as Knock.ButtonSetContentBlock:
                            actionButtonsContent(block: block)
                        default:
                            EmptyView()
                        }
                    }
                }
            }
            archiveItemButton(item: item)
        }
    }

    @ViewBuilder
    private func markdownContent(block: Knock.MarkdownContentBlock) -> some View {
        renderNotificationContent(markdown: block.rendered)
    }
    
    @ViewBuilder
    private func actionButtonsContent(block: Knock.ButtonSetContentBlock) -> some View {
        HStack {
            ForEach(Array(block.buttons.enumerated()), id: \.offset) { _, button in
                actionButton(button: button)
            }
        }
    }
    
    @ViewBuilder
    private func actionButton(button: Knock.BlockActionButton) -> some View {
        Button(button.label) {}
            .padding()
            .background(button.name == "primary" ? .red : .white)
            .border(.black, width: 1)
    }
    
    @ViewBuilder
    private func renderNotificationContent(markdown: String) -> some View {
        let modifiedFontString = "<span style=\"font-family: -apple-system, sans-serif; font-size: 20\"> \(markdown) </span>"

        TextCustom(html: modifiedFontString)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 130, maxHeight: .infinity)
    }
    
    @ViewBuilder
    private func archiveItemButton(item: Knock.FeedItem) -> some View {
        Button {
            didTapArchive()
        } label: {
            Image(systemName: "x.circle")
        }
    }
    
    struct TextCustom: UIViewRepresentable {
        let html: String
        
        func updateUIView(_ uiView: UITextView, context: UIViewRepresentableContext<Self>) {
            DispatchQueue.main.async {
                let data = Data(self.html.utf8)
                
                if let attributedString = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
//                    uiView.backgroundColor = .clear

                    // For text visualisation only, no editing.
                    uiView.isEditable = false

                    // Make UITextView flex to available width, but require height to fit its content.
                    // Also disable scrolling so the UITextView will set its `intrinsicContentSize` to match its text content.
                    uiView.isScrollEnabled = false
                    uiView.setContentHuggingPriority(.defaultLow, for: .vertical)
                    uiView.setContentHuggingPriority(.defaultLow, for: .horizontal)
                    uiView.setContentCompressionResistancePriority(.required, for: .vertical)
                    uiView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
                    uiView.attributedText = attributedString
                }
            }
        }
        
        func makeUIView(context: UIViewRepresentableContext<Self>) -> UITextView {
            let label = UITextView()
            return label
        }
    }
}


struct FeedSheetView_Previews: PreviewProvider {
    static var previews: some View {
        let markdown = Knock.MarkdownContentBlock(name: "markdown", content: "Here's a new notification from **{{ recipient.name | default: \"you\" }}**:\n\n> {{ message }}", rendered: "<p>Here's a new notification from <strong>Dr. Ida Williamson</strong>:</p><blockquote><p>test</p></blockquote>")
                
        let buttons = Knock.ButtonSetContentBlock(name: "buttons", buttons: [Knock.BlockActionButton(label: "Primary", name: "primary", action: ""), Knock.BlockActionButton(label: "Secondary", name: "secondary", action: "")])
        
        let item = Knock.FeedItem(__cursor: "", actors: [], activities: [], blocks: [markdown, buttons], data: [:], id: "", inserted_at: nil, interacted_at: nil, clicked_at: nil, link_clicked_at: nil, total_activities: 0, total_actors: 0, updated_at: nil)
        
        
        List {
            VStack {
                FeedNotificationRowView(item: item) {}
                FeedNotificationRowView(item: item) {}
                FeedNotificationRowView(item: item) {}
                Spacer()
            }
        }
    }
}
