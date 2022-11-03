//
//  CameraViewModel.swift
//  Samplero
//
//  Created by JiwKang on 2022/10/14.
//

import AVFoundation
import Foundation
import CoreML
import Vision

import RxSwift

class CameraViewModel: ViewModelType {

    // MARK: - Properties
    
    let db = DBHelper.shared
    
    var disposeBag = DisposeBag()
    
    let estimateHistoryObservable: Observable<[EstimateHistory]>
    
    let shopBasketSubject: BehaviorSubject<Int> = BehaviorSubject(value: 0)
    // Photo Output
    let photoOutput = AVCapturePhotoOutput()

    
    init () {
        var estimateHistories: [EstimateHistory] = []
        estimateHistories = db.getEstimateHistories()
        
        estimateHistoryObservable = Observable.of(estimateHistories)
        
        shopBasketSubject.onNext(db.getShopBasketCount())
    }

    struct Input { }
    struct Output { }
    func transform(input: Input) -> Output {
        return Output()
    }


    private func checkCameraPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            // Request
            AVCaptureDevice.requestAccess(for: .video) { granted in
                guard granted else {
                    return
                }
                DispatchQueue.main.async {
                    self.setUpCamera()
                }
            }
        case .restricted:
            break
        case .denied:
            break
        case .authorized:
            setUpCamera()
        @unknown default:
            break
        }
    }

    private func setUpCamera() {
        let session = AVCaptureSession()
        if let device = AVCaptureDevice.default(for: .video) {
            do {
                let input = try AVCaptureDeviceInput(device: device)
                if session.canAddInput(input) {
                    session.addInput(input)
                }

                if session.canAddOutput(photoOutput) {
                    session.addOutput(photoOutput)
                }

                previewLayer.videoGravity = .resizeAspectFill
                previewLayer.session = session

                DispatchQueue.global().async {
                    session.startRunning()
                }
                self.session = session
            } catch {
                print(error)
            }
        }
    }


    private func segmentFloor() {
        guard let model = try? VNCoreMLModel(for: FloorSegmentation.init(configuration: .init()).model)
        else { return }
        let request = VNCoreMLRequest(model: model, completionHandler: self.visionRequestDidComplete)
        request.imageCropAndScaleOption = .scaleFill
        DispatchQueue.global().async {
            guard let takenImageData = self.takenPicture.jpegData(compressionQuality: 1.0) else { return }
            let handler = VNImageRequestHandler(data: takenImageData, options: [:])
            do {
                try handler.perform([request])
            } catch {
                print(error)
            }
        }
    }

    private func visionRequestDidComplete(request: VNRequest, error: Error?) {
        DispatchQueue.main.async { [self] in
            if let observations = request.results as? [VNCoreMLFeatureValueObservation],
               let segmentationMap = observations.first?.featureValue.multiArrayValue {
                guard let segmentationMask = segmentationMap.image(min: 0, max: 1) else { return }

                self.takenPictureIndex = self.db.getEstimateHistoryCount() + 1



                if segmentationMask.size != self.takenPicture.size {
                    guard let resizedMask = segmentationMask.resizedImage(for: self.takenPicture.size) else { return }
                    self.fileManager.saveImage(image: resizedMask, imageName: self.floorSegmentedImageName + String(describing: self.takenPictureIndex!), folderName: self.savingFolderName)
                } else {
                    self.fileManager.saveImage(image: segmentationMask, imageName: self.floorSegmentedImageName + String(describing: self.takenPictureIndex!), folderName: self.savingFolderName)
                }


                self.fileManager.saveImage(image: self.takenPicture, imageName: self.matInsertedImageName + String(describing: self.takenPictureIndex!), folderName: self.savingFolderName)

                self.db.insertEstimateHistory(history: EstimateHistory(imageId: self.takenPictureIndex, width: nil, height: nil, selectedSampleId: nil))


                self.takenPictureViewController.dismiss(animated: true)
                var estimateVC = EstimateViewController()
                estimateVC.bindViewModel(EstimateViewModel())
                estimateVC.viewModel.imageIndex = self.takenPictureIndex
                self.navigationController?.pushViewController(estimateVC, animated: true)

                self.takenPictureViewController.stopLottieAnimation() // 로티 종료
            }
        }
    }
}
