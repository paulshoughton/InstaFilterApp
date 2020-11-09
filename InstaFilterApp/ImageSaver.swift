//
//  ImageSaver.swift
//  InstaFilterApp
//
//  Created by Paul Houghton on 06/11/2020.
//

import UIKit

class ImageSaver: NSObject {
    var successHandler: (() -> Void)?
    var errorHandler: ((Error) -> Void)?
    
    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveError), nil)
    }
    
    @objc func saveError(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo:UnsafeRawPointer) {
        
        if let error = error {
            errorHandler?(error)
            
        }
        else {
            successHandler?()
        }
        
    }
}
