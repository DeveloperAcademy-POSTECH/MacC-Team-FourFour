//
//  EstimateHistoryViewModel.swift
//  Samplero
//
//  Created by JiwKang on 2022/10/10.
//  Modified by Cozy on 2022/11/03.
//

import Foundation

import RxCocoa
import RxSwift

class EstimateHistoryViewModel: ViewModelType {
    
    // MARK: - Properties
    
    let db = DBHelper.shared
    var disposeBag = DisposeBag()

    struct Input {
        let viewWillAppear: ControlEvent<Bool>
        let itemSelected: ControlEvent<IndexPath>
    }

    struct Output {
        let isEmptyCell: Observable<Bool>
        let estimateHistorySubject: Observable<[EstimateHistory]>
        let tappedItem: Observable<IndexPath>
    }

    func transform(input: Input) -> Output {
        let estimateHistorySubject: BehaviorSubject<[EstimateHistory]> = BehaviorSubject(value: db.getEstimateHistories())

        let isEmptyCell = input.viewWillAppear
            .withLatestFrom(estimateHistorySubject)
            .map { $0.count > 0 ? true : false }

        let tappedItem = input.itemSelected
            .asObservable()

        return Output(isEmptyCell: isEmptyCell, estimateHistorySubject: estimateHistorySubject, tappedItem: tappedItem)
    }
}
