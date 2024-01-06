//
//  NotificationsView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 9/20/23.
//

import SwiftUI
import MapKit

struct NotificationSettingsView: View {
    
    
    @State private var settings: UserNotificationSettings?
        
    @State private var location: UserNotificationSettings.UserNotificationLocation?
    
    @State private var isLoading = false
    
    @State private var alertErrorFetchingSettings = false
    @State private var alertErrorSavingSettings = false
    
    @State private var isShowingNotificationMapView = false
    
    @State private var notifyAttempt = false
    @State private var notifyCarjacking = false
    @State private var notifyStolen = false
    @State private var notifyRecovered = false
    @State private var notifyIncident = false
    @State private var notifyWitnessed = false
    @State private var notifyLocated = false
    @State private var notifyBreakIn = false

    @EnvironmentObject var userVM: UserViewModel
    
    @Environment (\.dismiss) var dismiss
        
    var locationIsNotSet: Bool {
        return (settings?.location == nil && location == nil)
    }
    
    var completion: (()->())? = nil
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Form {
                    Section {
                        Button(locationIsNotSet ? "Add Location" : "Change Location") {
                            isShowingNotificationMapView.toggle()
                        }
                    } footer: {
                        Text(locationIsNotSet ? "Specify where to receive location based notifications and reports from." : "Modify where to receive location based notifications and reports from.")
                    }
                    Section {
                        Toggle("Attempt", isOn: $notifyAttempt)
                        Toggle("Break-in", isOn: $notifyBreakIn)
                        Toggle("Carjacking", isOn: $notifyCarjacking)
                        Toggle("Recovered", isOn: $notifyRecovered)
                        Toggle("Incident", isOn: $notifyIncident)
                        Toggle("Located", isOn: $notifyLocated)
                        Toggle("Stolen", isOn: $notifyStolen)
                        Toggle("Witnessed", isOn: $notifyWitnessed)
                    } header: {
                        Text("Report-based notifications")
                    } footer: {
                        Text("When receiving notifications regarding updates to a report you've made, these settings are ignored.")
                    }
                    .tint(.blue)
                    .disabled(locationIsNotSet)
                }
                .disabled(isLoading)
            }
            .navigationTitle(SettingsView.SettingsRoutes.notifications.title)
            .navigationBarTitleDisplayMode(.inline)
            .interactiveDismissDisabled()
            .overlay {
                if isLoading {
                    FilmProgressView()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        save()
                    } label: {
                        Text("Save")
                    }
                    .disabled(isLoading)
                }
            }
            .customSheetView(isPresented: $isShowingNotificationMapView, detents: [.large()], showsIndicator: true) {
                NotificationMapView(location: $location)
            }
            .onAppear {
                getUserSettings()
            }
        }
        .tint(Color(uiColor: .label))
        .alert("There was an error retrieving your settings", isPresented: $alertErrorFetchingSettings) {
            Button("OK") {
                dismiss()
            }
        }
        .alert("There was an error saving your settings", isPresented: $alertErrorSavingSettings) {
            Button("OK") {}
        } message: {
            Text("We ran into an issue saving your settings. Check your internet connection and try again.")
        }
    }
    
    func save() {
        Task {
            isLoading = true
            let settings = UserNotificationSettings(
                location: location,
                notifyAttempt: notifyAttempt,
                notifyBreakIn: notifyBreakIn, 
                notifyCarjacking: notifyCarjacking,
                notifyRecovered: notifyRecovered, 
                notifyIncident: notifyIncident,
                notifyLocated: notifyLocated,
                notifyStolen: notifyStolen,
                notifyWitnessed: notifyWitnessed)
            
            do {
                try await userVM.saveNotificationSettings(settings)
                if let completion {
                    completion()
                }
                dismiss()
            } catch {
                self.alertErrorSavingSettings.toggle()
                self.isLoading = false
            }
        }
    }
    
    func getUserSettings() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            Task {
                do {
                    let settings = try await userVM.fetchNotificationSettings()
                    
                    if let settings {
                        self.settings = settings
                        
                        self.notifyAttempt = settings.notifyAttempt
                        self.notifyBreakIn = settings.notifyBreakIn
                        self.notifyCarjacking = settings.notifyCarjacking
                        self.notifyRecovered = settings.notifyRecovered
                        self.notifyIncident = settings.notifyIncident
                        self.notifyLocated = settings.notifyLocated
                        self.notifyStolen = settings.notifyStolen
                        self.notifyWitnessed = settings.notifyWitnessed
                        
                        self.location = settings.location
                    }
                    
                    isLoading = false
                } catch {
                    self.alertErrorFetchingSettings.toggle()
                }
            }
        }
    }
}

struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationSettingsView()
            .environmentObject(UserViewModel())
    }
}
