//
//  ShopBasketViewModel.swift
//  Samplero
//
//  Created by DaeSeong on 2022/10/12.
//

import UIKit

import RxCocoa
import RxSwift

class ShopBasketViewModel {

    var disposeBag: DisposeBag = DisposeBag()
//    let wishedSampleObservable = Observable.of(MockData.sampleList)
let wishedSampleObservable = BehaviorRelay<[Sample]>(value: MockData.sampleList)

    let remove = PublishSubject<Sample>()
var selectedSample = PublishRelay<Sample>()



    init() {

        remove.map{ removedSample in
                print(removedSample.matName)
                    return self.wishedSampleObservable.value.filter { sample -> Bool in
                        sample.matName != removedSample.matName
                    }
                    }
                    .bind(to: wishedSampleObservable)
                    .disposed(by: disposeBag)
    }
}
