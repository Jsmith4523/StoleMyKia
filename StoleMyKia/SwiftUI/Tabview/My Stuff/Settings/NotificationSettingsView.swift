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
    
    @State private var notifyAttempt    = true
    @State private var notifyCarjacking = true
    @State private var notifyStolen     = true
    @State private var notifyRecovered  = true
    @State private var notifyIncident   = true
    @State private var notifyWitnessed  = true
    @State private var notifyLocated    = true
    @State private var notifyBreakIn    = true

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
                        Button(locationIsNotSet ? "Add Location" : "Adjust Location") {
                            isShowingNotificationMapView.toggle()
                        }
                    } footer: {
                        Text(locationIsNotSet ? "Specify the location from which you want to receive location-based notifications and reports" : "Adjust where you receive location-based notifications and reports from.")
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
                        Text("Customize what reports you would like to be notified on.\nWhen receiving updates to your report(s), these settings are not taken into account.")
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
                    .disabled(isLoading || location == nil)
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
        .alert("An Error Occurred", isPresented: $alertErrorSavingSettings) {
            Button("OK") {}
        } message: {
            Text("We ran into an issue saving your settings. Please try again.")
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
