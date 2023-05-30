//
//  NewChannelView.swift
//  Knock Example
//
//  Created by Diego on 27/05/23.
//

import SwiftUI
import Knock

struct NewChannelView: View, Identifiable {
    @Environment(\.dismiss) var dismiss
    
    public var id = UUID.init().uuidString
    
    public var channelTypeKey: Knock.ChannelTypeKey
    public var channelTypesArray: Binding<[Knock.ChannelTypePreferenceItem]>
    public var completionHandler: (() -> Void)? = nil
    
    @State private var type = PreferenceType.bool
    @State private var variable = ""
    @State private var operation = ""
    @State private var argument = ""
    
    private var canAddChannel: Bool {
        return type == .bool || (
            variable != "" &&
            operation != "" &&
            argument != ""
        )
    }
    
    private var errorMessage: String {
        if canAddChannel {
            return ""
        }
        else {
            return "variable, operation, and argument must have a value"
        }
    }
    
    enum PreferenceType {
        case bool
        case conditions
    }
    
    var body: some View {
        Form {
            Text("New channel for: \(channelTypeKey.rawValue)")
            
            Picker("Type", selection: $type) {
                Text("Bool").tag(PreferenceType.bool)
                Text("Conditions").tag(PreferenceType.conditions)
            }
            .pickerStyle(.segmented)
            
            if type == .conditions {
                TextField("Variable", text: $variable)
                TextField("Operation", text: $operation)
                TextField("Argument", text: $argument)
            }
            
            Button( (errorMessage == "") ? "Add channel" : errorMessage) {
                switch type {
                case .bool:
                    let item = Knock.ChannelTypePreferenceItem(id: channelTypeKey, value: .left(false))
                    channelTypesArray.wrappedValue.append(item)
                    completionHandler?()
                case .conditions:
                    let condition = Knock.Condition(variable: variable, operation: operation, argument: argument)
                    let item = Knock.ChannelTypePreferenceItem(id: channelTypeKey, value: .right(Knock.ConditionsArray(conditions: [condition])))
                    channelTypesArray.wrappedValue.append(item)
                    completionHandler?()
                }
                
                dismiss()
            }
            .disabled(!canAddChannel)
        }
    }
}

struct NewChannelView_Previews: PreviewProvider {
    @State static var items: [Knock.ChannelTypePreferenceItem] = []
    
    static var previews: some View {
        NewChannelView(channelTypeKey: .push, channelTypesArray: $items)
    }
}
