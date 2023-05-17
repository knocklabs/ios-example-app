//
//  PreferencesView.swift
//  Knock Example
//
//  Created by Diego on 16/05/23.
//

import SwiftUI
import Knock

struct PreferencesView: View {
    private var knockClient: Knock = Utils.myKnockClient()
    @State private var preferenceSet: Knock.PreferenceSet = Knock.PreferenceSet()
    @State private var preferenceArray: [Knock.ChannelTypePreferenceItem] = [] {
        didSet {
            saveCurrentPreferences()
        }
    }
    @State private var categories = Knock.WorkflowPreferenceItems() {
        didSet {
            saveCurrentPreferences()
        }
    }
    @State private var workflows = Knock.WorkflowPreferenceItems() {
        didSet {
            saveCurrentPreferences()
        }
    }
    
    @State private var showingNewSheetForCategories = false
    @State private var showingNewSheetForWorkflows = false
    @State private var showingError: Error? = nil
    @State private var isShowingError = false
    
    private let availableChannelTypeKeyPaths: [KeyPath<Knock.ChannelTypePreferences, Bool?>] = [
        \.chat,
        \.email,
        \.in_app_feed,
        \.push,
        \.sms
    ]
    
    var body: some View {
        NavigationView {
            preferencesView()
        }
        .onAppear {
            getCurrentPreferences()
        }
    }
    
    @ViewBuilder
    func preferencesView() -> some View {
        List {
            Section(header: Text("Channels")) {
                channelTypesView(channelTypesArray: $preferenceArray)
            }
            
            Section(header: Text("Categories")) {
                workflowPreferenceTreeView(rootItems: $categories)
                Button {
                    showingNewSheetForCategories = true
                } label: {
                    Text("Add preference")
                        .foregroundColor(.accentColor)
                }
                .sheet(isPresented: $showingNewSheetForCategories) {
                    NewWorkflowPreferenceSheetView(items: $categories)
                }
            }
            
            Section(header: Text("Workflows")) {
                workflowPreferenceTreeView(rootItems: $workflows)
                Button {
                    showingNewSheetForWorkflows = true
                } label: {
                    Text("Add preference")
                        .foregroundColor(.accentColor)
                }
                .sheet(isPresented: $showingNewSheetForWorkflows) {
                    NewWorkflowPreferenceSheetView(items: $workflows)
                }
            }
        }
        .refreshable {
            getCurrentPreferences()
        }
        .navigationTitle("Preferences")
        .navigationBarItems(
            trailing:
                EditButton()
        )
        .alert("There was an error", isPresented: $isShowingError, presenting: showingError) { error in
            Button("OK") {
                getCurrentPreferences()
            }
        } message: { error in
            Text(error.localizedDescription)
        }
    }
    
    @ViewBuilder
    func workflowPreferenceTreeView(rootItems: Binding<Knock.WorkflowPreferenceItems>) -> some View {
        ForEach(rootItems.boolValues) { $boolItem in
            Toggle(boolItem.id, isOn: $boolItem.value)
                .onChange(of: boolItem) { newItem in
                    print("newItem: ")
                    print(newItem)
                    saveCurrentPreferences()
                }
        }
        .onDelete { offsets in
            rootItems.wrappedValue.boolValues.remove(atOffsets: offsets)
        }
        
        ForEach(rootItems.channelTypeValues) { $channelType in
            nestedChannelTypesView(id: channelType.id, channelTypesArray: $channelType.channelTypes)
        }
        .onDelete { offsets in
            rootItems.wrappedValue.channelTypeValues.remove(atOffsets: offsets)
        }
    }
    
    @ViewBuilder
    func nestedChannelTypesView(id: String, channelTypesArray: Binding<[Knock.ChannelTypePreferenceItem]>) -> some View {
        Section(id) {
            ForEach(channelTypesArray, id: \.id) { $item in
                Toggle(item.id.rawValue, isOn: $item.value)
                    .onChange(of: item) { _ in
                        saveCurrentPreferences()
                    }
            }
            .onDelete { offsets in
                channelTypesArray.wrappedValue.remove(atOffsets: offsets)
            }
            .padding(.leading)
            
            Menu {
                let possibleItems = Knock.ChannelTypeKey.allCases.map{ key in
                    Knock.ChannelTypePreferenceItem(id: key, value: false)
                }
                let availableItems = possibleItems.filter { item in
                    channelTypesArray.wrappedValue.contains{ $0.id == item.id } == false
                }
                ForEach(availableItems, id: \.id) { item in
                    Button {
                        channelTypesArray.wrappedValue.append(item)
                    } label: {
                        Text(item.id.rawValue)
                    }
                }
            } label: {
                Text("Add channel to \(id)")
                    .padding(.leading)
            } .disabled(channelTypesArray.wrappedValue.count == Knock.ChannelTypeKey.allCases.count)
        }
    }
    
    @ViewBuilder
    func channelTypesView(channelTypesArray: Binding<[Knock.ChannelTypePreferenceItem]>) -> some View {
        ForEach(channelTypesArray, id: \.id) { $item in
            Toggle(item.id.rawValue, isOn: $item.value)
                .onChange(of: item) { _ in
                    saveCurrentPreferences()
                }
        }
        .onDelete { offsets in
            channelTypesArray.wrappedValue.remove(atOffsets: offsets)
        }
        
        Menu {
            let possibleItems = Knock.ChannelTypeKey.allCases.map{ key in
                Knock.ChannelTypePreferenceItem(id: key, value: false)
            }
            let availableItems = possibleItems.filter { item in
                channelTypesArray.wrappedValue.contains{ $0.id == item.id } == false
            }
            ForEach(availableItems) { item in
                Button {
                    channelTypesArray.wrappedValue.append(item)
                } label: {
                    Text(item.id.rawValue)
                }
            }
        } label: {
            Text("Add channel")
        } .disabled(channelTypesArray.wrappedValue.count == Knock.ChannelTypeKey.allCases.count)
    }
    
    private func getCurrentPreferences() {
        knockClient.getUserPreferences(preferenceId: "default") { result in
            switch result {
            case .success(var preferenceSet):
                if preferenceSet.channel_types == nil {
                    preferenceSet.channel_types = Knock.ChannelTypePreferences()
                }
                
                if preferenceSet.categories == nil {
                    preferenceSet.categories = [:]
                }
                
                if preferenceSet.workflows == nil {
                    preferenceSet.workflows = [:]
                }
                
                self.preferenceSet = preferenceSet
                self.preferenceArray = preferenceSet.channel_types!.asArray()
                self.categories = preferenceSet.categories!.toArrays()
                self.workflows = preferenceSet.workflows!.toArrays()
            case .failure(let error):
                print("error getting prefs")
                showingError = error
                isShowingError = true
            }
        }
    }
    
    private func saveCurrentPreferences() {
        let channel_types = preferenceArray.toChannelTypePreferences()
        preferenceSet.channel_types = channel_types
        
        let categoriesDictionary = categories.toPreferenceDictionary()
        preferenceSet.categories = categoriesDictionary
        
        let workflowsDictionary = workflows.toPreferenceDictionary()
        preferenceSet.workflows = workflowsDictionary
        
        knockClient.setUserPreferences(preferenceId: "default", preferenceSet: preferenceSet) { result in
            switch result {
            case .success(_):
                print("prefs saved")
            case .failure(let error):
                print("error saving prefs")
                showingError = error
                isShowingError = true
            }
        }
    }
}

struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView()
    }
}
