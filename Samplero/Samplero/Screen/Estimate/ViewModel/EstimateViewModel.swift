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

    let db = DBHelper.shared

    var disposeBag: DisposeBag = DisposeBag()
    var db = DBHelper.shared
    
    let shopBasketSubject: BehaviorSubject<Int> = BehaviorSubject(value: 0)
    
    init() {
        shopBasketSubject.onNext(db.getShopBasketCount())
    }

    var samples: Samples = Samples()

    let shopBaskets: BehaviorSubject<[ShopBasket]>

    init() {
        let basketItems = db.getShopBasketItem()
        shopBaskets = BehaviorSubject(value: basketItems)

        basketItems.forEach { item in
            samples.addSample(sample: MockData.sampleList[item.sampleId])
        }
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

