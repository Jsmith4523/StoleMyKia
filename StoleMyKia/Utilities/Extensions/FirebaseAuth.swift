//
//  FirebaseAuth.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/10/23.
//

import Foundation
import FirebaseAuth

extension User? {
    
    
    var isSignedIn: Bool {
        !(self == nil)
    }
}
