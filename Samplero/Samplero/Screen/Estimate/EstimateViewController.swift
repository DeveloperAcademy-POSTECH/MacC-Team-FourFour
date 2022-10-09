//
//  EstimateViewController.swift
//  Samplero
//
//  Created by DaeSeong on 2022/10/08.
//

import UIKit

import SnapKit

private enum Size {
    static let deviceHeight = UIScreen.main.bounds.size.height - ((UIApplication.shared.windows.first?.safeAreaInsets.top) ??  0) - 44
    static let defaultOffset = 20.0
    static let samplePriceTopOffset = 28
    static let samplePriceValueLeadingOffset = 23
    static let sampleAddButtonWidth = 100
    static let sampleAddButtonHeight = 39
    static let sampleAddButtonTopOffset = 17
    static let sampleAddButtonCornerRadius = 14.0
    static let cellItemSize = 40
}

class EstimateViewController: BaseViewController {


    // MARK: - Properties

    
    private let roomImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.image = ImageLiteral.sampleRoom
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    private let sampleDetailView = SampleDetailView(sample: MockData.sampleList[0])

    private let bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        return view
    }()

    private let samplePriceLabel: UILabel = {
        let label = UILabel()
        label.textAlignment =  .left
        label.font = .systemFont(ofSize: 14)
        label.text = "샘플가격"
        label.textColor = .systemGray2
        return label
    }()

    private let samplePriceValueLabel: UILabel = {
        let label = UILabel()
        label.textAlignment =  .left
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = .black
        label.text = "5000원"
        return label
    }()

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
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.flowLayout)
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

    private var lastSelectedIndexPath: IndexPath?


    // MARK: - Life Cycle


    override func viewDidLoad() {
        super.viewDidLoad()
        setDelegation()
    }

    override func render() {
        view.addSubview(roomImageView)
        roomImageView.snp.makeConstraints { make in
            make.height.equalTo(Size.deviceHeight*0.69)
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
        }

        roomImageView.addSubview(sampleCollectionView)
        sampleCollectionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(14)
            make.height.equalTo(40)
        }

        view.addSubview(sampleDetailView)
        sampleDetailView.snp.makeConstraints { make in
            make.top.equalTo(roomImageView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(Size.deviceHeight*0.2)
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
            make.trailing.equalTo(-Size.defaultOffset)
            make.width.equalTo(Size.sampleAddButtonWidth)
            make.height.equalTo(Size.sampleAddButtonHeight)

        }

    }

    override func configUI() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: ImageLiteral.shoppingBag, style: .plain, target: self, action: nil)
        self.navigationItem.rightBarButtonItem?.tintColor = .black

    }


    // MARK: - Func

    private func setDelegation() {
        sampleCollectionView.dataSource = self
        sampleCollectionView.delegate = self

    }
}


// MARK: - UICollectionViewDataSource


extension EstimateViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return MockData.sampleList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withType: SampleCollectionViewCell.self, for: indexPath)
        cell.configure(with: MockData.sampleList[indexPath.item].imageName)
        
        if indexPath.item == 0 {
            lastSelectedIndexPath = indexPath
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .left)
            sampleDetailView.configure(with: MockData.sampleList[indexPath.item])
            samplePriceValueLabel.text = MockData.sampleList[indexPath.item].samplePrice
        }
        cell.isSelected = (lastSelectedIndexPath == indexPath)

        return cell
    }
}


// MARK: - UICollectionViewDelegate


extension EstimateViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        sampleDetailView.configure(with: MockData.sampleList[indexPath.item])
        samplePriceValueLabel.text = MockData.sampleList[indexPath.item].samplePrice
    }
}

