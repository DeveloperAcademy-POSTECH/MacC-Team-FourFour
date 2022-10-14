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
    func getImage() -> UIImage {
        return self.fileManager.getImage(imageName: self.matInsertedImageName + "\(imageIndex)", folderName: savingFolderName) ?? UIImage()
    }

    func getMaskedImage() -> UIImage {

        return self.fileManager.getImage(imageName: self.floorSegmentedImageName + "\(imageIndex)", folderName: savingFolderName) ?? UIImage()
    }
}


