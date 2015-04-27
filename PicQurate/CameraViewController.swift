//
//  CameraViewController.swift
//  PicQurate
//
//  Created by SongXujie on 25/04/2015.
//  Copyright (c) 2015 SK8 PTY LTD. All rights reserved.
//

import Foundation
import GPUImage

@objc public protocol CameraViewControllerDelegate {
    func onPhotoTaken(image: UIImage);
}

class CameraViewController: IMGLYCameraViewController {
    
    weak var delegate:CameraViewControllerDelegate?
    
    // MARK: - Completion
    override
    func editorCompletionBlock(result:IMGLYEditorResult, image:UIImage?) {
        if let image = image where result == IMGLYEditorResult.Done {
            UIImageWriteToSavedPhotosAlbum(image, self, "image:didFinishSavingWithError:contextInfo:", nil);
            self.delegate?.onPhotoTaken(image);
        }
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
}