//
//  NewConditionView.swift
//  Knock Example
//
//  Created by Diego on 29/05/23.
//

import SwiftUI
import Knock

struct NewConditionView: View, Identifiable {
    @Environment(\.dismiss) var dismiss
    
    public var id = UUID.init().uuidString
    
    @State private var variable = ""
    @State private var operation = ""
    @State private var argument = ""
    
    public var conditions: Binding<[Knock.Condition]>
    public var completionHandler: (() -> Void)? = nil
    
    private var canAddChannel: Bool {
        return variable != "" && operation != "" && argument != ""
    }
    
    private var errorMessage: String {
        if canAddChannel {
            return ""
        }
        else {
            return "variable, operation, and argument must have a value"
        }
    }
    
    var body: some View {
        Form {
            TextField("Variable", text: $variable)
            TextField("Operation", text: $operation)
            TextField("Argument", text: $argument)
            
            Button( (errorMessage == "") ? "Add condition" : errorMessage) {
                let condition = Knock.Condition(variable: variable, operation: operation, argument: argument)
                conditions.wrappedValue.append(condition)
                
                completionHandler?()
                
                dismiss()
            }
            .disabled(!canAddChannel)
        }
    }
}

struct AddConditionView_Previews: PreviewProvider {
    @State static var conditions: [Knock.Condition] = []
    
    static var previews: some View {
        NewConditionView(conditions: $conditions)
    }
}
