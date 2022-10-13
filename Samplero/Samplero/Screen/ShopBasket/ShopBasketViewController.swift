//
//  ShopBasketViewController.swift
//  Samplero
//
//  Created by DaeSeong on 2022/10/10.
//

import UIKit

import RxCocoa
import RxDataSources
import RxSwift
import SnapKit


private enum Size {
    static let noticeBackgroundHeight = 42.0
    static let defaultOffset = 20.0
    static let allButtonsBackgroundHeight = 51.0
    static let orderButtonCorneradius = 14.0
    static let orderButtonHeight = 64.0
    static let buttonTextStackViewSpacing = 2.0
    static let zPositionValue = 1.0
    static let cellSpacing = 32.0
    static let cellHeight = 80.0
    static let footerViewHeight = 111.0
}

class ShopBasketViewController: BaseViewController, ViewModelBindableType {
    
    
    // MARK: - Properties
    // View consists of noticeBackgroundView, allButtonsBackgroundView, shopBasketCollectionView
    private let noticeBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .boxBackground
        return view
    }()
    
    private let noticeLabel: UILabel = {
        let label = UILabel()
        label.text = "ⓘ 샘플은 하나씩만 구매할 수 있어요."
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 12, weight: .light)
        return label
    }()
    
    private let allButtonsBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private let allChoiceButton: UIButton = {
        let button = UIButton()
        button.setTitle("  전체 선택", for: .normal)  // 띄어쓰기 논의해봐야 할듯
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        button.setTitleColor(.systemGray2, for: .normal)
        button.setImage(UIImage(systemName: "square"), for: .normal)
        button.imageView?.tintColor = .systemGray4
        return button
    }()
    
    private let allDeleteButton: UIButton = {
        let button = UIButton()
        button.setTitle("전체 삭제", for: .normal)  // 띄어쓰기 논의해봐야 할듯
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        button.setTitleColor(.systemGray2, for: .normal)
        return button
    }()
    
    // orderButton consists of buttonTextStackView( buttonFirstLabel, buttonSecondLabel )
    private let orderButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .boxBackground
        button.layer.cornerRadius = Size.orderButtonCorneradius
        button.layer.zPosition = Size.zPositionValue
        button.isEnabled = false
        return button
    }()
    
    private let buttonTextStackView: UIStackView = {
        let view = UIStackView()
        view.alignment = .center
        view.axis = .vertical
        view.distribution = .fillEqually
        view.spacing = Size.buttonTextStackViewSpacing
        return view
    }()
    
    private let buttonFirstLabel: UILabel = {
        let label = UILabel()
        label.text = "0개의 샘플"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .white
        return label
    }()
    
    private let buttonSecondLabel: UILabel = {
        let label = UILabel()
        label.text = "주문하기"
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textColor = .white
        return label
    }()
    
    private let shopBasketFlowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = Size.cellSpacing
        return layout
    }()
    
    private lazy var shopBasketCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.shopBasketFlowLayout)
        collectionView.register(cell: ShopBasketCollectionViewCell.self)
        collectionView.backgroundColor = .systemBackground
        collectionView.register(AmountFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: AmountFooterView.className)
        return collectionView
    }()
    
    private let noSampleLabel: UILabel = {
        let label = UILabel()
        label.text = "담긴 샘플이 없습니다."
        label.textColor = .secondaryGray
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.layer.zPosition = -1
        return label
    }()
    
    var viewModel: ShopBasketViewModel!

    var checkedCount = 0
    // MARK: - Life Cycle
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDelegation()
    }
    override func viewWillAppear(_ animated: Bool) {
        hideNavBar()
    }
    override func viewDidLayoutSubviews() {
        shopBasketFlowLayout.footerReferenceSize = CGSizeMake(shopBasketCollectionView.bounds.width, Size.footerViewHeight)
    }
    
    override func render() {
        view.addSubview(noticeBackgroundView)
        noticeBackgroundView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(Size.noticeBackgroundHeight)
        }
        
        noticeBackgroundView.addSubview(noticeLabel)
        noticeLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(Size.defaultOffset)
        }
        
        view.addSubview(allButtonsBackgroundView)
        allButtonsBackgroundView.snp.makeConstraints { make in
            make.top.equalTo(noticeBackgroundView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(Size.allButtonsBackgroundHeight)
        }
        allButtonsBackgroundView.addSubview(allChoiceButton)
        allChoiceButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(Size.defaultOffset) // 18인지 20인지 헷갈
        }
        allButtonsBackgroundView.addSubview(allDeleteButton)
        allDeleteButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(Size.defaultOffset)
        }
        
        view.addSubview(orderButton)
        orderButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(Size.defaultOffset)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(Size.orderButtonHeight)
        }
        
        orderButton.addSubview(buttonTextStackView)
        buttonTextStackView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
        buttonTextStackView.addArrangedSubview(buttonFirstLabel)
        buttonTextStackView.addArrangedSubview(buttonSecondLabel)
        
        view.addSubview(shopBasketCollectionView)
        shopBasketCollectionView.snp.makeConstraints { make in
            make.top.equalTo(allButtonsBackgroundView.snp.bottom)
            make.leading.bottom.trailing.equalToSuperview()
        }
        
        view.addSubview(noSampleLabel)
        noSampleLabel.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
    }
    
    override func configUI() {
        view.backgroundColor = .systemBackground
        navigationItem.title = "장바구니"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func bind() {
        // Reactive collectionView ( more than one section )
        let dataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<String, Sample>> {(_, collectionView, indexPath, sample) -> UICollectionViewCell in
            
            // cell configuration
            let cell = collectionView.dequeueReusableCell(withType: ShopBasketCollectionViewCell.self, for: indexPath)
            
            cell.configure(with: sample)
            cell.disposeBag = DisposeBag()

            // each cell's checkButton Binding
            cell.getCheckButton().rx.tap
                .map {cell.isChecked.toggle()}
                .map { _ in sample }
                .bind(to: self.viewModel.selectedSubject)
                .disposed(by: cell.disposeBag!)

            // each cell's deleteButton Binding
            cell.getDeleteButton().rx.tap
                .map { _ in sample }
                .bind(to: self.viewModel.remove)
                .disposed(by: cell.disposeBag!)
            // TODO:- viewModel.disposed로 하면 연속으로 지워지는 문제 발생 이유 찾기


            return cell
            
        } configureSupplementaryView: { (_, collectionView, _, indexPath) -> UICollectionReusableView in
            
            // CollectionView Footer Configuration
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: AmountFooterView.className, for: indexPath)
            return footerView
        }

        
        // shopBasketCollectionView binding
        viewModel.wishedSampleObservable
            .asObservable()
            .map {
                return [SectionModel(model: "", items: $0)]}
            .bind(to: shopBasketCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: viewModel.disposeBag)
        
        // shopBasketCollectionView visibleStatus binding
        viewModel.wishedSampleObservable
            .map { !$0.isEmpty}
            .asDriver(onErrorJustReturn: false)
            .drive(shopBasketCollectionView.rx.visibleStatus)
            .disposed(by: viewModel.disposeBag)

        // allButtonsBackgroundView visibleStatus binding
        viewModel.wishedSampleObservable
            .map { $0.isEmpty }
            .asDriver(onErrorJustReturn: true)
            .drive(allButtonsBackgroundView.rx.isHidden)
            .disposed(by: viewModel.disposeBag)

        // allDeleteButton binding
        allDeleteButton.rx.tap
            .map { [] }
            .bind(to: viewModel.wishedSampleObservable)
            .disposed(by: viewModel.disposeBag)
        
        // buttonFirstLabel binding
        viewModel.selectionState
            .map { "\($0.count)개의 샘플"}
            .asDriver(onErrorJustReturn: "0개의 샘플")
            .drive(buttonFirstLabel.rx.text)
            .disposed(by: viewModel.disposeBag)

        // orderButton enableStatus binding
        viewModel.selectionState
            .map { !$0.isEmpty }
            .asDriver(onErrorJustReturn: false)
            .drive(orderButton.rx.enableStatus)
            .disposed(by: viewModel.disposeBag)


        viewModel.selectionState
            .map { $0.count }
            .subscribe(onNext: { currentCount in
                self.checkedCount = currentCount
                if currentCount == self.viewModel.wishedSampleObservable.value.count {
                    self.allChoiceButton.setImage(UIImage(systemName: "square.fill"), for: .normal)
                    self.allChoiceButton.imageView?.tintColor = .accent

                } else {
                        self.allChoiceButton.setImage(UIImage(systemName: "square"), for: .normal)
                        self.allChoiceButton.imageView?.tintColor = .boxBackground
                    }
            })
            .disposed(by: viewModel.disposeBag)

        //

        allChoiceButton.rx.tap
            .map {
                let wishedSampleCount = self.viewModel.wishedSampleObservable.value.count
                 if self.checkedCount == wishedSampleCount {
                    return false
                } else { return true }
            }
            .map {
                ($0, self.viewModel.wishedSampleObservable.value) }
            .subscribe(onNext: { flag, wishedAllSample in
                self.viewModel.selectedAllSubject.onNext(wishedAllSample)
                switch flag {
                case true:
                    self.allChoiceButton.setImage(UIImage(systemName: "square.fill"), for: .normal)
                    self.allChoiceButton.imageView?.tintColor = .accent

                    for item in 0..<self.shopBasketCollectionView.numberOfItems(inSection: .zero) {
                        let cell = self.shopBasketCollectionView.cellForItem(at: IndexPath(item: item, section: .zero)) as? ShopBasketCollectionViewCell
                        cell?.isChecked = true

                    }
                case false:
                    self.allChoiceButton.setImage(UIImage(systemName: "square"), for: .normal)
                    self.allChoiceButton.imageView?.tintColor = .boxBackground

                    for item in 0..<self.shopBasketCollectionView.numberOfItems(inSection: .zero) {
                        let cell = self.shopBasketCollectionView.cellForItem(at: IndexPath(item: item, section: .zero)) as? ShopBasketCollectionViewCell
                        cell?.isChecked = false

                    }

                }
            })
            .disposed(by: viewModel.disposeBag)





    }
    
    // MARK: - Func
    
    
    private func setDelegation() {
        shopBasketCollectionView.rx.setDelegate(self).disposed(by: viewModel.disposeBag)
    }
    
    private func hideNavBar() {
        navigationController?.navigationBar.isHidden = false
    }
    
}


// MARK: - UICollectionViewDelegateFlowLayout


extension ShopBasketViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        .init(width: collectionView.bounds.width, height: Size.cellHeight)
    }
}

// MARK: - UICollectionView visibleStatus + Rx


extension Reactive where Base: UICollectionView {
    var visibleStatus: Binder<Bool> {
        return Binder(self.base) { collectionView, boolValue in
            switch boolValue {
            case true :
                collectionView.isHidden = false
            case false :
                collectionView.isHidden = true
            }
        }
    }
}


// MARK: - UIButton visibleStatus + Rx


extension Reactive where Base: UIButton {
    var enableStatus: Binder<Bool> {
        return Binder(self.base) { button, boolValue in
            switch boolValue {
            case true :
                button.isEnabled = true
                button.backgroundColor = .accent
            case false :
                button.isHidden = false
                button.backgroundColor = .systemGray4
            }
        }
    }
}
