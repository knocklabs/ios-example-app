//
//  ConditionArrayView.swift
//  Knock Example
//
//  Created by Diego on 26/05/23.
//

import SwiftUI
import Knock

struct ConditionArrayView: View {
    @Binding var item: Knock.ChannelTypePreferenceItem
    var onChangeHandler: (() -> Void)? = nil
    
    var body: some View {
        let binding = Binding(
            get: { self.item.value.rightValue()! },
            set: {
                self.item.value = .right($0)
                self.onChangeHandler?()
            }
        )
        
        ForEach(binding.conditions) { $condition in
            Text("\(item.id.rawValue) condition: \(condition.variable) - \(condition.operation) - \(condition.argument)")
        }
    }
}

struct ConditionArrayView_Previews: PreviewProvider {
    static let cArr = Knock.ConditionsArray(conditions: [
        Knock.Condition(variable: "var1", operation: "op", argument: "arg"),
        Knock.Condition(variable: "var2", operation: "op", argument: "arg"),
        Knock.Condition(variable: "var3", operation: "op", argument: "arg")
    ])
    
    @State static var item = Knock.ChannelTypePreferenceItem(id: .email, value: .right(cArr))
    
    static var previews: some View {
        ConditionArrayView(item: $item)
            .padding(.horizontal)
    }
}
