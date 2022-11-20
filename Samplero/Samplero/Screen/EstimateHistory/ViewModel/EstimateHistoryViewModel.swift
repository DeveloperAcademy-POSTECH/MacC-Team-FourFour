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

    private let coordinator: EstimateHistoryCoordinator

    // MARK: - Init

    required init(coordinator: EstimateHistoryCoordinator) {
        self.coordinator = coordinator
    }
    
    // MARK: - Input
    struct Input {
        let viewWillAppear: ControlEvent<Bool>
        let itemSelected: ControlEvent<IndexPath>
    }

    // MARK: - Output
    struct Output {
        let isEmptyCell: Observable<Bool>
        let estimateHistorySubject: Observable<[EstimateHistory]>
    }

    // MARK: - Transform
    func transform(input: Input) -> Output {
        let estimateHistorySubject: BehaviorSubject<[EstimateHistory]> = BehaviorSubject(value: db.getEstimateHistories())

        let isEmptyCell = input.viewWillAppear
            .withLatestFrom(estimateHistorySubject)
            .map { $0.count > 0 ? true : false }

        input.itemSelected
            .subscribe { indexPath in
                self.coordinator.showEstimate(with: indexPath.row + 1)
            }
            .disposed(by: disposeBag)

        return Output(isEmptyCell: isEmptyCell, estimateHistorySubject: estimateHistorySubject)
    }
}
