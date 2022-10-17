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
    static let sampleAddButtonHeight = 50.0
    static let sampleAddButtonTopOffset = 17.0
    static let sampleAddButtonCornerRadius = 14.0
    static let sampleAddButtonBottomOffset = 14.0
    static let cellItemSize = 40.0
    static let sampleCollectionBottomOffset = 14.0

}

final class EstimateViewController: BaseViewController, ViewModelBindableType {

    // MARK: - Properties
    // View consists of roomImageView, sampleDetailView, bottomView

    private let matInsertedImageName: String = "mat-inserted-photo-"
    private let savingFolderName: String = "estimate-photo"

    private var sourceImage: UIImage!
    private var maskedImage: UIImage!

    var roomImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.image = ImageLiteral.sampleRoom
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    private let sampleDetailView = SampleDetailView()

    // subView of bottomView
    private let sampleAddButton: UIButton = {
        let button = UIButton()
        button.setTitle("샘플담기", for: .normal)
        button.backgroundColor = .accent
        button.titleLabel?.font = .boldBody
        button.setTitleColor(.white, for: .normal)
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
    
    
    // Open Cart Button
    private let cartButton: UIButton = {
        let button: UIButton = UIButton()
        button.setImage(ImageLiteral.cartDark, for: .normal)
        return button
    }()
    
    private let cartButtonBackground: UIView = {
        let view: UIView = UIView()
        view.layer.cornerRadius = UIScreen.main.bounds.width / 16.25
        view.backgroundColor = .clear
        return view
    }()
    
    private let cartCountLabel: UILabel = {
        let label: UILabel = UILabel()
        label.textColor = .white
        label.backgroundColor = .accent
        label.font = .boldCaption1
        label.text = " 99+ "
        label.layer.masksToBounds = true
        return label
    }()

    // variable for selecting first item in default
    private var lastSelectedIndexPath: IndexPath?

    var viewModel: EstimateViewModel!

    let toBeEstimatedPriceView = ToBeEstimatedPriceView()
    let estimatedPriceView = EstimatedPriceView(estimatedPrice: -1, width: 1100, height: 1200, estimatedQuantity: 80, pricePerBlock: -1)


    private var lastSelectedImage = UIImage()

    private let getAreaVC = GetAreaViewController()


    private var addedButtonLabelStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        stackView.isHidden = true
        stackView.spacing = 12
        return stackView
    }()
    private let addedButtonLabel: UILabel = {
        let label = UILabel()
        label.text = "샘플 장바구니에 담김"
        label.textColor = .accent
        label.font = .regularCaption1
        return label
    }()

    private let goShopBasketLabel: UILabel = {
        let label = UILabel()
        label.text = "보러가기＞"
        label.textColor = .accent
        label.font = .boldSubheadline
        return label
    }()



    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.fileManager.saveImage(image: self.lastSelectedImage, imageName: self.matInsertedImageName + String(describing: viewModel.imageIndex), folderName: self.savingFolderName)
    }

    override func viewDidLayoutSubviews() {
        toBeEstimatedPriceView.textButton.layer.cornerRadius = toBeEstimatedPriceView.textButton.bounds.height / 2
        estimatedPriceView.textButton.layer.cornerRadius = estimatedPriceView.textButton.bounds.height / 2
        cartCountLabel.layer.cornerRadius = cartCountLabel.layer.bounds.height / 2
    }

    override func render() {
        view.addSubview(roomImageView)
        roomImageView.snp.makeConstraints { make in
            make.height.equalTo(Size.deviceHeight * 0.69)
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
        }
        roomImageView.addSubview(toBeEstimatedPriceView)
        toBeEstimatedPriceView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(80)
        }

        roomImageView.addSubview(estimatedPriceView)
        estimatedPriceView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(80)
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
            make.height.equalTo(Size.deviceHeight * 0.18)
        }

        view.addSubview(sampleAddButton)
        sampleAddButton.snp.makeConstraints { make in
            make.top.equalTo(sampleDetailView.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(Size.defaultOffset)
            make.height.equalTo(Size.sampleAddButtonHeight)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(Size.sampleAddButtonBottomOffset)
        }
        
        cartButtonBackground.snp.makeConstraints { make in
            make.size.equalTo(UIScreen.main.bounds.width / 8.125)
        }

        view.addSubview(addedButtonLabelStackView)
        addedButtonLabelStackView.snp.makeConstraints { make in
            make.centerX.centerY.equalTo(sampleAddButton)
        }
        addedButtonLabelStackView.addArrangedSubview(addedButtonLabel)
        addedButtonLabelStackView.addArrangedSubview(goShopBasketLabel)
        cartButtonBackground.addSubview(cartButton)
        cartButton.snp.makeConstraints { make in
            make.center.equalTo(cartButtonBackground)
        }
        cartButtonBackground.addSubview(cartCountLabel)
        cartCountLabel.snp.makeConstraints { make in
            make.top.equalTo(cartButtonBackground)
            make.trailing.equalTo(cartButtonBackground)
        }
    }

    override func configUI() {
        super.configUI()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: cartButtonBackground)
        self.navigationItem.rightBarButtonItem?.tintColor = .black

        toBeEstimatedPriceView.backgroundColor = .black.withAlphaComponent(0.5)
        toBeEstimatedPriceView.alpha = 1
        estimatedPriceView.backgroundColor = .black.withAlphaComponent(0.5)
        estimatedPriceView.alpha = 0
    }

    func bind() {

        let input = EstimateViewModel.Input(
            viewWillAppear: rx.viewWillAppear,
            viewWillDisappear: rx.viewWillDisappear,
            collectionModelSelected: sampleCollectionView.rx.modelSelected(Sample.self),
            addButtonSelected: sampleAddButton.rx.tap,
            inputAreaSelected:  toBeEstimatedPriceView.textButton.rx.tap, inputAreaAgainSelected: estimatedPriceView.textButton.rx.tap,
            cartButtonSelected: cartButton.rx.tap,
            getAreaSaveButtonSelected: getAreaVC.saveButton.rx.tap.map { _ in (self.getAreaVC.areaWidth, self.getAreaVC.areaHeight) },
            goShopBasketLabelSelected: goShopBasketLabel.rx.tapGesture)

        // Output
        let output = viewModel.transform(input: input)

        output.viewWillAppear
            .subscribe { [weak self] count in
                self?.navigationController?.isNavigationBarHidden = false
                self?.cartCountLabel.text = count
            }
            .disposed(by: viewModel.disposeBag)

        output.resultImage
            .bind(to: roomImageView.rx.image)
            .disposed(by: viewModel.disposeBag)
        
        output.SampleList
            .bind(to: sampleCollectionView.rx.items) { [weak self] collectionView, itemIndex, sample -> UICollectionViewCell in
                let indexPath = IndexPath(item: itemIndex, section: .zero)
                let cell = collectionView.dequeueReusableCell(withType: SampleCollectionViewCell.self, for: indexPath)
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
            .subscribe { currentSample in
                self.toBeEstimatedPriceView.alpha = 1
                self.estimatedPriceView.alpha = 0
                self.configure(with: currentSample)
            }
            .disposed(by: viewModel.disposeBag)

        output.tappedSample
            .withLatestFrom(viewModel.samplesRelay) { return (samples: $1, currentSample: $0)}
            .map { tuple in
                if tuple.samples.firstIndex(of: tuple.currentSample) != nil {
                    return true
                } else { return false }
            }
            .subscribe { isDuplicated in
                print(isDuplicated)
                if isDuplicated {
                    self.sampleAddButton.backgroundColor = .addedButtonGray
                    self.sampleAddButton.isEnabled = false
                    self.sampleAddButton.setTitle("", for: .normal)
                    self.addedButtonLabelStackView.isHidden = false
                } else {
                    self.sampleAddButton.backgroundColor = .accent
                    self.sampleAddButton.isEnabled = true
                    self.sampleAddButton.setTitle("샘플 담기", for: .normal)
                    self.addedButtonLabelStackView.isHidden = true
                }
            }
            .disposed(by: viewModel.disposeBag)

        output.tappedInputArea
            .subscribe(onNext: {
                self.getAreaVC.preferredSheetSizing = .medium
                self.getAreaVC.getWidthView.textField.becomeFirstResponder()
                self.present(self.getAreaVC, animated: true)
            })
            .disposed(by: viewModel.disposeBag)

        output.tappedInputAreaAgain
            .subscribe(onNext: {
                self.getAreaVC.preferredSheetSizing = .medium
                self.getAreaVC.getWidthView.textField.becomeFirstResponder()
                self.present(self.getAreaVC, animated: true)
            })
            .disposed(by: viewModel.disposeBag)

        output.tappedGetAreaSaveButton
            .subscribe(onNext: { quantityAndPrice in
                self.estimatedPriceView.changeEstimation(estimatedPrice: Int(quantityAndPrice[1]), width: Int(self.getAreaVC.areaWidth), height: Int(self.getAreaVC.areaHeight), estimatedQuantity: Int(quantityAndPrice[0]), pricePerBlock: Int(quantityAndPrice[2]))
                self.toBeEstimatedPriceView.alpha = 0
                self.estimatedPriceView.alpha = 1
            })
            .disposed(by: viewModel.disposeBag)

        output.tappedAddButton
            .subscribe(onNext: {
                self.sampleAddButton.backgroundColor = .addedButtonGray
                self.sampleAddButton.isEnabled = false
                self.sampleAddButton.setTitle("", for: .normal)
                self.addedButtonLabelStackView.isHidden = false
            })
            .disposed(by: viewModel.disposeBag)

        output.tappedGoShopBasketLabel
            .subscribe(onNext: {
                var shopBasketVC = ShopBasketViewController()
                shopBasketVC.bindViewModel(ShopBasketViewModel())
                self.navigationController?.pushViewController(shopBasketVC, animated: true)
            })
            .disposed(by: viewModel.disposeBag)

        output.tappedCartButton
            .subscribe(onNext: {
                var vc = ShopBasketViewController()
                vc.bindViewModel(ShopBasketViewModel())
                self.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: viewModel.disposeBag)
        
    }


    // MARK: - Func


    func configure(with sample: Sample) {
        sampleDetailView.configure(with: sample)
        sourceImage = viewModel.getImage()
        maskedImage = viewModel.getMaskedImage()
    //  roomImageView.image = maskInputImage(with: sample)
    }

}

