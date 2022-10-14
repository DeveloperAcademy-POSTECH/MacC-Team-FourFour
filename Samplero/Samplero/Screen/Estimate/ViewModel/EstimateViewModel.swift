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

    var disposeBag: DisposeBag = DisposeBag()
    var db = DBHelper.shared
    
    let shopBasketSubject: BehaviorSubject<Int> = BehaviorSubject(value: 0)
    
    init() {
        shopBasketSubject.onNext(db.getShopBasketCount())
    }

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
