//
//  PreferencesView.swift
//  Knock Example
//
//  Created by Diego on 16/05/23.
//

import SwiftUI
import Knock

final class PreferenceModelData: ObservableObject {
    @Published var preferenceSet: Knock.PreferenceSet = Knock.PreferenceSet()
    @Published var preferenceArray: [Knock.ChannelTypePreferenceItem] = []
    @Published var categories = Knock.WorkflowPreferenceItems()
    @Published var workflows = Knock.WorkflowPreferenceItems()
}

struct PreferencesView: View {
    private var knockClient: Knock = Utils.myKnockClient()
    
//    @EnvironmentObject var modelData: PreferenceModelData
    @StateObject private var modelData = PreferenceModelData()
    
    @State private var showingNewSheetForCategories = false
    @State private var showingNewSheetForWorkflows = false
    @State private var showingError: Error? = nil
    @State private var isShowingError = false
    
    @State private var newChannelView: NewChannelView? = nil
    @State private var newConditionView: NewConditionView? = nil
    
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
                channelTypesView(channelTypesArray: $modelData.preferenceArray)
            }
            
            Section(header: Text("Categories")) {
                workflowPreferenceTreeView(rootItems: $modelData.categories)
                Button {
                    showingNewSheetForCategories = true
                } label: {
                    Text("Add preference")
                        .foregroundColor(.accentColor)
                }
                .sheet(isPresented: $showingNewSheetForCategories) {
                    NewWorkflowPreferenceView(items: $modelData.categories)
                }
            }
            
            Section(header: Text("Workflows")) {
                workflowPreferenceTreeView(rootItems: $modelData.workflows)
                Button {
                    showingNewSheetForWorkflows = true
                } label: {
                    Text("Add preference")
                        .foregroundColor(.accentColor)
                }
                .sheet(isPresented: $showingNewSheetForWorkflows) {
                    NewWorkflowPreferenceView(items: $modelData.workflows)
                }
            }
        }
        .refreshable {
            getCurrentPreferences()
        }
        .navigationTitle("Preferences")
        .navigationBarItems(trailing: EditButton())
        .alert("There was an error", isPresented: $isShowingError, presenting: showingError) { error in
        } message: { error in
            Text(error.localizedDescription)
        }
        .sheet(item: $newChannelView) { newView in
            newView
        }
        .sheet(item: $newConditionView) { newView in
            newView
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
            saveCurrentPreferences()
        }
        
        ForEach(rootItems.channelTypeValues) { $channelType in
            nestedChannelTypesView(id: channelType.id, channelTypesArray: $channelType.channelTypes)
            
            conditionArrayView(id: channelType.id, conditionsArray: $channelType.conditions)
        }
        .onDelete { offsets in
            rootItems.wrappedValue.channelTypeValues.remove(atOffsets: offsets)
            saveCurrentPreferences()
        }
    }
    
    @ViewBuilder
    func nestedChannelTypesView(id: String, channelTypesArray: Binding<[Knock.ChannelTypePreferenceItem]>) -> some View {
        Section(id) {
            ForEach(channelTypesArray) { $item in
                switch item.value {
                case .left(_):
                    BooleanPreferenceView(item: $item) {
                        saveCurrentPreferences()
                    }
                case .right(_):
                    ConditionArrayView(item: $item) {
                        saveCurrentPreferences()
                    }
                }
            }
            .onDelete { offsets in
                channelTypesArray.wrappedValue.remove(atOffsets: offsets)
                saveCurrentPreferences()
            }
            .padding(.leading)
            
            addChannelTypeMenuView(channelTypesArray: channelTypesArray, buttonText: "Add channel to \(id)")
        }
    }
    
    @ViewBuilder
    func conditionArrayView(id: String, conditionsArray: Binding<[Knock.Condition]>) -> some View {
        var sectionTitle: String {
            if conditionsArray.count == 0 {
                return "conditions for: \(id) (empty)"
            }
            else {
                return "conditions for: \(id)"
            }
        }
        
        Section(sectionTitle) {
            ForEach(conditionsArray) { condition in
                let value = condition.wrappedValue
                Text("condition: \(value.variable) - \(value.operation) - \(value.argument)")
            }
            .onDelete { offsets in
                conditionsArray.wrappedValue.remove(atOffsets: offsets)
                saveCurrentPreferences()
            }
            .deleteDisabled(false)
            .padding(.leading)
            
            Button {
                newConditionView = NewConditionView(conditions: conditionsArray) {
                    newConditionView = nil
                    saveCurrentPreferences()
                }
            } label: {
                Text("Add condition")
                    .foregroundColor(.accentColor)
            }
            .deleteDisabled(true)
            .padding(.leading)
        }
        .deleteDisabled(true)
    }
    
    @ViewBuilder
    func addChannelTypeMenuView(channelTypesArray: Binding<[Knock.ChannelTypePreferenceItem]>, buttonText: String = "Add channel") -> some View {
        Menu {
            let possibleKeys = Knock.ChannelTypeKey.allCases
            let availableKeys = possibleKeys.filter { key in
                channelTypesArray.wrappedValue.contains{ $0.id == key } == false
            }
            ForEach(availableKeys, id: \.self) { key in
                Button {
                    newChannelView = NewChannelView(channelTypeKey: key, channelTypesArray: channelTypesArray) {
                        newChannelView = nil
                        saveCurrentPreferences()
                    }
                } label: {
                    Text(key.rawValue)
                }
            }
        } label: {
            Text(buttonText)
                .padding(.leading)
        } .disabled(channelTypesArray.wrappedValue.count == Knock.ChannelTypeKey.allCases.count)
            .deleteDisabled(true)
    }
    
    @ViewBuilder
    func channelTypesView(channelTypesArray: Binding<[Knock.ChannelTypePreferenceItem]>) -> some View {
        let leftItems = channelTypesArray.filter { item in
            switch item.value.wrappedValue {
            case .left(_):
                return true
            case .right(_):
                return false
            }
        }
        
        let rightItems = channelTypesArray.filter { item in
            switch item.value.wrappedValue {
            case .left(_):
                return false
            case .right(_):
                return true
            }
        }
        
        ForEach(leftItems) { $item in
            BooleanPreferenceView(item: $item) {
                saveCurrentPreferences()
            }
        }
        .onDelete { offsets in
            let itemToDelete = leftItems[offsets.first!]
            
            let searchId = itemToDelete.id
            let prefIndex: Int = channelTypesArray.wrappedValue.firstIndex(where: { $0.id == searchId })!
            
            channelTypesArray.wrappedValue.remove(at: prefIndex)
            saveCurrentPreferences()
        }
        
        ForEach(rightItems) { $item in
            ConditionArrayView(item: $item) {
                saveCurrentPreferences()
            }
        }
        .onDelete { offsets in
            let itemToDelete = rightItems[offsets.first!]
            
            let searchId = itemToDelete.id
            let prefIndex: Int = channelTypesArray.wrappedValue.firstIndex(where: { $0.id == searchId })!
            
            channelTypesArray.wrappedValue.remove(at: prefIndex)
            saveCurrentPreferences()
        }
        
        addChannelTypeMenuView(channelTypesArray: channelTypesArray)
    }
    
    private func getCurrentPreferences() {
        knockClient.getUserPreferences(preferenceId: "default") { result in
            switch result {
            case .success(let preferenceSet):
                self.modelData.preferenceSet = preferenceSet
                self.modelData.preferenceArray = preferenceSet.channel_types.asArray()
                self.modelData.categories = preferenceSet.categories.toArrays()
                self.modelData.workflows = preferenceSet.workflows.toArrays()
            case .failure(let error):
                print("error getting prefs:")
                print(error)
                showingError = error
                isShowingError = true
            }
        }
    }
    
    private func saveCurrentPreferences() {
        let channel_types = modelData.preferenceArray.toChannelTypePreferences()
        modelData.preferenceSet.channel_types = channel_types
        
        let categoriesDictionary = modelData.categories.toPreferenceDictionary()
        modelData.preferenceSet.categories = categoriesDictionary
        
        let workflowsDictionary = modelData.workflows.toPreferenceDictionary()
        modelData.preferenceSet.workflows = workflowsDictionary
        
        print("will save...")
        knockClient.setUserPreferences(preferenceId: "default", preferenceSet: modelData.preferenceSet) { result in
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
            .environmentObject(PreferenceModelData())
    }
}
