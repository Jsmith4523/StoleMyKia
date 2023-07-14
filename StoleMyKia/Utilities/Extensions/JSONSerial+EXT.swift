//
//  JSONSerial+EXT.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/2/23.
//

import Foundation
import FirebaseFirestore

extension JSONSerialization {
    
    ///Create object from input.
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
        
    ///Create JSON from Encodable Object.
    static func createJsonFromObject<T: Codable>(_ object: T) throws -> Any? {
        let data = try JSONEncoder().encode(object)
        let jsonObject = try JSONSerialization.jsonObject(with: data)
        
        return jsonObject
    }
    
    ///Creates objects from input.
    static func objectsFromFoundationObjects<T: Codable>(_ jsonObjects: Any, to object: T.Type) throws -> [T] {
        let data = try JSONSerialization.data(withJSONObject: jsonObjects)
        let objects = try JSONDecoder().decode([T].self, from: data)
        return objects
    }
}
