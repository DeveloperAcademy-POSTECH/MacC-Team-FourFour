//
//  RxAVCapturePhotoCaptureDelegateProxy.swift
//  Samplero
//
//  Created by DaeSeong on 2022/11/05.
//
import AVFoundation
import UIKit

import RxCocoa
import RxSwift



@available(iOS 11.0, *)
public typealias PhotoCaptureOutput = (output: AVCapturePhotoOutput, photo: AVCapturePhoto, error: Error?)

@available(iOS 11.0, *)
final class RxAVCapturePhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {

    typealias Observer = AnyObserver<PhotoCaptureOutput>

    var observer: Observer?

    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        observer?.on(.next(PhotoCaptureOutput(output, photo, error)))
    }

}

