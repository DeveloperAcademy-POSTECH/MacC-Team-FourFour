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
    static let orderButtonCorneRadius = 14.0
    static let orderButtonHeight = 64.0
    static let buttonTextStackViewSpacing = 2.0
    static let zPositionValue = 1.0
    static let cellSpacing = 32.0
    static let cellHeight = 80.0
    static let footerViewHeight = 111.0
}

final class ShopBasketViewController: BaseViewController, ViewModelBindableType {
    
    
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
        button.setTitleColor(.secondaryGray, for: .normal)
        button.setImage(UIImage(systemName: "square"), for: .normal)
        button.imageView?.tintColor = .boxBackground
        return button
    }()
    
    private let allDeleteButton: UIButton = {
        let button = UIButton()
        button.setTitle("전체 삭제", for: .normal)  // 띄어쓰기 논의해봐야 할듯
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        button.setTitleColor(.secondaryGray, for: .normal)
        return button
    }()
    
    private let upperDivider: UIView = {
        let divider = UIView()
        divider.backgroundColor = UIColor.separator
        return divider
    }()
    
    // orderButton consists of buttonTextStackView( buttonFirstLabel, buttonSecondLabel )
    private let orderButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .boxBackground
        button.layer.cornerRadius = Size.orderButtonCorneRadius
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
        view.isUserInteractionEnabled = false
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
        label.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .callout).pointSize, weight: .bold)
        label.textColor = .white
        return label
    }()
    
    private let shopBasketFlowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = Size.cellSpacing
        layout.sectionInset = .init(top: 24, left: 0, bottom: 24, right: 0)
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

    private var dataSource: RxCollectionViewSectionedReloadDataSource<SectionModel<String, CheckSample>>!


    // MARK: - Life Cycle
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        
        view.addSubview(upperDivider)
        upperDivider.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(allButtonsBackgroundView)
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
        
        view.addSubview(orderButton)
        orderButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(Size.defaultOffset)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(Size.orderButtonHeight)
        }
        
        view.addSubview(noSampleLabel)
        noSampleLabel.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
    }
    
    override func configUI() {
        view.backgroundColor = .systemBackground
        navigationItem.title = "장바구니"
    }
    
    func bind() {
        setDelegation()
        setDatasource()

        let input = ShopBasketViewModel.Input(
            viewWillDisappear: rx.viewWillDisappear,
            allChoiceButtonSelected: allChoiceButton.rx.tap,
            allDeleteButtonSelected: allDeleteButton.rx.tap,
            orderButtonSelected: orderButton.rx.tap)

        let output = viewModel.transform(input: input)


        // wishedSample binding
        output.wishedSample
            .asDriver(onErrorJustReturn: [])
            .map {
                return [SectionModel(model: "", items: $0)]}
            .drive(shopBasketCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: viewModel.disposeBag)

        output.IsWishedSampleEmpty
            .map { !$0 }
            .asDriver(onErrorJustReturn: false)
            .drive(shopBasketCollectionView.rx.visibleStatus)
            .disposed(by: viewModel.disposeBag)
        output.IsWishedSampleEmpty
            .asDriver(onErrorJustReturn: true)
            .drive(allButtonsBackgroundView.rx.isHidden)
            .disposed(by: viewModel.disposeBag)
        output.IsWishedSampleEmpty
            .asDriver(onErrorJustReturn: true)
            .drive(upperDivider.rx.isHidden)
            .disposed(by: viewModel.disposeBag)


        // selectionState binding
        output.selectedCountText
            .drive(buttonFirstLabel.rx.text)
            .disposed(by: viewModel.disposeBag)

        output.selectionStateIsEmpty
            .drive(orderButton.rx.buttonEnabledStatus)
            .disposed(by: viewModel.disposeBag)

        output.IsAllChoiceButtonSelected
            .subscribe { boolValue in
                self.allChoiceButton.setImage(UIImage(systemName: boolValue ? "checkmark.square.fill" : "square"), for: .normal)
                self.allChoiceButton.imageView?.tintColor = boolValue ? .accent : .boxBackground
            }
            .disposed(by: viewModel.disposeBag)

        output.selectionTotalPrice
            .subscribe { totalPrice in
                let footerView = self.shopBasketCollectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionFooter, at: IndexPath(item: .zero, section: .zero)) as? AmountFooterView
                footerView?.configure(with: totalPrice)
            }
            .disposed(by: viewModel.disposeBag)


        // tappedAllChoiceButton binding
        output.tappedAllChoiceButton
            .subscribe(onNext: { checkedFlag  in
                self.changeAllChoiceButtonUI(checked: checkedFlag)
                self.switchAllCheckBoxInCell(checked: checkedFlag)
            })
            .disposed(by: viewModel.disposeBag)


        // tappedOrderButton binding
        output.tappedOrderButton
            .subscribe { copyStr in
                let vc = TermsViewController()
                vc.setShopBasketString(str: copyStr)
                self.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: viewModel.disposeBag)


    }
    
    // MARK: - Func
    
    
    private func setDelegation() {
        shopBasketCollectionView.rx.setDelegate(self).disposed(by: viewModel.disposeBag)
    }

    private func setDatasource() {
        // Reactive collectionView ( more than one section )
         dataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<String, CheckSample>> {(_, collectionView, indexPath, checkSample) -> UICollectionViewCell in

            // cell configuration
            let cell = collectionView.dequeueReusableCell(withType: ShopBasketCollectionViewCell.self, for: indexPath)

            cell.configure(with: checkSample)
            cell.disposeBag = DisposeBag()

            // each cell's checkButton Binding
            cell.checkBox.rx.tap
                 .map {
                     cell.isChecked.toggle()
                     checkSample.isChecked.toggle() }
                .map { _ in checkSample }
                .bind(to: self.viewModel.selectedSubject)
                .disposed(by: cell.disposeBag!)

            // each cell's deleteButton Binding
            cell.deleteButton.rx.tap
                .map { _ in checkSample }
                .bind(to: self.viewModel.removedSubject)
                .disposed(by: cell.disposeBag!)
            return cell

        } configureSupplementaryView: { (_, collectionView, _, indexPath) -> UICollectionReusableView in
            // CollectionView Footer Configuration
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: AmountFooterView.className, for: indexPath)
            return footerView
        }

    }

    private func showNavigationBar() {
        navigationController?.navigationBar.isHidden = false
    }

    private func switchAllCheckBoxInCell(checked: Bool) {
        for item in 0..<shopBasketCollectionView.numberOfItems(inSection: .zero) {
            let cell = shopBasketCollectionView.cellForItem(at: IndexPath(item: item, section: .zero)) as? ShopBasketCollectionViewCell
            cell?.isChecked = checked
        }
    }

    private func changeAllChoiceButtonUI(checked: Bool) {
        self.allChoiceButton.setImage(UIImage(systemName: checked ? "checkmark.square.fill" : "square"), for: .normal)
        self.allChoiceButton.imageView?.tintColor = checked ? .accent : .boxBackground
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
    var buttonEnabledStatus: Binder<Bool> {
        return Binder(self.base) { button, boolValue in
            switch boolValue {
            case true :
                button.isEnabled = false
                button.backgroundColor = .boxBackground
            case false :
                button.isEnabled = true
                button.backgroundColor = .accent
            }
        }
    }
}
