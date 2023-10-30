//
//  FeedLocationServicesDisabledView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 10/28/23.
//

import SwiftUI
import CoreLocation

struct FeedLocationServicesDisabledView: View {
    var body: some View {
        VStack(spacing: 15) {
            Spacer()
                .frame(height: 150)
            Image(systemName: "location.slash")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
            VStack(spacing: 7) {
                Text("Location Services Disabled")
                    .font(.system(size: 19).weight(.heavy))
                Text("Please enable location services for \(UIApplication.appName ?? "this application") in order to use this feature. Then refresh this screen.")
                    .font(.system(size: 17))
                    .multilineTextAlignment(.center)
            }
            Spacer()
                .frame(height: 50)
            Button {
                requestLocationServices()
            } label: {
                Text("Enable Access")
                    .authButtonStyle(background: .blue)
            }
            Spacer()
        }
        .padding()
    }
    
    private func requestLocationServices() {
        switch CLLocationManager.shared.authorizationStatus {
        case .denied:
            URL.openApplicationSettings()
        case .restricted:
            URL.openApplicationSettings()
        case .notDetermined:
            CLLocationManager.shared.requestAlwaysAuthorization()
        default:
            break
        }
    }
}

#Preview {
    ScrollView {
        FeedLocationServicesDisabledView()
    }
}
