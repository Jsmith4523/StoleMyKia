//
//  LoginViewModel.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/25/23.
//

import Foundation
import FirebaseAuth
import Firebase
import SwiftUI

enum RootViewLoadStatus {
    case loading, loaded
}

final class UserViewModel: ObservableObject {
    
    @Published private(set) var userReports = [Report]()
    @Published private(set) var userBookmarks = [Report]()
    
    @Published private(set) var rootViewLoadStatus: RootViewLoadStatus = .loading
                
    @Published private(set) var firebaseUser: FirebaseUser?
    @Published private var userUid: String?
    
    private let firebaseManager = FirebaseUserManager()
    weak var delegate: UserViewModelDelegate?
    
    init() {
        print("Alive: UserViewModel")
        firebaseManager.setDelegate(self)
    }
    
    func fetchUserInformation() async throws {
        guard let userUid else { return }
        self.firebaseUser = try await firebaseManager.fetchSignedInUserInformation(uid: userUid)
    }
    
    func fetchUsersReports() async throws -> [Report] {
        return try await firebaseManager.getUserReports()
    }
    
    func setDelegate(_ delegate: UserViewModelDelegate) {
        self.delegate = delegate
    }
    
    @MainActor
    func fetchUserReports() async throws {
        let reports = try await firebaseManager.getUserReports()
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
        delegate?.userDidSuccessfullySignOut()
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
    @MainActor
    func userHasSignedIn(uid: String) async -> LoginStatus {
        self.userUid = uid
        withAnimation {
            self.rootViewLoadStatus = .loaded
        }
        return .signedIn
    }
    
    func userHasSignedOut() {
        self.firebaseUser = nil
    }
}

//MARK: - FirebaseUserDelegate
extension UserViewModel: FirebaseUserDelegate {
    var uid: String? {
        return userUid
    }
}


protocol UserViewModelDelegate: AnyObject {
    func userDidSuccessfullySignOut()
}
