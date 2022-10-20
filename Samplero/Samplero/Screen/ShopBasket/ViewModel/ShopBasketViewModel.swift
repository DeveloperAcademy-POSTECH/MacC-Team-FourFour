//
//  ShopBasketViewModel.swift
//  Samplero
//
//  Created by DaeSeong on 2022/10/12.
//

import UIKit

import RxCocoa
import RxSwift


private enum SelectionEvent {
    case sample(CheckSample)
    case all([CheckSample])
}

class ShopBasketViewModel {


    // MARK: - Properties

    let db = DBHelper.shared
    
    var shopBasketCopy: BehaviorSubject<String> = BehaviorSubject(value: "")

    var disposeBag: DisposeBag = DisposeBag()

    // 장바구니 목록 샘플
    let wishedSampleRelay = BehaviorRelay<[CheckSample]>(value: [])
    // 제거할 샘플
    let removedSample = PublishSubject<CheckSample>()
    // 현재 선택된 샘플들 목록
    var selectionState = PublishSubject<Set<CheckSample>>()
    // 선택된 샘플
    var selectedSample = PublishSubject<CheckSample>()
    // FIXME: - 필요성 검토
    var selectedAllSample = PublishSubject<[CheckSample]>()

    // MARK: - Init


    init() {
        // withLatestFrom - selectedAllSubject가 이벤트 방출할 때 wishedSampleRelay의 가장 최근에 방출한 이벤트와 결합해서 방출가능. but 클로저사용안하면 wishedSampleRelay의 가장 최근 이벤트만 방출.

        // scan의 초기값(Last보관소)은 첫번째 인자이고 두번째 인자인 핸들러를 통해 이전에 방출한 값과 위에서 방출한 이벤트값을 이용해 새로운 이벤트를 방출하고 Last보관소에 다시 저장한다.

        wishedSampleRelay.accept(self.db.getShopBasketItem().map { shopBasket in
            return shopBasket.toCheckSample()
        })

        // binding to selectionState
        Observable.of(
            selectedSample.map { SelectionEvent.sample($0) },
            selectedAllSample.withLatestFrom(wishedSampleRelay.map { SelectionEvent.all($0) })
                 ).merge()
            .scan(Set()) { (lastSampleSet: Set<CheckSample>, event: SelectionEvent) in
                var lastSampleSet = lastSampleSet
                switch event {
                case .sample(let checkSample):
                    if lastSampleSet.contains(checkSample) {
                        lastSampleSet.remove(checkSample)
                    } else {
                        lastSampleSet.insert(checkSample)
                    }
                case .all(let all):
                    if lastSampleSet == Set(all) {
                        lastSampleSet = Set()
                    } else {
                        lastSampleSet = Set(all)
                    }
                }
                return lastSampleSet
            }
            .startWith(Set())
            .bind(to: selectionState)
            .disposed(by: disposeBag)

        // removedSample binding to selectedSample
        removedSample.map { removedCheckSample in
            return self.wishedSampleRelay.value.filter { checkSample -> Bool in
                checkSample.sample.id == removedCheckSample.sample.id && checkSample.isChecked == true
            }
        }
        .filter { !$0.isEmpty }
        .map { $0[0] }
        .bind(to: selectedSample)
        .disposed(by: disposeBag)

        // removedSample binding to wishedSampleRelay
        removedSample.map { removedCheckSample in
            let resultWishedSample =  self.wishedSampleRelay.value.filter { checkSample -> Bool in
                checkSample.sample.id != removedCheckSample.sample.id
            }
            self.selectedAllSample.onNext(resultWishedSample)
            return resultWishedSample
        }
        .bind(to: wishedSampleRelay)
        .disposed(by: disposeBag)
        
        
        removedSample.map { $0.sample.id }
        .subscribe(onNext: { id in
            self.db.deleteItemFromShopBasket(itemId: id)
        })
        .disposed(by: disposeBag)
        
        
    }
}


