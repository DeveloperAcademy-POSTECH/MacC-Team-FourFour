//
//  EstimateViewController.swift
//  Samplero
//
//  Created by DaeSeong on 2022/10/08.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit

private enum Size {
    static let deviceHeight = UIScreen.main.bounds.size.height - ((UIApplication.shared.windows.first?.safeAreaInsets.top) ??  0.0) - 44.0
    static let defaultOffset = 20.0
    static let samplePriceTopOffset = 28.0
    static let samplePriceValueLeadingOffset = 23.0
    static let sampleAddButtonWidth = 100.0
    static let sampleAddButtonHeight = 39.0
    static let sampleAddButtonTopOffset = 17.0
    static let sampleAddButtonCornerRadius = 14.0
    static let cellItemSize = 40.0
    static let sampleCollectionBottomOffset = 14.0
}

final class EstimateViewController: BaseViewController, ViewModelBindableType {


    // MARK: - Properties
    // View consists of roomImageView, sampleDetailView, bottomView
    
    private let roomImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.image = ImageLiteral.sampleRoom
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    private let sampleDetailView = SampleDetailView()

    private let bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        return view
    }()

    // subView of bottomView
    private let samplePriceLabel: UILabel = {
        let label = UILabel()
        label.textAlignment =  .natural
        label.font = .systemFont(ofSize: 14)
        label.text = "샘플가격"
        label.textColor = .systemGray2
        return label
    }()

    // subView of bottomView
    private let samplePriceValueLabel: UILabel = {
        let label = UILabel()
        label.textAlignment =  .natural
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = .black
        return label
    }()

    // subView of bottomView
    private let sampleAddButton: UIButton = {
        let button = UIButton()
        button.setTitle("샘플담기", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = Size.sampleAddButtonCornerRadius
        return button
    }()

    private let flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = Size.defaultOffset
        layout.itemSize = CGSize(width: Size.cellItemSize, height: Size.cellItemSize)
        return layout
    }()

    private lazy var sampleCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: self.flowLayout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.register(cell: SampleCollectionViewCell.self)
        collectionView.contentInset = UIEdgeInsets(top: .zero,
                                                   left: Size.defaultOffset,
                                                   bottom: .zero,
                                                   right: Size.defaultOffset)
        collectionView.allowsMultipleSelection = false
        return collectionView
    }()

    // variable for selecting first item in default
    private var lastSelectedIndexPath: IndexPath?

    var viewModel: EstimateViewModel!

    // MARK: - Life Cycle


    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func render() {
        view.addSubview(roomImageView)
        roomImageView.snp.makeConstraints { make in
            make.height.equalTo(Size.deviceHeight * 0.69)
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
        }

        roomImageView.addSubview(sampleCollectionView)
        sampleCollectionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(Size.sampleCollectionBottomOffset)
            make.height.equalTo(Size.cellItemSize)
        }

        view.addSubview(sampleDetailView)
        sampleDetailView.snp.makeConstraints { make in
            make.top.equalTo(roomImageView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(Size.deviceHeight * 0.2)
        }

        view.addSubview(bottomView)
        bottomView.snp.makeConstraints { make in
            make.top.equalTo(sampleDetailView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }

        bottomView.addSubview(samplePriceLabel)
        samplePriceLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Size.samplePriceTopOffset)
            make.leading.equalToSuperview().offset(Size.defaultOffset)
        }
        
        bottomView.addSubview(samplePriceValueLabel)
        samplePriceValueLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Size.samplePriceTopOffset)
            make.leading.equalTo(samplePriceLabel.snp.trailing).offset(Size.samplePriceValueLeadingOffset)
        }

        bottomView.addSubview(sampleAddButton)
        sampleAddButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Size.sampleAddButtonTopOffset)
            make.trailing.equalToSuperview().inset(Size.defaultOffset)
            make.width.equalTo(Size.sampleAddButtonWidth)
            make.height.equalTo(Size.sampleAddButtonHeight)

        }

    }

    override func configUI() {
        super.configUI()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: ImageLiteral.cartDark, style: .plain, target: self, action: nil)
        self.navigationItem.rightBarButtonItem?.tintColor = .black

    }

    func bind() {
        // Input
        let input = EstimateViewModel.Input(collectionModelSelected: sampleCollectionView.rx.modelSelected(Sample.self))

        // Output
        let output = viewModel.transform(input: input)

        output.SampleList
            .bind(to: sampleCollectionView.rx.items) { [weak self] collectionView, itemIndex, sample -> UICollectionViewCell in
                let indexPath = IndexPath(item: itemIndex, section: .zero)
                let cell = collectionView.dequeueReusableCell(withType: SampleCollectionViewCell.self,
                                                              for: indexPath)
                cell.configure(with: sample.imageName)

                if itemIndex == .zero {
                    self?.lastSelectedIndexPath = indexPath
                    collectionView.selectItem(at: indexPath,
                                              animated: true,
                                              scrollPosition: .left)
                    self?.configure(with: sample)
                }

                cell.isSelected = (self?.lastSelectedIndexPath == indexPath)

                return cell
            }
            .disposed(by: viewModel.disposeBag)

        output.tappedSample
            .bind(to: rx.configSample)
            .disposed(by: viewModel.disposeBag)
    }


    // MARK: - Func


    func configure(with sample: Sample) {
        sampleDetailView.configure(with: sample)
        samplePriceValueLabel.text = "\(sample.samplePrice.description)원"
    }
}


// MARK: - configSample: Binder


extension Reactive where Base: EstimateViewController {
    var configSample: Binder<Sample> {
        return Binder(self.base) { _, sample in
            self.base.configure(with: sample)
        }
    }
}
