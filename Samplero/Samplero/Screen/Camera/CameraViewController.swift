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
    
    // Capture Session
    var session: AVCaptureSession?
    // Photo Output
    let output = AVCapturePhotoOutput()
    // Video Preview
    let previewLayer = AVCaptureVideoPreviewLayer()
    
    // Rx
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
    
    // Top Drawer
    private let topDrawer: UIView = {
        let view: UIView = UIView()
        view.backgroundColor = .black
        view.alpha = 0.5
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
        
        button.setTitle("사진 불러오기", for: .normal)
        button.titleLabel?.textColor = .white
        button.titleLabel?.font = UIFont.systemFont(ofSize: UIScreen.main.bounds.width / 26)
        
        return button
    }()
    
    // Open History Button
    private let photoHistoryButton: UIButton = {
        let button: UIButton = UIButton()
        button.setImage(UIImage(named: "sample_history"), for: .normal)
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
        button.setImage(UIImage(named: "cart"), for: .normal)
        return button
    }()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkCameraPermissions()
        addTargets()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        disposeBag = DisposeBag()
    }
    
    override func render() {
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.bounds
        
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
        
        view.addSubview(shutterButton)
        shutterButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(UIScreen.main.bounds.height / 10.55)
            make.centerX.equalToSuperview()
            make.size.equalTo(UIScreen.main.bounds.height / 14.07)
        }
        
        view.addSubview(bringPhotoButton)
        bringPhotoButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(UIScreen.main.bounds.height / 12.98)
            make.leading.equalToSuperview().inset(UIScreen.main.bounds.width / 16.25)
        }
        
        view.addSubview(photoHistoryButton)
        photoHistoryButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(UIScreen.main.bounds.width / 19.5)
            make.centerY.equalTo(shutterButton)
            make.size.equalTo(UIScreen.main.bounds.width / 7.96)
        }
        
        view.addSubview(cartButton)
        cartButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(UIScreen.main.bounds.width / 19.5)
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
    }
    
    // MARK: - Func
    
    func addTargets() {
        shutterButton.rx.tap.bind {
            print("clicked take photo button")
            
            #if !targetEnvironment(simulator)
            self.output.capturePhoto(with: AVCapturePhotoSettings(),
                                delegate: self)
            #endif
        }.disposed(by: disposeBag)

        bringPhotoButton.rx.tap.bind {
            let imagePickerController = UIImagePickerController()
            imagePickerController.sourceType = .photoLibrary
            imagePickerController.delegate = self
            imagePickerController.allowsEditing = false
            self.present(imagePickerController, animated: true)
        }.disposed(by: disposeBag)
        
        photoHistoryButton.rx.tap.bind {
            // TODO: open history
            print("clicked history")
        }.disposed(by: disposeBag)
        
        cartButton.rx.tap.bind {
            // TODO: open cart
            print("clicked cart")
        }.disposed(by: disposeBag)
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
        let image = UIImage(data: data)
        
        session?.stopRunning()
        
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.frame = view.bounds
        view.addSubview(imageView)
    }
}

extension CameraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let selectedImage = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerOriginalImage")] as? UIImage {
            // TODO: TakenPictureViewController present with selectedImage
            print("got image from library", "\(selectedImage)")
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
