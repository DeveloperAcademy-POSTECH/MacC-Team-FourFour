//
//  CameraViewController.swift
//  Samplero
//
//  Created by JiwKang on 2022/10/09.
//

import AVFoundation
import CoreML
import UIKit
import Vision

import SnapKit
import RxSwift
import RxCocoa

private enum Name {
    static let savingFolderName: String = "estimate-photo"
    static let floorSegmentedImageName: String = "floor-segmented-photo-"
    static let matInsertedImageName: String = "mat-inserted-photo-"
}

final class CameraViewController: BaseViewController, ViewModelBindableType {


    // MARK: - Properties

    var takenPictureViewController: TakenPictureViewController = {
        let viewController = TakenPictureViewController()
        viewController.modalPresentationStyle = .overFullScreen
        return viewController
    }()

    private let imagePickerController: UIImagePickerController = {
        let viewController = UIImagePickerController()
        viewController.sourceType = .photoLibrary
        viewController.allowsEditing = false
        return viewController
    }()

    let isClosedHelpView: Bool = UserDefaults.standard.bool(forKey: "isClosedHelpView")

    // Capture Session
    var session: AVCaptureSession = AVCaptureSession()
    // Photo Output
    let photoOutput = AVCapturePhotoOutput()

    let photoCaptureDelegate = RxAVCapturePhotoCaptureDelegate()

    // Video Preview
    let previewLayer = AVCaptureVideoPreviewLayer()
    
    
    private let db = DBHelper.shared
    // Rx
    //    let viewModel = CameraViewModel()
    var viewModel: CameraViewModel!

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

    override func viewDidLoad() {
        super.viewDidLoad()
        addTargets()
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
        
        session.stopRunning()
        
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


    // MARK: - Bind


    func bind() {
        viewModel.requestCameraPermission()
            .filter { status in
                status == .notDetermined || status == .authorized }
            .subscribe { status in
                if status == .notDetermined {
                    AVCaptureDevice.requestAccess(for: .video) { grated in
                        guard grated else { return }
                        self.setUpCamera()
                    }
                } else { self.setUpCamera() }
            }
            .disposed(by: viewModel.disposeBag)

        // Input
        let input = CameraViewModel.Input(
            viewWillAppear: rx.viewWillAppear,
            tappedPhotoHistoryButton: photoHistoryButton.rx.tap,
            tappedPickerDidCancel: imagePickerController.rx.didCancel,
            tappedBringPhotoButton: bringPhotoButton.rx.tap.map { self.imagePickerController },
            tappedCartButton: cartButton.rx.tap,
            tappedXMarkButton: cameraHelpView.xMarkButton.rx.tap.do(onNext: { _ in self.cameraHelpView.isHidden = true
                self.topDrawer.isHidden = false }),
            tappedNextButton: takenPictureViewController.nextButton.rx.tap
                .do(onNext: { _ in self.takenPictureViewController.setupLottieView() }),
            tappedRetakeButton: takenPictureViewController.retakeButton.rx.tap
                .do(onNext: { _ in self.session.rx.startRunning() }),
            photoOutput: session.rx.photoCaptureOutput(
                photoOutput: photoOutput,
                photoCaptureDelegate: photoCaptureDelegate),
            didFinishPicking: imagePickerController.rx.didFinishPickingMediaWithInfo)

        let output = viewModel.transform(input: input)

        output.viewWillAppear
            .subscribe { _ in
                self.session.rx.startRunning()
                self.navigationController?.isNavigationBarHidden = true }
            .disposed(by: viewModel.disposeBag)

        output.shopBasketCountString
            .bind(to: cartCountLabel.rx.text)
            .disposed(by: viewModel.disposeBag)

        output.lastHistoryImage
            .subscribe(onNext: { [weak self] lastHistoryImage in
                if lastHistoryImage == nil {
                    self?.photoHistoryButton.backgroundColor = .white
                } else {
                    self?.photoHistoryButton.setImage(lastHistoryImage, for: .normal)
                } })
            .disposed(by: viewModel.disposeBag)
    }


    // MARK: - Func


    private func addTargets() {
        shutterButton.rx.tap.bind {
#if !targetEnvironment(simulator)
            self.photoOutput.capturePhoto(with: AVCapturePhotoSettings(),
                                          delegate: self.photoCaptureDelegate)
#else
            self.takenPictureViewController.configPictureImage(image: UIImage(named: "sample_photo_0") ?? UIImage())
            self.takenPictureViewController.retakeButton.rx.tap
                .map { [weak self] in self?.session.rx.startRunning() }
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: {
                    self.takenPictureViewController.dismiss(animated: true)
                }).disposed(by: self.viewModel.disposeBag)
            
            self.present(self.takenPictureViewController, animated: true)
            self.session.stopRunning()
#endif
        }.disposed(by: viewModel.disposeBag)
    }

    private func setUpCamera() {
        if let device = AVCaptureDevice.default(for: .video) {
            do {
                let input = try AVCaptureDeviceInput(device: device)
                if session.canAddInput(input) {
                    session.addInput(input)
                }
                if session.canAddOutput(photoOutput) {
                    session.addOutput(photoOutput)
                }
                previewLayer.videoGravity = .resizeAspectFill
                previewLayer.session = session
                
                session.rx.startRunning()
            } catch { print(error) }
        }
    }
}


// MARK: - Extension

extension Reactive where Base: UIView {
    public var tapGesture: ControlEvent<UITapGestureRecognizer> {
        self.base.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer()
        self.base.addGestureRecognizer(gesture)
        return gesture.rx.event
    }
}

