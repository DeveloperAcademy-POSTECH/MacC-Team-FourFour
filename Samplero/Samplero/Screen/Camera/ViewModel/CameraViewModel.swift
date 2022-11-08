//
//  CameraViewModel.swift
//  Samplero
//
//  Created by JiwKang on 2022/10/14.
//

import AVFoundation
import UIKit
import Vision

import RxSwift
import RxCocoa

private enum Name {
    static let savingFolderName: String = "estimate-photo"
    static let floorSegmentedImageName: String = "floor-segmented-photo-"
    static let matInsertedImageName: String = "mat-inserted-photo-"
}

class CameraViewModel: ViewModelType {
    // MARK: - Properties
    
    let db = DBHelper.shared
    let fileManager = LocalFileManager.instance

    var disposeBag = DisposeBag()

    private var takenPictureIndex: Int!

    private let coordinator: CameraCoordinator

    required init(coordinator: CameraCoordinator) {
        self.coordinator = coordinator
    }

    struct Input {
        //        let viewDidLoad: ControlEvent<Void>
        let viewWillAppear: ControlEvent<Bool>
        let tappedPhotoHistoryButton: ControlEvent<Void>
        let tappedPickerDidCancel: Observable<Void>
        let tappedBringPhotoButton: Observable<UIImagePickerController>
        let tappedCartButton: ControlEvent<Void>
        let tappedXMarkButton: Observable<Void>
        let tappedNextButton: Observable<Void>
        let tappedRetakeButton: Observable<Void>
        let photoOutput: Observable<PhotoCaptureOutput>
        let didFinishPicking: Observable<UIImage>
    }

    struct Output {
        let viewWillAppear: ControlEvent<Bool>
        let lastHistoryImage: Observable<UIImage?>
        //        let cameraPermissionStatus: Observable<AVAuthorizationStatus>
        let capturedImage: Observable<UIImage>
        let shopBasketCountString: Observable<String>
    }

    func transform(input: Input) -> Output {

        let vnRequest: BehaviorRelay<VNRequest> = BehaviorRelay(value: VNRequest())
        let capturedImage: BehaviorRelay<UIImage> = BehaviorRelay(value: UIImage())
        let shopBasketCount: BehaviorSubject<Int> = BehaviorSubject(value: 0)

        takenPictureIndex = db.getEstimateHistoryCount() + 1

        let shopBasketCountString = input.viewWillAppear
            .withLatestFrom(shopBasketCount)
            .map { _ in return self.db.getShopBasketCount() }
            .map { count in
                if count >= 99 { return " 99+ "
                } else { return " \(count) " } }

        let lastHistoryImage = Observable.of(db.getEstimateHistories())
            .map { histories in
                return Name.matInsertedImageName
                + "\(histories.last?.imageId ?? 0)"
            }
            .map { imageName in
                return self.fileManager.getImage(imageName: imageName,
                                                 folderName: Name.savingFolderName)
            }

        //        let cameraPermissionStatus = input.viewDidLoad
        //            .flatMap { _ in
        //                return self.requestCameraPermission()
        //            }


        Observable.of(input.didFinishPicking,
                      input.photoOutput
                          .map { $0.photo }
                          .compactMap { $0.fileDataRepresentation() }
                          .compactMap { UIImage(data: $0)}
        )
        .merge()
        .bind(to: capturedImage)
        .disposed(by: disposeBag)

        input.tappedPhotoHistoryButton
            .subscribe { _ in
                self.coordinator.showEstimateHistory()
            }.disposed(by: disposeBag)

        input.tappedPickerDidCancel
            .subscribe { _ in
                self.coordinator.hidePresentView()
            }.disposed(by: disposeBag)

        input.tappedBringPhotoButton
            .subscribe { imagePickerVC in
                self.coordinator.showImagePicker(imagePickerVC: imagePickerVC)
            }.disposed(by: disposeBag)

        input.tappedCartButton
            .subscribe { _ in
                self.coordinator.showShopBasket()
            }.disposed(by: disposeBag)

        input.tappedXMarkButton
            .subscribe { _ in
                UserDefaults.standard.set(true, forKey: "isClosedHelpView")
            }.disposed(by: disposeBag)

        input.tappedNextButton.withLatestFrom(capturedImage)
            .asObservable()
            .observe(on: SerialDispatchQueueScheduler.init(qos: .userInitiated))
            .compactMap { takenPicture in
                return takenPicture.jpegData(compressionQuality: 1.0)
            }
            .subscribe(onNext: { capturedImageData in
                guard let model = try? VNCoreMLModel(for: FloorSegmentation.init(configuration: .init()).model) else { return }

                let request = VNCoreMLRequest(model: model) { request, _ in
                    vnRequest.accept(request)
                }

                request.imageCropAndScaleOption = .scaleFill
                do {
                    try VNImageRequestHandler(data: capturedImageData, options: [:])
                        .perform([request])
                } catch {
                    print("error")
                }
            })
            .disposed(by: disposeBag)

        input.tappedRetakeButton
            .subscribe(onNext: { _ in
                self.coordinator.hidePresentView()
            })
            .disposed(by: disposeBag)


        vnRequest
            .skip(1)
            .subscribe(on: MainScheduler.asyncInstance)
            .compactMap { $0.results as? [VNCoreMLFeatureValueObservation] }
            .compactMap { $0.first?.featureValue.multiArrayValue }
            .compactMap { $0.image(min: 0, max: 1) }
            .map { segmentationMask in
                if segmentationMask.size != capturedImage.value.size {
                    guard let resizedMask = segmentationMask.resizedImage(for: capturedImage.value.size) else { return }
                    self.fileManager.saveImage(image: resizedMask, imageName: Name.floorSegmentedImageName + String(describing: self.takenPictureIndex!), folderName: Name.savingFolderName)
                } else {
                    self.fileManager.saveImage(image: segmentationMask, imageName: Name.floorSegmentedImageName + String(describing: self.takenPictureIndex!), folderName: Name.savingFolderName)
                }
            }
            .map { _ in
                self.fileManager.saveImage(image: capturedImage.value, imageName: Name.matInsertedImageName + String(describing: self.takenPictureIndex!), folderName: Name.savingFolderName)

                self.db.insertEstimateHistory(history: EstimateHistory(imageId: self.takenPictureIndex, width: nil, height: nil, selectedSampleId: nil))
            }
            .compactMap { _ in
                return self.takenPictureIndex
            }
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { takenPictureIndex in
                self.coordinator.showEstimate(takenPictureIndex: takenPictureIndex)
            }).disposed(by: disposeBag)


        capturedImage
            .skip(1)    // 초기값인 빈 이미지를 막기 위해서 사용
            .subscribe { image in
                self.coordinator.showTakenPicture(image: image)
            }.disposed(by: disposeBag)

        shopBasketCount.onNext(db.getShopBasketCount())

        return Output(viewWillAppear: input.viewWillAppear,
                      lastHistoryImage: lastHistoryImage,
                      //                      cameraPermissionStatus: cameraPermissionStatus,
                      capturedImage: capturedImage.asObservable(),
                      shopBasketCountString: shopBasketCountString)
    }

}

extension CameraViewModel {
    
    func requestCameraPermission() -> Observable<AVAuthorizationStatus> {
        Observable<AVAuthorizationStatus>.create { observer in
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            observer.onNext(status)
            return Disposables.create { observer.onCompleted() }
        }
    }

}
