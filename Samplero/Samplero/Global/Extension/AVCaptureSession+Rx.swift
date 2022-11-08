//
//  AVCaptureSession+Rx.swift
//  Samplero
//
//  Created by DaeSeong on 2022/11/05.
//

import AVFoundation

import RxSwift

extension Reactive where Base: AVCaptureSession {

    func startRunning() {
        DispatchQueue.global().async {
            self.base.startRunning()
        }
    }

    func stopRunning() {
        DispatchQueue.global().async {
            self.base.stopRunning()
        }
    }

    func photoCaptureOutput(photoOutput: AVCapturePhotoOutput,
                            photoCaptureDelegate: RxAVCapturePhotoCaptureDelegate) -> Observable<PhotoCaptureOutput> {

        let photoCaptureOutput: Observable<PhotoCaptureOutput> = Observable
            .create { observer in
                photoCaptureDelegate.observer = observer

                return Disposables.create {
                    self.configure { session in
                        session.removeOutput(photoOutput)
                    }
                }
            }
            .subscribe(on: MainScheduler.asyncInstance)
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
