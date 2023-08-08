//
//  JSONSerial+EXT.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/2/23.
//

import Foundation
import FirebaseFirestore

extension JSONSerialization {
    
    enum JSONSearizationError: Error {
        case incompatible
        case error
    }
    
    ///Create object from JSON Object.
    static func objectFromData<T: Codable>(_ object: T.Type, jsonObject: Any?) -> T? {
        guard let jsonObject = jsonObject as? [String: Any] else { return nil }
        
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
    
    static func createJsonFromObject<T: Encodable>(_ object: T) throws -> Any? {
        let data = try JSONEncoder().encode(object)
        let jsonObject = try JSONSerialization.jsonObject(with: data)
        
        return jsonObject
    }
    
    ///Creates QuerySnapshotData from input.
    static func objectsFromFoundationObjects<T: Codable>(_ jsonObjects: Any, to object: T.Type) throws -> [[T]] {
        guard let jsonObjects = jsonObjects as? [[String: Any]] else {
            throw Self.JSONSearizationError.incompatible
        }
        
        let data = try JSONSerialization.data(withJSONObject: jsonObjects)
        print(data)
        let objects = try JSONDecoder().decode([[T]].self, from: data)
        return objects
    }
}
