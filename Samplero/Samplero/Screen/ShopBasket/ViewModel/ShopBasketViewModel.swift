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
    let wishedSampleObservable = Observable.of(MockData.sampleList)
}
