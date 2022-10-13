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
//    private var sourceTakenPhotoData = Data()
    private var outputPicture = UIImage()
    private var takenImage = UIImage()
    private var takenImageData = Data()
    
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
        takenPictureImageView.image = image
//        takenPictureImageView.image = image.resizedImage(for: CGSize(width: 1080, height: 1920))
        takenImage = image
        takenImageData = image.jpegData(compressionQuality: 1.0)!
//        takenImage = UIImage.load(named: "sample_house")
    }
    
    private func addTargets() {
        retakeButton.rx.tap.bind {
            print("clicked retake picture button")
        }.disposed(by: disposeBag)
        
        nextButton.rx.tap.bind {
            // TODO: go next
            guard let model = try? VNCoreMLModel(for: FloorSegmentation.init(configuration: .init()).model)
            else { return }
            let request = VNCoreMLRequest(model: model, completionHandler: self.visionRequestDidComplete)

            request.imageCropAndScaleOption = .scaleFill

            DispatchQueue.global().async {
//                let handler = VNImageRequestHandler(cgImage: self.takenImage.cgImage!, options: [:])
                let handler = VNImageRequestHandler(data: self.takenImageData, options: [:])
                do {
                    try handler.perform([request])
                } catch {
                    print(error)
                }
            }

        }.disposed(by: disposeBag)
    }


    private func visionRequestDidComplete(request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            if let observations = request.results as? [VNCoreMLFeatureValueObservation],
               let segmentationmap = observations.first?.featureValue.multiArrayValue {
                let segmentationMask = segmentationmap.image(min: 0, max: 1)
                self.outputPicture = segmentationMask!.resizedImage(for: self.takenImage.size)!
                self.maskInputImage()
            }
        }
    }

    private func maskInputImage() {
        let backgroundImage = UIImage.load(named: "sample_mat_floor")

        let beginImage = CIImage(data: self.takenImageData)!.oriented(CGImagePropertyOrientation(UIImage(data: self.takenImageData)!.imageOrientation))
//        let beginImage = CIImage(cgImage: takenImage.cgImage!)
        guard let backgroundCGImage = backgroundImage.cgImage else { return }
        var background = CIImage(cgImage: backgroundCGImage.resize(size: self.takenImage.size)!)
        let mask = CIImage(cgImage: self.outputPicture.cgImage!)

        if let compositeImage = CIFilter(name: "CIBlendWithMask", parameters: [
            kCIInputImageKey: beginImage,
            kCIInputBackgroundImageKey: background,
            kCIInputMaskImageKey: mask])?.outputImage {
            let ciContext = CIContext(options: nil)
            let filteredImageRef = ciContext.createCGImage(compositeImage, from: compositeImage.extent)
            self.outputPicture = UIImage(cgImage: filteredImageRef!)
            let newViewController = EstimateViewController()
            newViewController.roomImageView.image = self.outputPicture
            self.present(newViewController, animated: true)
//            self.navigationControll9er?.pushViewController(newViewController, animated: true)
        }
    }
    
    func getRetakeButton() -> UIButton {
        return retakeButton
    }
}
