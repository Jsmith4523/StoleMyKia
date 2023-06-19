//
//  NotificationRadiusView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/19/23.
//

import SwiftUI

struct NotificationRadiusView: View {
    
    @StateObject private var radiusMapCoordinator = NotificationRadiusMapViewCoordinator()
    @EnvironmentObject var userModel: UserViewModel
    
    @Environment (\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                NotificationRadiusMapView(radiusMapCoordinator: radiusMapCoordinator)
                    .frame(height: 300)
                VStack {
                    Spacer()
                    Slider(value: $radiusMapCoordinator.radius, in: NotificationRadiusMapViewCoordinator.radiusRange)
                    Spacer()
                }
                .padding()
                Spacer()
            }
            .navigationTitle("Radius")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .bold()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        setNewRadius()
                    }
                    .bold()
                    .disabled(!radiusMapCoordinator.canBeUpdated)
                }
            }
            .alert("That's an error", isPresented: $radiusMapCoordinator.alertRadiusError) {
                Button("OK") { dismiss() }
            } message: {
                Text(radiusMapCoordinator.alertRadiusErrorReason.rawValue)
            }
            .onAppear {
                radiusMapCoordinator.setDelegate(userModel)
            }
        }
    }
    
    private func setNewRadius() {
        radiusMapCoordinator.saveNewRadius {
            self.dismiss()
        }
    }
}

struct NotificaitonRadiusView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            NotificationRadiusView()
        }
    }
}
