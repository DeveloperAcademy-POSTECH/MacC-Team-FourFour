//
//  EstimateHistoryViewModel.swift
//  Samplero
//
//  Created by JiwKang on 2022/10/10.
//

import Foundation

import RxSwift

class EstimateHistoryViewModel {
    var disposeBag = DisposeBag()
    
    let estimateHistoryObservable = Observable.of(EstimateHistory.mockData)
}
