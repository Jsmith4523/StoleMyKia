//
//  AES+EXT.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/23/23.
//

import Foundation
import CommonCrypto
import CryptoKit

struct EncryptedData: Codable, Hashable {
    let data: String
    let key: Data
    let iv: Data
}

enum EDEncryptionStatus: Error {
    case invalidData
    case encryptFailure(Int)
    case decryptError(Int)
    
    var reason: String {
        switch self {
        case .encryptFailure(let int):
            return "Encryption failed with error code \(int)"
        case .decryptError(let int):
            return "Decryption failed with error code \(int)"
        case .invalidData:
            return "Input data is invalid"
        }
    }
}

extension EncryptedData {

    func decode() -> String? {
        let buffSize = self.data.count + kCCBlockSizeAES128
                
        let buffer = Data(count: buffSize)
        
        return nil
    }

    static func createEncryption(input: String) throws -> Data? {
        
        //If the string is passed through as empty, go ahead and return nil
        guard !(input.isEmpty) else {
            return nil
        }
        
        let key   = SymmetricKey(size: .bits256)
        let iv    = SymmetricKey(size: .bits256)
        
        let input   = input
        let keyData = key.withUnsafeBytes { Data($0)}
        let ivData  = iv.withUnsafeBytes { Data($0)}
        
        guard let data = input.data(using: .utf8) else {
            throw EDEncryptionStatus.invalidData
        }
        
        let bufferSize = data.count + kCCBlockSizeAES128
        var buffer = [UInt8](repeating: 0, count: bufferSize)
        var encryptSize = 0
        
        let status = key.withUnsafeBytes { kBytes in
            iv.withUnsafeBytes { ivBytes in
                data.withUnsafeBytes { dBytes in
                    CCCrypt(UInt32(kCCEncrypt),
                            UInt32(kCCAlgorithmAES128),
                            UInt32(kCCOptionPKCS7Padding),
                            kBytes.baseAddress,
                            keyData.count,
                            ivBytes.baseAddress,
                            dBytes.baseAddress,
                            data.count,
                            &buffer,
                            bufferSize,
                            &encryptSize)
                }
            }
        }
        
        guard status == kCCSuccess else {
            throw EDEncryptionStatus.encryptFailure(Int(status))
        }
        
        let encryptedData = Data(bytes: buffer, count: encryptSize)
        let b64EncodeData = encryptedData.base64EncodedString()
                
        let encrytedData = EncryptedData(data: b64EncodeData, key: keyData, iv: ivData)
        
        guard let jsonObject = try? JSONSerialization.createJsonFromObject(encrytedData) else {
            fatalError("Unable to create json object from string!!")
        }
        
        let jsonData = try JSONSerialization.data(withJSONObject: jsonObject)
        
        return jsonData
    }
}
