//
//  BooleanPreferenceView.swift
//  Knock Example
//
//  Created by Diego on 25/05/23.
//

import SwiftUI
import Knock

struct BooleanPreferenceView: View {
    @Binding var item: Knock.ChannelTypePreferenceItem
    var onChangeHandler: (() -> Void)? = nil
    
    var body: some View {
        let binding = Binding(
            get: { self.item.value.leftValue()! },
            set: {
                self.item.value = .left($0)
                self.onChangeHandler?()
            }
        )
        
        Toggle(item.id.rawValue, isOn: binding)
    }
}

struct BooleanView_Previews: PreviewProvider {
    @State static var item = Knock.ChannelTypePreferenceItem(id: .email, value: .left(false))

    static var previews: some View {
        BooleanPreferenceView(item: $item)
            .padding(.horizontal)
    }
}
