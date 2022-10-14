//
//  TermsViewModel.swift
//  Samplero
//
//  Created by Minkyeong Ko on 2022/10/13.
//

import Foundation

import RxCocoa
import RxSwift

class TermsViewModel {
    var disposeBag = DisposeBag()
    
    var checkboxObservable: BehaviorSubject<Bool>
    
    init() {
        self.checkboxObservable = BehaviorSubject(value: false)
    }
}
