//
//  EstimateHistoryViewController.swift
//  Samplero
//
//  Created by JiwKang on 2022/10/10.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit

class EstimateHistoryViewController: BaseViewController, ViewModelBindableType {
    
    // MARK: - Properties
    
    var viewModel: EstimateHistoryViewModel!
    
    private let helpingLabel: UILabel = {
        let label: UILabel = UILabel()
        label.text = "견적이 없습니다.\n사진을 찍어보세요!"
        label.numberOfLines = 2
        label.textColor = .secondaryGray
        label.textAlignment = .center
        return label
    }()
    
    private let estimateHistoryCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(cell: EstimateHistoryCollectionViewCell.self)
        return collectionView
    }()
    
    // MARK: - Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
        
        viewModel.estimateHistorySubject
            .map { $0.count > 0 ? true : false }
            .subscribe(onNext: { [weak self] in
                if $0 {
                    self?.estimateHistoryCollectionView.isHidden = false
                    self?.helpingLabel.isHidden = true
                } else {
                    self?.estimateHistoryCollectionView.isHidden = true
                    self?.helpingLabel.isHidden = false
                }
            })
            .disposed(by: viewModel.disposeBag)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        estimateHistoryCollectionView.rx.setDelegate(self)
            .disposed(by: viewModel.disposeBag)
    }
    
    override func render() {
        view.addSubview(estimateHistoryCollectionView)
        estimateHistoryCollectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        view.addSubview(helpingLabel)
        helpingLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override func configUI() {
        view.backgroundColor = .white
        navigationItem.title = "견적 내역"
    }
    
    // MARK: - Func
    
    func bind() {
        viewModel.estimateHistorySubject
            .bind(to: estimateHistoryCollectionView.rx.items) { collectionView, row, history -> UICollectionViewCell in
                let cell = collectionView.dequeueReusableCell(withType: EstimateHistoryCollectionViewCell.self, for: IndexPath.init(row: row, section: 0))
                cell.configure(history: history)
                return cell
            }
            .disposed(by: viewModel.disposeBag)
        
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
