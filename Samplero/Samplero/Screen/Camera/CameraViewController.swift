//
//  CameraViewController.swift
//  Samplero
//
//  Created by JiwKang on 2022/10/09.
//

import AVFoundation
import UIKit

import SnapKit
import RxSwift
import RxCocoa

class CameraViewController: BaseViewController {
    
    // MARK: - Properties
    
    let isClosedHelpView: Bool = UserDefaults.standard.bool(forKey: "isClosedHelpView")
    
    // Capture Session
    var session: AVCaptureSession?
    // Photo Output
    let output = AVCapturePhotoOutput()
    // Video Preview
    let previewLayer = AVCaptureVideoPreviewLayer()
    
    let fileManager = LocalFileManager.instance
    
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
        button.layer.cornerRadius = UIScreen.main.bounds.width / 16.25
        button.layer.masksToBounds = true
        button.backgroundColor = .init(white: 1, alpha: 0.2)
        button.setImage(ImageLiteral.cartLight, for: .normal)
        return button
    }()
    
    // MARK: - Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkCameraPermissions()
        addTargets()
        bind()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bringPhotoButton.layer.cornerRadius = bringPhotoButton.bounds.height / 2
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
        
        view.addSubview(cartButton)
        cartButton.snp.makeConstraints { make in
            make.centerX.equalTo(view.snp.trailing).inset(UIScreen.main.bounds.width / 8.86)
            make.centerY.equalTo(shutterButton)
            make.size.equalTo(UIScreen.main.bounds.width / 8.125)
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
                let savingfolderName: String = "estimate-photo"
                let floorSegmentedImageName: String = "floor-segmented-photo"
                let imageName = floorSegmentedImageName + "-\(history.last?.imageId ?? 0)"
                let image = self?.fileManager.getImage(imageName: imageName, folderName: savingfolderName)
                
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
            let takenPictureViewController = TakenPictureViewController()
            takenPictureViewController.configPictureImage(image: UIImage(named: "sample_photo_0") ?? UIImage())
            takenPictureViewController.modalPresentationStyle = .overFullScreen
            takenPictureViewController.rx.retake
                .observe(on: ConcurrentDispatchQueueScheduler(qos: .background))
                .map { [weak self] in
                    self?.session?.startRunning()
                }
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: {
                    takenPictureViewController.dismiss(animated: true)
                }).disposed(by: self.disposeBag)
            
            self.present(takenPictureViewController, animated: true)
            
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
            // TODO: open cart
            print("clicked cart")
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
}

// MARK: - Extension

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation() else {
            return
        }
        
        let takenPictureViewController = TakenPictureViewController()
        takenPictureViewController.configPictureImage(image: UIImage(data: data) ?? UIImage())
        takenPictureViewController.modalPresentationStyle = .overFullScreen
        takenPictureViewController.rx.retake
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .map { [weak self] in
                self?.session?.startRunning()
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: {
                takenPictureViewController.dismiss(animated: true)
            }).disposed(by: disposeBag)
        self.present(takenPictureViewController, animated: true)
        
        session?.stopRunning()
    }
}

extension Reactive where Base: TakenPictureViewController {
    var retake: ControlEvent<Void> {
        let source = self.base.getRetakeButton().rx.tap
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
        takenPictureViewController.modalPresentationStyle = .overFullScreen
        takenPictureViewController.rx.retake
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .map { [weak self] in
                self?.session?.startRunning()
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: {
                takenPictureViewController.dismiss(animated: true)
            }).disposed(by: disposeBag)
        
        picker.dismiss(animated: true, completion: nil)
        self.present(takenPictureViewController, animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
