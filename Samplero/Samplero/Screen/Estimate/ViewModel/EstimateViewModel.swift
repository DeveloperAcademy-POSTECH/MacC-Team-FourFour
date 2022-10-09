//
//  EstimateViewModel.swift
//  Samplero
//
//  Created by DaeSeong on 2022/10/09.
//

import UIKit

import RxCocoa
import RxSwift

class EstimateViewModel: ViewModelType {

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
