//
//  LoginViewModel.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/25/23.
//

import Foundation
import FirebaseAuth
import Firebase


final class UserViewModel: ObservableObject {
    
    enum RootViewLoadStatus {
        case loading, loaded
    }
    
    @Published private(set) var userReports = [Report]()
    @Published private(set) var userBookmarks = [Report]()
    
    @Published private(set) var rootViewLoadStatus: RootViewLoadStatus = .loaded
                
    @Published private(set) var firebaseUser: FirebaseUser?
    @Published private var userUid: String?
    
    private let firebaseManager = FirebaseUserManager()
    
    func fetchUserInformation() async throws {
        guard let userUid else { return }
        self.firebaseUser = try await firebaseManager.fetchSignedInUserInformation(uid: userUid)
    }
    
    func fetchUsersReports() async throws -> [Report] {
        return try await firebaseManager.getUserReports()
    }
    
    @MainActor
    func fetchUserReports() async {
        guard let reports = try? await firebaseManager.getUserReports() else {
            return
        }
        
        self.userReports = reports
    }
    
    func bookmarkReport(_ id: UUID) async throws {
        try await firebaseManager.addBookmark(reportId: id)
    }
    
    func removeBookmark(_ id: UUID) async throws {
        try await firebaseManager.removeBookmark(reportId: id)
    }
    
    func reportIsBookmarked(_ id: UUID) async throws -> Bool {
        return try await firebaseManager.isBookmarked(id)
    }
    
    func signOut() {
        try? Auth.auth().signOut()
    }
        
    deinit {
        print("Dead: UserViewModel")
    }
}

//MARK: - FirebaseUserNotificationRadiusDelegate
extension UserViewModel: FirebaseUserNotificationRadiusDelegate {
    var usersRadius: Double? {
        guard let firebaseUser else {
            return nil
        }
        
        return firebaseUser.notificationSettings.notificationRadius
    }
    
    func setNewRadius(_ radius: Double, completion: @escaping (Bool) -> Void) {
        
    }
}

//MARK: - FirebaseAuthDelegate
extension UserViewModel: FirebaseAuthDelegate {
    func userHasSignedIn(uid: String) async -> LoginLoadStatus {
        do {
            self.userUid = uid
            self.firebaseUser = try await firebaseManager.fetchSignedInUserInformation(uid: uid)
            self.rootViewLoadStatus = .loaded
        } catch FirebaseUserManagerError.doesNotExist {
            //Sign the user out if data is not avaliable
            return .signedOut
        } catch {
            self.rootViewLoadStatus = .loaded
            return .signedIn
        }
        
        return .signedIn
    }
    
    func userHasSignedOut() {
        self.firebaseUser = nil
        firebaseManager.userIsSigningOut()
    }
}

//MARK: - FirebaseUserDelegate
extension UserViewModel: FirebaseUserDelegate {
    var uid: String? {
        return userUid ?? "12345"
    }
}
