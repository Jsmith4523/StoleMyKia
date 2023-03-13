//
//  URL+EXT.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/13/23.
//

import Foundation
import UIKit

extension URL {
    
    static func applicationSettings() -> String {
        UIApplication.openSettingsURLString
    }
}
