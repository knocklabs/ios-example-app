//
//  NewWorkflowPreferenceView.swift
//  Knock Example
//
//  Created by Diego on 16/05/23.
//

import SwiftUI
import Knock

struct NewWorkflowPreferenceView: View {
    @Environment(\.dismiss) var dismiss
    
    @Binding var items: Knock.WorkflowPreferenceItems
    
    enum PreferenceType {
        case bool
        case channels
    }
    
    @State private var name = ""
    @State private var type = PreferenceType.bool
    
    var body: some View {
        Form {
            TextField("Name", text: $name)
            
            Picker("Type", selection: $type) {
                Text("Bool").tag(PreferenceType.bool)
                Text("Channels").tag(PreferenceType.channels)
            }
            .pickerStyle(.segmented)
            
            Button( (name == "") ? "Please add a name" : "Add") {
                switch type {
                case .bool:
                    items.boolValues.append(Knock.WorkflowPreferenceBoolItem(id: name, value: false))
                case .channels:
                    items.channelTypeValues.append(Knock.WorkflowPreferenceChannelTypesItem(id: name, channelTypes: [], conditions: []))
                }
                
                dismiss()
            }
            .disabled(name == "")
        }
    }
}
