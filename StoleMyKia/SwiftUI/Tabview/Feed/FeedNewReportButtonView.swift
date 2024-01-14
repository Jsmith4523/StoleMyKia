//
//  FeedNewReportButtonView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 10/25/23.
//

import SwiftUI
import CoreLocation

struct FeedNewReportButtonView: View {
    
    var backgroundColor: Color = .brand
    
    @State private var alertLocationServicesDenied = false
    @State private var isShowingNewReportView = false
    
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var reportsVM: ReportsViewModel
    
    var body: some View {
        HStack {
            Spacer()
            VStack {
                Spacer()
                Button {
                    presentComposeView()
                } label: {
                    Image(systemName: "plus")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                        .padding()
                        .background(backgroundColor)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                        .padding()
                }
            }
            .sheet(isPresented: $isShowingNewReportView) {
                ReportComposeReportTypeView(isPresented: $isShowingNewReportView)
                    .environmentObject(reportsVM)
                    .environmentObject(userVM)
                    .environmentObject(ReportComposeViewModel())
            }
        }
        .alert("Location Services Disabled", isPresented: $alertLocationServicesDenied) {
            Button("OK") {}
            Button("Enable Location Services") { URL.openApplicationSettings() }
        } message: {
            Text("In order to create and upload reports, \(UIApplication.appName ?? "This application") requires the use of your device's location services. You can enable them by pressing 'Enable Location Services', or going to the 'Settings' app > '\(UIApplication.appName ?? "This application")' > 'Location Services'.")
        }
    }
    
    private func presentComposeView() {
        switch CLLocationManager().authorizationStatus {
        case .notDetermined:
            CLLocationManager().requestWhenInUseAuthorization()
        case .restricted:
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
            self.alertLocationServicesDenied.toggle()
        case .denied:
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
            self.alertLocationServicesDenied.toggle()
        case .authorizedAlways:
            self.isShowingNewReportView.toggle()
        case .authorizedWhenInUse:
            self.isShowingNewReportView.toggle()
        case .authorized:
            self.isShowingNewReportView.toggle()
        @unknown default:
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
            self.alertLocationServicesDenied.toggle()
        }
    }
}

#Preview {
    FeedNewReportButtonView()
        .environmentObject(UserViewModel())
        .environmentObject(ReportsViewModel())
}
