//
//  UserReportsDelegate.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 5/28/23.
//

import Foundation

protocol UserReportsDelegate: AnyObject {
    
    ///Fetch reports made by the currently signed in user
    func getUserReports(completion: @escaping ((Result<[Report], Error>)->Void))
    
    ///Deletes all user reports
    func deleteAll(completion: @escaping ((Bool)->Void))
}
