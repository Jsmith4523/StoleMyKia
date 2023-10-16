//
//  ImageCache.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/28/23.
//

import Foundation
import UIKit

open class ImageCache {
    
    static let shared = ImageCache()
    
    private var cache = NSCache<AnyObject, AnyObject>()
    
    private init() {
        listenForSignOut()
    }
    
    open func getImage(_ urlString: String?, completion: @escaping (UIImage?)->Void) {
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
    
    @objc
    private func removeAll() {
        cache.removeAllObjects()
    }
    
    ///Allows the ImageCache class to listen when the user has signed out the application
    private func listenForSignOut() {
        NotificationCenter.default.addObserver(self, selector: #selector(removeAll), name: .signOut, object: nil)
    }
        
    deinit {
        NotificationCenter.default.removeObserver(self, name: .signOut, object: nil)
    }
}
