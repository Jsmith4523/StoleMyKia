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
    let key: String
    let iv: String
}

extension EncryptedData {

    func decode() -> String? {
        let buffSize = self.data.count + kCCBlockSizeAES128
        
        let buffer = Data(count: buffSize)
        
        return nil
    }

    static func createEncryption(input: String) -> EncryptedData? {
        
        //This is all very much new code to me
        //I am doing the best of properly encrypting data
        
        let key   = Data(count: kCCKeySizeAES128)
        let input = input
        let iv    = Data(count: kCCBlockSizeAES128) //TODO: Generate randomly each time the method is called
        
        guard let data = input.data(using: .utf8) else {
            return nil
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
                            key.count,
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
            print("Encryption failed: \(status)")
            return nil
        }
        
        let encryptedData = Data(bytes: buffer, count: encryptSize)
        let b64EncodeData = encryptedData.base64EncodedString()
                
        let encrytedData = EncryptedData(data: b64EncodeData, key: key.base64EncodedString(), iv: iv.base64EncodedString())
        
        return encrytedData
    }
}
