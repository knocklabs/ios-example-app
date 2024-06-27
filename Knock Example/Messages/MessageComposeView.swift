//
//  MessageComposeView.swift
//  Knock Example
//
//  Created by Diego on 16/05/23.
//

import SwiftUI
import Knock
import OSLog

struct MessageComposeView: View {
    @State var message = ""
    @State var showToast = false
    @Binding var selectedTenant: DemoTenant
    
    var body: some View {
        VStack {
            HStack {
                Text("Send an in-app notification")
                    .font(.title2)
                
                Spacer()
            }
            .padding(.top)
            
            HStack {
                Text("Message:")
                    .font(.title3)
                
                Spacer()
                
                Picker("Select a tenant", selection: $selectedTenant) {
                    ForEach(DemoTenant.allCases, id: \.self) {
                        Text($0.rawValue)
                    }
                }
                .pickerStyle(.menu)
            }
            
            TextEditor(text: $message)
                .padding()
                .border(.gray)
            
            Toggle("Show a toast?", isOn: $showToast)
                .padding(.vertical)
            
            HStack {
                Button("Send notification") {
//                    DemoBackend.sendNotifyDemoMessage(message: message, tenant: selectedTeam.id, showToast: showToast, userId: knockClient.userId)
//                    clear the message on send
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
        .navigationTitle("In-App Feed")
    }
}

struct MessageComposeView_Previews: PreviewProvider {
    static var previews: some View {
        @State var tenant = DemoTenant.select
        return MessageComposeView(selectedTenant: $tenant)
    }
}

public enum DemoTenant: String, CaseIterable {
    case select = "Select a Tenant"
    case none = "None"
    case tenantA = "Tenant A"
    case tenantB = "Tenant B"
    case tenantC = "Tenant C"
    
    var tenantId: String? {
        switch self {
        case .none, .select: nil
        case .tenantA: "tenant-a"
        case .tenantB: "tenant-b"
        case .tenantC: "tenant-c"
        }
    }
}
