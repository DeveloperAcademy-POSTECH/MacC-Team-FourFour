//
//  UIPickerController+Rx.swift
//
//  Samplero
//
//  Created by DaeSeong on 2022/11/05.
//

import UIKit

import RxCocoa
import RxSwift

public typealias ImagePickerDelegate = UIImagePickerControllerDelegate & UINavigationControllerDelegate

extension Reactive where Base: UIImagePickerController {

    public var didFinishPickingMediaWithInfo: Observable<UIImage> {
        return RxImagePickerProxy.proxy(for: base)
            .didFinishPickingMediaWithInfoSubject
            .asObservable()
//            .do(onCompleted: {
//                self.base.dismiss(animated: true, completion: nil)
//            })
    }

    public var didCancel: Observable<Void> {
        return RxImagePickerProxy.proxy(for: base)
            .didCancelSubject
            .asObservable()
//            .do(onCompleted: {
//                self.base.dismiss(animated: true, completion: nil)
//            })
    }

}

extension UIImagePickerController: HasDelegate {
    public typealias Delegate = ImagePickerDelegate
}

class RxImagePickerProxy: DelegateProxy<UIImagePickerController, ImagePickerDelegate>, DelegateProxyType, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    public init(imagePicker: UIImagePickerController) {
        super.init(parentObject: imagePicker, delegateProxy: RxImagePickerProxy.self)
    }

    // MARK: - DelegateProxyType
    public static func registerKnownImplementations() {
        self.register { RxImagePickerProxy(imagePicker: $0) }
    }

    static func currentDelegate(for object: UIImagePickerController) -> ImagePickerDelegate? {
        return object.delegate
    }

    static func setCurrentDelegate(_ delegate: ImagePickerDelegate?, to object: UIImagePickerController) {
        object.delegate = delegate
    }

    // MARK: - Proxy Subject
    internal lazy var didFinishPickingMediaWithInfoSubject = PublishSubject<UIImage>()
    internal lazy var didCancelSubject = PublishSubject<Void>()


    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        let selectedImage = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerOriginalImage")] as? UIImage ?? UIImage()
        didFinishPickingMediaWithInfoSubject.onNext(selectedImage)
      //  didFinishPickingMediaWithInfoSubject.onCompleted()
        didCancelSubject.onCompleted()
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        didCancelSubject.onNext(())
    //    didCancelSubject.onCompleted()
        didFinishPickingMediaWithInfoSubject.onCompleted()
    }

    // MARK: - Completed
    deinit {
        self.didFinishPickingMediaWithInfoSubject.onCompleted()
        self.didCancelSubject.onCompleted()
    }

}
