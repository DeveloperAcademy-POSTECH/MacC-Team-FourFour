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

    var sourceImage = UIImage()
    var maskedImage = UIImage()

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
    }


    // MARK: - Func


    func configure(with sample: Sample) {
        sampleDetailView.configure(with: sample)
        sourceImage = viewModel.getImage()
        maskedImage = viewModel.getMaskedImage()

        roomImageView.image = maskInputImage(with: sample)
    }

    func maskInputImage(with sample: Sample) -> UIImage? {
//        guard let takenImageData = self.sourceImage.jpegData(compressionQuality: 1.0) else { return nil }
//        guard let takenCIImage = CIImage(data: takenImageData) else { return nil }
//        guard let takenUIImage = UIImage(data: takenImageData) else { return nil }
        let takenCIImage = CIImage(cgImage: self.sourceImage.cgImage!)
        let beginImage = takenCIImage

//        let beginImage = takenCIImage.oriented(CGImagePropertyOrientation(takenUIImage.imageOrientation))

        let backgroundImage = UIImage.load(named: "Spread\(sample.imageName)")
        guard let backgroundCGImage = backgroundImage.cgImage else { return nil }
        guard let resizedBackgroundImage = backgroundCGImage.resize(size: self.sourceImage.size) else { return nil }
        let background = CIImage(cgImage: resizedBackgroundImage)

        guard let maskedCGImage = self.maskedImage.cgImage else { return nil }
        let mask = CIImage(cgImage: maskedCGImage) .oriented(CGImagePropertyOrientation(self.maskedImage.imageOrientation))

//        let parameters = [
//            kCIInputImageKey: beginImage,
//            kCIInputBackgroundImageKey: background,
//            kCIInputMaskImageKey: mask
//        ]

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
        return UIImage(cgImage: filteredImageRef)
    }
}



// MARK: - configSample: Binder

extension Reactive where Base: EstimateViewController {
    var configSample: Binder<Sample> {
        return Binder(self.base) { _, sample in
            if let matInsertedImage = self.base.maskInputImage(with: sample) {
                self.base.roomImageView.image = matInsertedImage
            }
            self.base.configure(with: sample)
        }
    }
}
