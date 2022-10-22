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
    
    var shopBasketCopy = BehaviorSubject(value: "")

    var disposeBag: DisposeBag = DisposeBag()
    //    let wishedSampleRelay = BehaviorRelay<[CheckSample]>(value: MockData.sampleList.map {CheckSample(sample: $0)})
    let removedSubject = PublishSubject<CheckSample>()
    // current selected checkSample collection
    // selected checkSample
    var selectedSubject = PublishSubject<CheckSample>()
    // FIXME: - 필요성 검토
    var selectedAllSubject = PublishSubject<Void>()
    let wishedSampleRelay = BehaviorRelay<[CheckSample]>(value: [])
    var selectionState = BehaviorRelay<Set<CheckSample>>(value: Set())
    // for allChoiceButton
    var checkedCount = 0
    // MARK: - Init


    init() {
        wishedSampleRelay.accept(self.db.getShopBasketItem().map { shopBasket in
            return shopBasket.toCheckSample()
        })

        // binding to selectionState
        Observable.of(
            selectedSubject.map { SelectionEvent.sample($0) },
            selectedAllSubject.withLatestFrom(wishedSampleRelay.map { SelectionEvent.all($0) })
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

        // removedSubejct binding to selectedSubject
        removedSubject.map { removedCheckSample in
            return self.wishedSampleRelay.value.filter { checkSample -> Bool in
                checkSample.sample.id == removedCheckSample.sample.id && checkSample.isChecked == true
            }
        }
        .filter { !$0.isEmpty }
        .map { $0[0] }
        .bind(to: selectedSubject)
        .disposed(by: disposeBag)

        // removedSubejct binding to wishedSampleRelay
        removedSubject.map { removedCheckSample in
            return self.wishedSampleRelay.value.filter { checkSample -> Bool in
                checkSample.sample.id != removedCheckSample.sample.id
            }
        }
        .bind(to: wishedSampleRelay)
        .disposed(by: disposeBag)
        
        removedSubject.map { $0.sample.id }
            .subscribe(onNext: { id in
                self.db.deleteItemFromShopBasket(itemId: id)
            })
            .disposed(by: disposeBag)
        
        
    }


    struct Input {
       // let viewWillDisappear: Observable<Bool>
        let allChoiceButtonSelected: ControlEvent<Void>
        let allDeleteButtonSelected: ControlEvent<Void>
        let orderButtonSelected: ControlEvent<Void>
    }
    struct Output {
        let wishedSample: Observable<[CheckSample]>
        let selectionState: Observable<Set<CheckSample>>
        let tappedAllChoiceButton: Observable<Bool>
        let tappedOrderButton: Observable<String>
    }

    func transform(input: Input) -> Output {



        // TODO: - 이전 PR 머지후 수정예정
//        input.viewWillDisappear
//            .subscribe { _ in
//                let items = wishedSampleRelay.value
//
//                items.forEach { item in
//                    self.db.updateShopBasketItemSelectedState(itemId: item.sample.id, shopBasketItem: item.isChecked)
//                }
//            }
//            .disposed(by: disposeBag)


        let tappedAllChoiceButton =  input.allChoiceButtonSelected.map { _ in
            !(self.checkedCount == self.wishedSampleRelay.value.count)
        }
            .map { checkedFlag in
                self.selectedAllSubject.onNext(())
                _ = self.wishedSampleRelay.value.map { $0.isChecked = checkedFlag }
                return checkedFlag
            }


        let tappedAllDeleteButton =  input.allDeleteButtonSelected.asDriver()
        tappedAllDeleteButton
            .map({ [] })
            .drive(self.wishedSampleRelay)
            .disposed(by: disposeBag)
        tappedAllDeleteButton
            .map({ [] })
            .drive(self.selectionState)
            .disposed(by: disposeBag)
        tappedAllDeleteButton
            .asObservable()
            .subscribe { _ in
                self.db.deleteAllItemFromShopBasket()
            }
            .disposed(by: disposeBag)


        let tappedOrderButton = input.orderButtonSelected.withLatestFrom(self.shopBasketCopy.asObservable())

        

        return Output(wishedSample: wishedSampleRelay.asObservable(),
                      selectionState: selectionState.asObservable(),
                      tappedAllChoiceButton: tappedAllChoiceButton,
                      tappedOrderButton: tappedOrderButton)
    }

}


