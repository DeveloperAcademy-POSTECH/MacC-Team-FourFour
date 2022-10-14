//
//  TakenPictureViewController.swift
//  Samplero
//
//  Created by JiwKang on 2022/10/10.
//

import AVFoundation
import CoreML
import UIKit
import Vision

import RxCocoa
import RxSwift
import SnapKit

class TakenPictureViewController: BaseViewController {
    
    // MARK: - Properties
    private var outputPicture = UIImage()

    private var takenPictureIndex: Int!
    private var takenPicture: UIImage!
    
    // Image FileManager
    private let savingfolderName: String = "estimate-photo"
    private let floorSegmentedImageName: String = "floor-segmented-photo-"
    private let matInsertedImageName: String = "mat-inserted-photo-"
    private let fileManager = LocalFileManager.instance
    
    // DB
    private let db = DBHelper.shared
    
    // Rx
    private var disposeBag = DisposeBag()

    // Picture view
    private let takenPictureImageView: UIImageView = {
        let imageView: UIImageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    // Top Drawer
    private let topDrawer: UIView = {
        let view: UIView = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    // Bottom Drawer
    private let bottomDrawer: UIView = {
        let view: UIView = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    // Retake Button
    private let retakeButton: UIButton = {
        let button: UIButton = UIButton()
        button.setTitle("다시찍기", for: .normal)
        button.titleLabel?.textColor = .white
        button.titleLabel?.font = .boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
        return button
    }()
    
    // Next Button
    private let nextButton: UIButton = {
        let button: UIButton = UIButton()
        button.setTitle("다음", for: .normal)
        button.titleLabel?.textColor = .white
        button.titleLabel?.font = .boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
        return button
    }()
    
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        addTargets()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        disposeBag = DisposeBag()
    }
    
    override func render() {
        view.addSubview(takenPictureImageView)
        
        view.addSubview(topDrawer)
        topDrawer.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(UIScreen.main.bounds.height / 6.975)
        }
        
        view.addSubview(bottomDrawer)
        bottomDrawer.snp.makeConstraints { make in
            make.bottom.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(UIScreen.main.bounds.height / 4.157)
        }
        
        takenPictureImageView.snp.makeConstraints { make in
            make.top.equalTo(topDrawer.snp.bottom)
            make.bottom.equalTo(bottomDrawer.snp.top)
            make.leading.trailing.equalToSuperview()
        }
        
        view.addSubview(retakeButton)
        retakeButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(24)
            make.bottom.equalToSuperview().inset(44)
        }
        
        view.addSubview(nextButton)
        nextButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(24)
            make.bottom.equalToSuperview().inset(44)
        }
    }
    
    // MARK: - Func
    
    func configPictureImage(image: UIImage) {
        self.takenPicture = image
        takenPictureImageView.image = takenPicture
    }
    
    private func addTargets() {
        retakeButton.rx.tap.bind {
            print("clicked retake picture button")
        }.disposed(by: disposeBag)
        
        nextButton.rx.tap.bind {
            // TODO: go next
            print("next button tapped")
            self.segmentFloor()
            // TODO: activation
        }.disposed(by: disposeBag)
    }

    private func segmentFloor() {
        guard let model = try? VNCoreMLModel(for: FloorSegmentation.init(configuration: .init()).model)
        else { return }
        let request = VNCoreMLRequest(model: model, completionHandler: self.visionRequestDidComplete)

        request.imageCropAndScaleOption = .scaleFill
        DispatchQueue.global().async {
            guard let takenImageData = self.takenPicture.jpegData(compressionQuality: 1.0) else { return }
            let handler = VNImageRequestHandler(data: takenImageData, options: [:])
            do {
                try handler.perform([request])
            } catch {
                print(error)
            }
        }
    }


    private func visionRequestDidComplete(request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            if let observations = request.results as? [VNCoreMLFeatureValueObservation],
               let segmentationMap = observations.first?.featureValue.multiArrayValue {
                guard let segmentationMask = segmentationMap.image(min: 0, max: 1) else { return }

                self.takenPictureIndex = self.db.getEstimateHistoryCount() + 1

                var estimateVC = EstimateViewController()
                estimateVC.bindViewModel(EstimateViewModel())

                if segmentationMask.size != self.takenPicture.size {
                    guard let resizedMask = segmentationMask.resizedImage(for: self.takenPicture.size) else { return }
                    self.fileManager.saveImage(image: resizedMask, imageName: self.floorSegmentedImageName + String(describing: self.takenPictureIndex!), folderName: self.savingfolderName)
                } else {
                    self.fileManager.saveImage(image: segmentationMask, imageName: self.floorSegmentedImageName + String(describing: self.takenPictureIndex!), folderName: self.savingfolderName)
                }


                self.fileManager.saveImage(image: self.takenPicture, imageName: self.matInsertedImageName + String(describing: self.takenPictureIndex!), folderName: self.savingfolderName)


                self.db.insertEstimateHistory(history: EstimateHistory(imageId: self.takenPictureIndex, width: nil, height: nil, selectedSampleId: nil))

                estimateVC.viewModel.imageIndex = self.takenPictureIndex

                self.navigationController?.pushViewController(estimateVC, animated: true)
            }
        }
    }

    func getRetakeButton() -> UIButton {
        return retakeButton
    }
}
