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
        button.titleLabel?.font = .boldBody
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .accent
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

     let toBeEstimatedPriceView = ToBeEstimatedPriceView()
     let estimatedPriceView = EstimatedPriceView(estimatedPrice: -1, width: 1100, height: 1200, estimatedQuantity: 80, pricePerBlock: -1)

    var currentSample: Sample = MockData.sampleList[0]

    var lastSelectedImage = UIImage()

    private let getAreaVC = GetAreaViewController()
    // MARK: - Life Cycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.fileManager.saveImage(image: self.lastSelectedImage, imageName: self.matInsertedImageName + String(describing: viewModel.imageIndex), folderName: self.savingFolderName)
    }

    override func viewDidLayoutSubviews() {
        toBeEstimatedPriceView.textButton.layer.cornerRadius = toBeEstimatedPriceView.textButton.bounds.height/2
        estimatedPriceView.textButton.layer.cornerRadius = estimatedPriceView.textButton.bounds.height/2
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

    }

    override func configUI() {
        super.configUI()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: ImageLiteral.cartDark, style: .plain, target: self, action: nil)
        self.navigationItem.rightBarButtonItem?.tintColor = .black

        toBeEstimatedPriceView.backgroundColor = .black.withAlphaComponent(0.5)
        toBeEstimatedPriceView.alpha = 1
        estimatedPriceView.backgroundColor = .black.withAlphaComponent(0.5)
        estimatedPriceView.alpha = 0
    }

    func bind() {
        // Input
        let input = EstimateViewModel.Input(collectionModelSelected: sampleCollectionView.rx.modelSelected(Sample.self))

        // Output
        let output = viewModel.transform(input: input)

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
            .bind(to: rx.configSample)
            .disposed(by: viewModel.disposeBag)


        toBeEstimatedPriceView.textButton.rx.tap
            .subscribe(onNext: {
                self.getAreaVC.preferredSheetSizing = .medium
                self.present(self.getAreaVC, animated: true)
            })
            .disposed(by: viewModel.disposeBag)

        estimatedPriceView.textButton.rx.tap
            .subscribe(onNext: {
                self.getAreaVC.preferredSheetSizing = .medium
                self.present(self.getAreaVC, animated: true)
            })
            .disposed(by: viewModel.disposeBag)

        getAreaVC.saveButton
            .rx.tap.subscribe(onNext: {
                let quantityAndPrice = self.calculatePrice(width: self.getAreaVC.areaWidth, height: self.getAreaVC.areaHeight)
                self.estimatedPriceView.changeEstimation(estimatedPrice: Int(quantityAndPrice[1]), width: Int(self.getAreaVC.areaWidth), height: Int(self.getAreaVC.areaHeight), estimatedQuantity: Int(quantityAndPrice[0]), pricePerBlock: self.self.currentSample.samplePrice)
                self.toBeEstimatedPriceView.alpha = 0
                self.estimatedPriceView.alpha = 1

            })
            .disposed(by: viewModel.disposeBag)
        

    }


    // MARK: - Func


    func configure(with sample: Sample) {
        sampleDetailView.configure(with: sample)
        sourceImage = viewModel.getImage()
        maskedImage = viewModel.getMaskedImage()

        roomImageView.image = maskInputImage(with: sample)
    }

    private func calculatePrice(width: CGFloat, height: CGFloat) -> [CGFloat] {
        let sampleArea = currentSample.size.width * currentSample.size.height
        let estimatedQuantity = width*height / sampleArea
        let estimatedPrice = currentSample.samplePrice == -1 ? -1 : CGFloat(currentSample.samplePrice) * estimatedQuantity
        // FIXME: - 배열 말고 다른 방식 사용하기
        return [estimatedQuantity, estimatedPrice]
    }



    func maskInputImage(with sample: Sample) -> UIImage? {
        let takenCIImage = CIImage(cgImage: self.sourceImage.cgImage!)
        let beginImage = takenCIImage.oriented(CGImagePropertyOrientation(sourceImage.imageOrientation))
        let backgroundImage = UIImage.load(named: "Spread\(sample.imageName)")
        guard let backgroundCGImage = backgroundImage.cgImage else { return nil }
        guard let resizedBackgroundImage = backgroundCGImage.resize(size: self.sourceImage.size) else { return nil }
        let background = CIImage(cgImage: resizedBackgroundImage)
        let mask = CIImage(cgImage: self.maskedImage.cgImage!)

        let parameters = [
            kCIInputImageKey: beginImage,
            kCIInputBackgroundImageKey: background,
            kCIInputMaskImageKey: mask
        ]

        guard let compositeImage = CIFilter(name: "CIBlendWithMask", parameters: parameters )?.outputImage else {
            return nil
        }
        let ciContext = CIContext(options: nil)
        guard let filteredImageRef = ciContext.createCGImage(compositeImage, from: compositeImage.extent) else { return nil }
        self.lastSelectedImage = UIImage(cgImage: filteredImageRef)
        return self.lastSelectedImage
    }
}



// MARK: - configSample: Binder

extension Reactive where Base: EstimateViewController {
    var configSample: Binder<Sample> {
        return Binder(self.base) { estimateVC, sample in
            estimateVC.currentSample = sample
            estimateVC.toBeEstimatedPriceView.alpha = 1
            estimateVC.estimatedPriceView.alpha = 0
            estimateVC.configure(with: sample)
            if let matInsertedImage = self.base.maskInputImage(with: sample) {
                self.base.roomImageView.image = matInsertedImage
            }
        }
    }
}

