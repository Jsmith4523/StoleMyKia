//
//  UserReportsDelegate.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 5/28/23.
//

import Foundation

enum URReportsError: Error {
    case userReportsError
    case userUpdatesError
    case userBookmarksError
    case error(String)
    
    var description: String {
        switch self {
             
        case .userReportsError:
            return "Unable to fetch your reports!"
        case .userUpdatesError:
            return "Unable to fetch your updates!"
        case .userBookmarksError:
            return "Unable to fetch your bookmarks!"
        case .error(let reason):
            return reason
        }
    }
}

protocol UserReportsDelegate: AnyObject {
    
    func getUserReports(completion: @escaping ((Result<[Report], URReportsError>)->Void))
    func getUserUpdates(completion: @escaping (Result<[Report], URReportsError>) -> Void)
    func getUserBookmarks(removalCompletion: @escaping RemovalCompletion, completion: @escaping (Result<[Report], URReportsError>) -> Void)
    
    func deleteAll(completion: @escaping ((Bool)->Void))
}
