//
//  AVCaptureSession+Rx.swift
//  Samplero
//
//  Created by DaeSeong on 2022/11/05.
//

import AVFoundation

import RxSwift

extension Reactive where Base: AVCaptureSession {

    public func startRunning() {
        DispatchQueue.global().async {
              self.base.startRunning()
          }
      }

      public func stopRunning() {
          DispatchQueue.global().async {
              self.base.stopRunning()
          }
      }

    @available(iOS 11.0, *)
    func photoCaptureOutput(photoOutput: AVCapturePhotoOutput,
                                   photoCaptureDelegate: RxAVCapturePhotoCaptureDelegate) -> Observable<PhotoCaptureOutput> {
//            let photoOutput = AVCapturePhotoOutput()
//            let photoCaptureDelegate = RxAVCapturePhotoCaptureDelegate()
            let photoCaptureOutput: Observable<PhotoCaptureOutput> = Observable
                .create { observer in
                    photoCaptureDelegate.observer = observer

//                    self.configure { session in
//                        if session.canAddOutput(photoOutput) {
//                            session.addOutput(photoOutput)
//                        } else {
//                            observer.onError(RxAVFoundationError.cannotAddOutput("Photo"))
//                        }
//                    }
                    return Disposables.create {
                        self.configure { session in
                            session.removeOutput(photoOutput)
                        }
                    }
                }
                .subscribe(on: MainScheduler.asyncInstance)
            //            .observeOn(Scheduler.dataOutput)
            return photoCaptureOutput
        }

    private func configure(lambda: (AVCaptureSession) -> Void) {
            self.base.beginConfiguration() // beginConfiguration : captureSession의 설정 변경의 시작을 알리는 함수.
            lambda(self.base)
            self.base.commitConfiguration() // captureSession 의 설정 변경이 완료되었음을 알리는 함수.
        }
}

public enum RxAVFoundationError: Error {
    case noConnection(String)
    case cannotAddOutput(String)
}
