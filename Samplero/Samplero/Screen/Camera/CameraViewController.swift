//
//  CameraViewController.swift
//  Samplero
//
//  Created by JiwKang on 2022/10/09.
//

import Foundation
import AVFoundation
import CoreML
import UIKit
import Vision

import SnapKit
import RxSwift
import RxCocoa

class CameraViewController: BaseViewController {
    // MARK: - Properties

    private let savingFolderName: String = "estimate-photo"
    private let floorSegmentedImageName: String = "floor-segmented-photo-"
    private let matInsertedImageName: String = "mat-inserted-photo-"
    

    private var takenPicture = UIImage()
    private var takenPictureIndex: Int!
    var takenPictureViewController = TakenPictureViewController()

    let isClosedHelpView: Bool = UserDefaults.standard.bool(forKey: "isClosedHelpView")
   
    // Capture Session
    var session: AVCaptureSession?
    // Photo Output
    let output = AVCapturePhotoOutput()
    // Video Preview
    let previewLayer = AVCaptureVideoPreviewLayer()
    
    let fileManager = LocalFileManager.instance
    
    private let db = DBHelper.shared
    // Rx
    let viewModel = CameraViewModel()
    var disposeBag = DisposeBag()

    // Shutter Button
    private let shutterButton: UIButton = {
        let buttonSize: CGFloat = UIScreen.main.bounds.height / 14.07
        let boarderSize: CGFloat = buttonSize + buttonSize / 5
        
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize))
        button.layer.cornerRadius = buttonSize / 2
        button.layer.backgroundColor = UIColor.white.cgColor
        
        let boarder = CALayer()
        boarder.frame = CGRect(x: button.center.x - boarderSize / 2,
                               y: button.center.y - boarderSize / 2,
                               width: boarderSize,
                               height: boarderSize)
        boarder.cornerRadius = boarderSize / 2
        boarder.borderWidth = boarderSize / 20
        boarder.borderColor = UIColor.white.cgColor
        button.layer.addSublayer(boarder)
        
        return button
    }()
    
    // Help View
    private let cameraHelpView: CameraHelpView = CameraHelpView()
    
    // Top Drawer
    private let topDrawer: UIView = {
        let view: UIView = UIView()
        view.backgroundColor = .black
        view.alpha = 0.5
        view.isHidden = true
        return view
    }()
    
    // Bottom Drawer
    private let bottomDrawer: UIView = {
        let view: UIView = UIView()
        view.backgroundColor = .black
        view.alpha = 0.6
        return view
    }()
    
    // Bring Photo Button
    private let bringPhotoButton: UIButton = {
        let button: UIButton = UIButton()
        
        button.setImage(UIImage(systemName: "photo.on.rectangle"), for: .normal)
        button.setTitle(" 사진 불러오기", for: .normal)
        button.tintColor = .white
        button.setTitleColor(.lightGray.withAlphaComponent(0.8), for: .highlighted)
        
        button.backgroundColor = .white.withAlphaComponent(0.2)
        
        return button
    }()
    
    // Open History Button
    private let photoHistoryButton: UIButton = {
        let button: UIButton = UIButton()
        button.layer.cornerRadius = 3
        button.layer.masksToBounds = true
        return button
    }()
    
    // Open Cart Button
    private let cartButton: UIButton = {
        let button: UIButton = UIButton()
        button.setImage(ImageLiteral.cartLight, for: .normal)
        return button
    }()
    
    private let cartButtonBackground: UIView = {
        let view: UIView = UIView()
        view.layer.cornerRadius = UIScreen.main.bounds.width / 16.25
        view.layer.masksToBounds = true
        view.backgroundColor = .init(white: 1, alpha: 0.2)
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
    
    // MARK: - Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.global().async { [weak self] in
            self?.session?.startRunning()
        }
        navigationController?.isNavigationBarHidden = true
        
        viewModel.shopBasketSubject
            .map { _ in }
            .map {
                return self.viewModel.db.getShopBasketCount()
            }
            .map { count in
                if count >= 99 {
                    return " 99+ "
                } else {
                    return " \(count) "
                }
            }
            .bind(to: cartCountLabel.rx.text)
            .disposed(by: viewModel.disposeBag)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkCameraPermissions()
        addTargets()
        bind()
        // 뒤로가기 swipe 없애기
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bringPhotoButton.layer.cornerRadius = bringPhotoButton.bounds.height / 2
        cartCountLabel.layer.cornerRadius = cartCountLabel.layer.bounds.height / 2
    }
    
    override func render() {
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.bounds
        
        view.addSubview(bottomDrawer)
        bottomDrawer.snp.makeConstraints { make in
            make.bottom.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(UIScreen.main.bounds.height / 4.157)
        }
        
        view.addSubview(topDrawer)
        topDrawer.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(UIScreen.main.bounds.height / 6.975)
        }

        view.addSubview(cameraHelpView)
        cameraHelpView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.width.equalToSuperview()
            make.bottom.equalTo(bottomDrawer.snp.top)
        }

        view.addSubview(shutterButton)
        shutterButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(UIScreen.main.bounds.height / 10.55)
            make.centerX.equalToSuperview()
            make.size.equalTo(UIScreen.main.bounds.height / 14.07)
        }
        
        view.addSubview(bringPhotoButton)
        bringPhotoButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(UIScreen.main.bounds.height / 13.95)
            make.centerX.equalToSuperview()
            make.height.equalTo(46)
            make.width.equalTo(150)
        }
        
        view.addSubview(photoHistoryButton)
        photoHistoryButton.snp.makeConstraints { make in
            make.centerX.equalTo(view.snp.leading).inset(UIScreen.main.bounds.width / 8.86)
            make.centerY.equalTo(shutterButton)
            make.size.equalTo(UIScreen.main.bounds.width / 7.96)
        }
        
        view.addSubview(cartButtonBackground)
        cartButtonBackground.snp.makeConstraints { make in
            make.centerX.equalTo(view.snp.trailing).inset(UIScreen.main.bounds.width / 8.86)
            make.centerY.equalTo(shutterButton)
            make.size.equalTo(UIScreen.main.bounds.width / 8.125)
        }
        
        
        view.addSubview(cartButton)
        cartButton.snp.makeConstraints { make in
            make.center.equalTo(cartButtonBackground)
        }
        
        cartButton.addSubview(cartCountLabel)
        cartCountLabel.snp.makeConstraints { make in
            make.top.equalTo(cartButtonBackground)
            make.trailing.equalTo(cartButtonBackground)
        }
    }
    
    override func configUI() {
        #if targetEnvironment(simulator)
        let image = UIImage(named: "sample_photo")
        
        session?.stopRunning()
        
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.frame = view.bounds
        imageView.layer.zPosition = -1
        view.addSubview(imageView)
        #endif
        
        view.backgroundColor = .black
        navigationItem.backButtonTitle = "카메라"
        
        if isClosedHelpView {
            topDrawer.isHidden = false
            cameraHelpView.isHidden = true
        } else {
            topDrawer.isHidden = true
            cameraHelpView.isHidden = false
        }
    }
    
    func bind() {
        viewModel.estimateHistoryObservable
            .subscribe(onNext: { [weak self] history in
                let savingFolderName: String = "estimate-photo"
                let floorSegmentedImageName: String = "mat-inserted-photo"
                let imageName = floorSegmentedImageName + "-\(history.last?.imageId ?? 0)"
                let image = self?.fileManager.getImage(imageName: imageName, folderName: savingFolderName)
                
                if image == nil {
                    self?.photoHistoryButton.backgroundColor = .white
                } else {
                    self?.photoHistoryButton.setImage(image, for: .normal)
                }
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Func
    
    func addTargets() {
        shutterButton.rx.tap.bind {
            print("clicked take photo button")
            
            #if !targetEnvironment(simulator)
            self.output.capturePhoto(with: AVCapturePhotoSettings(),
                                delegate: self)
            #else
            self.takenPictureViewController.configPictureImage(image: UIImage(named: "sample_photo_0") ?? UIImage())
            self.takenPictureViewController.modalPresentationStyle = .overFullScreen
            self.takenPictureViewController.rx.retake
                .observe(on: ConcurrentDispatchQueueScheduler(qos: .background))
                .map { [weak self] in
                    self?.session?.startRunning()
                }
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: {
                    self.takenPictureViewController.dismiss(animated: true)
                }).disposed(by: self.disposeBag)
            
            self.present(self.takenPictureViewController, animated: true)
            
            self.session?.stopRunning()
            #endif
        }.disposed(by: disposeBag)

        bringPhotoButton.rx.tap.bind {
            let imagePickerController = UIImagePickerController()
            imagePickerController.sourceType = .photoLibrary
            imagePickerController.delegate = self
            imagePickerController.allowsEditing = false
            self.present(imagePickerController, animated: true)
        }.disposed(by: disposeBag)
        
        photoHistoryButton.rx.tap.bind { [weak self] in
            print("clicked history")
            
            var estimateHistoryViewController = EstimateHistoryViewController()
            estimateHistoryViewController.bindViewModel(EstimateHistoryViewModel())
            
            self?.navigationController?.pushViewController(estimateHistoryViewController, animated: true)

        }.disposed(by: disposeBag)
        
        cartButton.rx.tap.bind {
            var vc = ShopBasketViewController()
            vc.bindViewModel(ShopBasketViewModel())
            self.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by: disposeBag)
        
        cameraHelpView.xMarkButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.cameraHelpView.isHidden = true
                self?.topDrawer.isHidden = false

                UserDefaults.standard.set(true, forKey: "isClosedHelpView")
            })
            .disposed(by: disposeBag)

    }

    private func checkCameraPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            // Request
            AVCaptureDevice.requestAccess(for: .video) { granted in
                guard granted else {
                    return
                }
                DispatchQueue.main.async {
                    self.setUpCamera()
                }
            }
        case .restricted:
            break
        case .denied:
            break
        case .authorized:
            setUpCamera()
        @unknown default:
            break
        }
    }
    
    private func setUpCamera() {
        let session = AVCaptureSession()
        if let device = AVCaptureDevice.default(for: .video) {
            do {
                let input = try AVCaptureDeviceInput(device: device)
                if session.canAddInput(input) {
                    session.addInput(input)
                }
                
                if session.canAddOutput(output) {
                    session.addOutput(output)
                }
                
                previewLayer.videoGravity = .resizeAspectFill
                previewLayer.session = session
                
                DispatchQueue.global().async {
                    session.startRunning()
                }
                self.session = session
            } catch {
                print(error)
            }
        }
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
        DispatchQueue.main.async { [self] in
            if let observations = request.results as? [VNCoreMLFeatureValueObservation],
               let segmentationMap = observations.first?.featureValue.multiArrayValue {
                guard let segmentationMask = segmentationMap.image(min: 0, max: 1) else { return }

                self.takenPictureIndex = self.db.getEstimateHistoryCount() + 1



                if segmentationMask.size != self.takenPicture.size {
                    guard let resizedMask = segmentationMask.resizedImage(for: self.takenPicture.size) else { return }
                    self.fileManager.saveImage(image: resizedMask, imageName: self.floorSegmentedImageName + String(describing: self.takenPictureIndex!), folderName: self.savingFolderName)
                } else {
                    self.fileManager.saveImage(image: segmentationMask, imageName: self.floorSegmentedImageName + String(describing: self.takenPictureIndex!), folderName: self.savingFolderName)
                }


                self.fileManager.saveImage(image: self.takenPicture, imageName: self.matInsertedImageName + String(describing: self.takenPictureIndex!), folderName: self.savingFolderName)

                self.db.insertEstimateHistory(history: EstimateHistory(imageId: self.takenPictureIndex, width: nil, height: nil, selectedSampleId: nil))


                self.takenPictureViewController.dismiss(animated: true)
                var estimateVC = EstimateViewController()
                estimateVC.bindViewModel(EstimateViewModel())
                estimateVC.viewModel.imageIndex = self.takenPictureIndex
                self.navigationController?.pushViewController(estimateVC, animated: true)

                self.takenPictureViewController.stopLottieAnimation() // 로티 종료
            }
        }
    }
}

// MARK: - Extension

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation() else {
            return
        }

        let takenPictureViewController = TakenPictureViewController()
        takenPictureViewController.configPictureImage(image: UIImage(data: data) ?? UIImage())
        takenPictureViewController.rx.retake
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .map { [weak self] in
                self?.session?.startRunning()
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: {
                takenPictureViewController.dismiss(animated: true)
            }).disposed(by: disposeBag)

        takenPictureViewController.rx.nextButton
            .subscribe(onNext: {
                takenPictureViewController.setupLottieView() // 로티 시작
                self.takenPicture = takenPictureViewController.takenPicture
                self.takenPictureViewController = takenPictureViewController

                self.segmentFloor()
            }).disposed(by: disposeBag)

        takenPictureViewController.modalPresentationStyle = .overFullScreen

        self.present(takenPictureViewController, animated: true)

        session?.stopRunning()
    }

}

extension Reactive where Base: TakenPictureViewController {
    var retake: ControlEvent<Void> {
        let source = self.base.getRetakeButton().rx.tap
        return ControlEvent(events: source)
    }

    var nextButton: ControlEvent<Void> {
        let source = self.base.getNextButton().rx.tap
        return ControlEvent(events: source)
    }
}

extension Reactive where Base: UIView {
    public var tapGesture : ControlEvent<UITapGestureRecognizer> {
        self.base.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer()
        self.base.addGestureRecognizer(gesture)
        return gesture.rx.event
    }
}

extension CameraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        let selectedImage = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerOriginalImage")] as? UIImage ?? UIImage()

        let takenPictureViewController = TakenPictureViewController()
        takenPictureViewController.configPictureImage(image: selectedImage)
        takenPictureViewController.rx.retake
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .map { [weak self] in
                self?.session?.startRunning()
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: {
                takenPictureViewController.dismiss(animated: true)
            }).disposed(by: disposeBag)

        takenPictureViewController.rx.nextButton
            .subscribe(onNext: {
                self.takenPicture = takenPictureViewController.takenPicture
                self.takenPictureViewController = takenPictureViewController
                takenPictureViewController.setupLottieView()   // 로티시작
                self.segmentFloor()
            }).disposed(by: disposeBag)
        
        picker.dismiss(animated: true, completion: nil)
        takenPictureViewController.modalPresentationStyle = .overFullScreen
        self.present(takenPictureViewController, animated: true)

    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
