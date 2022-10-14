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

    private let savingfolderName: String = "estimate-photo"
    private let floorSegmentedImageName: String = "floor-segmented-photo-"
    private let matInsertedImageName: String = "mat-inserted-photo-"

    var disposeBag: DisposeBag = DisposeBag()

    struct Input {
        let collectionModelSelected: ControlEvent<Sample>
    }

    struct Output {
        let SampleList: Observable<[Sample]>
        let tappedSample: Observable<Sample>
    }

    func transform(input: Input) -> Output {
        let sampleList = Observable.of(MockData.sampleList)

        let selected = input.collectionModelSelected.asObservable()


        return Output(SampleList: sampleList, tappedSample: selected)
    }
}

extension EstimateViewModel {
    func getImage(imageId id: Int) -> UIImage {
        var image: UIImage!
        estimateHistorySubject
            .map { histories in
                histories.filter { $0.imageId == id }.first?.imageId
            }
            .subscribe(onNext: { imageId in
                image = self.fileManager.getImage(imageName: self.floorSegmentedImageName + "\(imageId ?? 0)", folderName: self.savingfolderName)
            })
            .disposed(by: disposeBag)
        return image
    }

    func getMaskedImage(imageId id: Int) -> UIImage {
        var image: UIImage!
        estimateHistorySubject
            .map { histories in
                histories.filter { $0.imageId == id }.first?.imageId
            }
            .subscribe(onNext: { imageId in
                image = self.fileManager.getImage(imageName: self.matInsertedImageName + "\(imageId ?? 0)", folderName: self.savingfolderName)
            })
            .disposed(by: disposeBag)
        return image
    }
}


