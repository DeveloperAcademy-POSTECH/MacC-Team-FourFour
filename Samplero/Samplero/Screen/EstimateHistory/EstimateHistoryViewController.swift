//
//  EstimateHistoryViewController.swift
//  Samplero
//
//  Created by JiwKang on 2022/10/10.
//

import UIKit

import SnapKit
import RxCocoa
import RxSwift

class EstimateHistoryViewController: BaseViewController {
    
    // MARK: - Properties
    
    let viewModel = EstimateHistoryViewModel()
    
    private let estimateHistoryCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.registor(cell: EstimateHistoryCollectionViewCell.self)
        return collectionView
    }()
    
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        addTargets()
    }
    
    override func render() {
        view.addSubview(estimateHistoryCollectionView)
        estimateHistoryCollectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        estimateHistoryCollectionView.rx.setDelegate(self)
            .disposed(by: viewModel.disposeBag)
    }
    
    override func configUI() {
        navigationItem.title = "견적 내역"
    }
    
    func bind() {
        viewModel.estimateHistoryObservable
            .bind(to: estimateHistoryCollectionView.rx.items) { collectionView, row, history -> UICollectionViewCell in
                let cell = collectionView.dequeReusableCell(withType: EstimateHistoryCollectionViewCell.self, for: IndexPath.init(row: row, section: 0))
                cell.configure(history: history)
                return cell
            }
            .disposed(by: viewModel.disposeBag)
    }
    
    // MARK: - Func
    
    func addTargets() {
        estimateHistoryCollectionView.rx.itemSelected
            .subscribe(onNext: { index in
                // TODO: select estimate history photo
                print("clicked \(index.row) cell")
            })
            .disposed(by: viewModel.disposeBag)
    }
}

extension EstimateHistoryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sizeValue: CGFloat = collectionView.bounds.width / 3
        let cellSize: CGSize = CGSize(width: sizeValue, height: sizeValue * 1.35)
        return cellSize
    }
}
