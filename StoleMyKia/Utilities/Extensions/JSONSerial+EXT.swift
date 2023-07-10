//
//  JSONSerial+EXT.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/2/23.
//

import Foundation
import FirebaseFirestore

extension JSONSerialization {
    
    static func objectFromData<T: Codable>(_ object: T.Type, jsonObject: Any?) -> T? {
        guard let jsonObject else { return nil }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: jsonObject)
            let object = try JSONDecoder().decode(T.self, from: data)
            
            return object
        } catch {
            return nil
        }
    }
        
    static func createJsonFromObject<T: Codable>(_ object: T) throws -> Any? {
        let data = try JSONEncoder().encode(object)
        let jsonObject = try JSONSerialization.jsonObject(with: data)
        
        return jsonObject
    }
}
