//
//  EstimateViewModel.swift
//  Samplero
//
//  Created by DaeSeong on 2022/10/09.
//

import UIKit

import RxCocoa
import RxSwift

final class EstimateViewModel: ViewModelType {
    var imageIndex: Int = 0
    private let savingFolderName: String = "estimate-photo"
    private let floorSegmentedImageName: String = "floor-segmented-photo-"
    private let matInsertedImageName: String = "mat-inserted-photo-"

    let fileManager = LocalFileManager.instance
    let db = DBHelper.shared
    var disposeBag: DisposeBag = DisposeBag()

    let samplesRelay = BehaviorRelay<[Sample]>(value: []) // 현재샘플이 이전에 담기를 했는지 안했는지 확인용도
    let currentSample: BehaviorRelay<Sample> = BehaviorRelay(value: MockData.sampleList[0])
    var lastSelectedImage = UIImage()
    
    struct Input {
        let viewWillAppear: ControlEvent<Bool>
        let viewWillDisappear: ControlEvent<Bool>
        let collectionModelSelected: ControlEvent<Sample>
        let addButtonSelected: ControlEvent<Void>
        let inputAreaSelected: ControlEvent<Void>
        let inputAreaAgainSelected: ControlEvent<Void>
        let cartButtonSelected: ControlEvent<Void>
        let getAreaSaveButtonSelected: Observable<(Double, Double)>
        let goShopBasketLabelSelected: ControlEvent<UITapGestureRecognizer>
    }

    struct Output {
        let viewWillAppear: Observable<String>
        let SampleList: Observable<[Sample]>
        let resultImage: Observable<UIImage?>
        let tappedSample: Observable<Sample>
        let tappedAddButton: Observable<Void>
        let tappedInputArea: Observable<Void>
        let tappedInputAreaAgain: Observable<Void>
        let tappedCartButton: Observable<Void>
        let tappedGetAreaSaveButton: Observable<[CGFloat]>
        let tappedGoShopBasketLabel: Observable<Void>
    }

    func transform(input: Input) -> Output {
        let sampleList = Observable.of(MockData.sampleList)

        let shopBasketCount: BehaviorSubject<Int> = BehaviorSubject(value: db.getShopBasketCount())
        let shopBaskets: BehaviorSubject<[ShopBasket]> = BehaviorSubject(value: db.getShopBasketItem())

        let selectedCollection = input.collectionModelSelected
            .map { sample in
            self.currentSample.accept(sample) }
            .withLatestFrom(self.currentSample)

        let selectedAddButton = input.addButtonSelected
            .withLatestFrom(samplesRelay)
            .map { samples in
                var samples = samples
                samples.append(self.currentSample.value)
                self.db.insertItemToShopBasket(item: ShopBasket(id: 0, sampleId: self.currentSample.value.id))
                shopBasketCount.onNext(self.db.getShopBasketCount())
                self.samplesRelay.accept(samples)
            }
        
        let selectedInputArea = input.inputAreaSelected.asObservable()

        let selectedInputAreaAgain = input.inputAreaAgainSelected.asObservable()

        let selectedCartButton = input.cartButtonSelected.asObservable()

        let selectedGetAreaSaveButton = input.getAreaSaveButtonSelected.map { width, height in
            self.calculatePrice(width: width, height: height)
        }
        
        let selectedGoShopBasketLabel = input.goShopBasketLabelSelected.map { _ in}.asObservable()

        shopBaskets
            .map { basketItems in
                var samples: [Sample] = []
                basketItems.forEach { item in
                    samples.append(MockData.sampleList[item.sampleId])
                }
                return samples
            }
            .bind(to: samplesRelay)
            .disposed(by: disposeBag)

        let willAppear = input.viewWillAppear
            .map { _ in
                shopBaskets.onNext(self.db.getShopBasketItem())
                shopBasketCount.onNext(self.db.getShopBasketCount())
            }
                .withLatestFrom(shopBasketCount)
                .map { count in
                    if count >= 99 {
                        return " 99+ "
                    } else {
                        return " \(count) "
                    }
                }

        let notInitialResultImage = input.collectionModelSelected
            .map { sample in
                return self.maskInputImage(with: sample, sourceImage: self.getImage(), maskedImage: self.getMaskedImage())
            }

        let initialResultImage = input.viewWillAppear
            .withLatestFrom(currentSample)
            .map { sample in
                self.maskInputImage(with: sample, sourceImage: self.getImage(), maskedImage: self.getMaskedImage())
            }

        let resultImage = Observable.of(initialResultImage,notInitialResultImage).merge()


        input.viewWillDisappear
            .subscribe { _ in
                self.fileManager.saveImage(image: self.lastSelectedImage, imageName: self.matInsertedImageName + String(describing: self.imageIndex), folderName: self.savingFolderName)
            }.disposed(by: disposeBag)

            return Output(
                        viewWillAppear: willAppear,
                          SampleList: sampleList,
                            resultImage: resultImage,
                          tappedSample: selectedCollection,
                          tappedAddButton: selectedAddButton,
                          tappedInputArea: selectedInputArea,
                        tappedInputAreaAgain: selectedInputAreaAgain,
                          tappedCartButton: selectedCartButton,
                        tappedGetAreaSaveButton: selectedGetAreaSaveButton,
                          tappedGoShopBasketLabel: selectedGoShopBasketLabel)
        }
    }



extension EstimateViewModel {
    func getImage() -> UIImage {
        return self.fileManager.getImage(imageName: self.matInsertedImageName + "\(imageIndex)", folderName: savingFolderName) ?? UIImage()

    }

    func getMaskedImage() -> UIImage {

        return self.fileManager.getImage(imageName: self.floorSegmentedImageName + "\(imageIndex)", folderName: savingFolderName) ?? UIImage()
    }

    private func calculatePrice(width: CGFloat, height: CGFloat) -> [CGFloat] {
        let sampleArea = currentSample.value.size.width * currentSample.value.size.height
        let estimatedQuantity = width*height / sampleArea
        let estimatedPrice = currentSample.value.matPrice == -1 ? -1 : CGFloat(currentSample.value.matPrice) * estimatedQuantity
        // FIXME: - 배열 말고 다른 방식 사용하기
        return [estimatedQuantity, estimatedPrice, CGFloat(currentSample.value.matPrice)]
    }

    func maskInputImage(with sample: Sample, sourceImage: UIImage, maskedImage: UIImage) -> UIImage? {
        let takenCIImage = CIImage(cgImage: sourceImage.cgImage!)
        let beginImage = takenCIImage.oriented(CGImagePropertyOrientation(sourceImage.imageOrientation))
        let spreadMatName = sample.imageName.replacingOccurrences(of: "Thumbnail", with: "Spread")
        let backgroundImage = UIImage.load(named: spreadMatName)
        guard let backgroundCGImage = backgroundImage.cgImage else { return nil }

        guard let resizedBackgroundImage = backgroundCGImage.resize(size: sourceImage.size) else { return nil }

        let background = CIImage(cgImage: resizedBackgroundImage)
        let mask = CIImage(cgImage: maskedImage.cgImage!)

        let parameters = [
            kCIInputImageKey: beginImage,
            kCIInputBackgroundImageKey: background,
            kCIInputMaskImageKey: mask
        ]

        guard let compositeImage = CIFilter(name: "CIBlendWithMask", parameters: parameters )?.outputImage else {
            return nil
        }
        let ciContext = CIContext(options: nil)
        guard let filteredImageRef = ciContext.createCGImage(compositeImage, from: compositeImage.extent) else { return nil }
        self.lastSelectedImage = UIImage(cgImage: filteredImageRef)
        return self.lastSelectedImage
    }
}
