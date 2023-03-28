//
//  ImageCache.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/28/23.
//

import Foundation
import UIKit

class ImageCache {
    
    let cache = NSCache<AnyObject, AnyObject>()
    
    func getImage(_ url: URL, completion: @escaping (UIImage?)->Void) {
        if let image = cache.object(forKey: url.absoluteString as AnyObject) as? UIImage {
            completion(image)
            return
        }
        
        URLSession.shared.getData(url) { data in
            guard let data, let image = UIImage(data: data) else {
                completion(nil)
                return
            }
            self.cache.setObject(image, forKey: url.absoluteString as AnyObject)
            completion(image)
        }
    }
}
