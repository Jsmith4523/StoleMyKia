//
//  ImageCache.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/28/23.
//

import Foundation
import UIKit

class ImageCache {
    
    static let shared = ImageCache()
    
    private var cache = NSCache<AnyObject, AnyObject>()
    
    private init() {}
    
    func getImage(_ urlString: String?, completion: @escaping (UIImage?)->Void) {
        if let image = cache.object(forKey: urlString as AnyObject) as? UIImage {
            completion(image)
            return
        }
        
        guard let urlString, let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.getData(url) { [weak self] data in
            guard let data, let image = UIImage(data: data) else {
                completion(nil)
                return
            }
            self?.cache.setObject(image, forKey: url.absoluteString as AnyObject)
            completion(image)
        }
    }
    
    func removeFromCache(_ urlString: String?) {
        guard let urlString else {
            return
        }
        cache.removeObject(forKey: urlString as AnyObject)
    }
    
    deinit {
        print("Cache class is being destroyed!!")
    }
}
