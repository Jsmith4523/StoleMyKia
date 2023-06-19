//
//  JSONSerial+EXT.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/2/23.
//

import Foundation
import FirebaseFirestore

extension JSONSerialization {
    
    static func createObjectWithData<T: Codable>(_ object: T.Type, jsonObject: Any?) throws -> T? {
        guard let jsonObject else {
            return nil
        }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: jsonObject)
            let decodedObject = try JSONDecoder().decode(T.self, from: data)
            
            return decodedObject
        } catch {
            print("Object with data error: \(error.localizedDescription)")
            throw error
        }
    }
        
    static func objectsFromSnapshot<O, T: Codable>(_ objects: [O], to target: [T.Type]) throws -> [T] {
        if let objects = objects as? [QueryDocumentSnapshot] {
            return try objects.compactMap {
                try $0.createFromObject(T.self)
            }
        } else {
            return try objects.compactMap {
                try Self.createObjectWithData(T.self, jsonObject: $0)
            }
        }
    }
    
    static func createJsonFromObject<T: Codable>(_ object: T) throws -> Any? {
        let data = try JSONEncoder().encode(object)
        let jsonObject = try JSONSerialization.jsonObject(with: data)
        
        return jsonObject
    }
}
