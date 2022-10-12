//
//  UIViewController+Alert.swift
//  Samplero
//
//  Created by Minkyeong Ko on 2022/10/12.
//

import UIKit

extension UIViewController {
    func makeAlert(title: String,
                   message: String,
                   okayAction: ((UIAlertAction) -> Void)? = nil,
                   completion : (() -> Void)? = nil) {
        let alertViewController = UIAlertController(title: title,
                                                    message: message,
                                                    preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "확인", style: .default, handler: okayAction)
        alertViewController.addAction(okayAction)
        
        self.present(alertViewController, animated: true, completion: completion)
    }
    
    func makeRequestAlert(title: String,
                          message: String,
                          okTitle: String = "확인",
                          cancelTitle: String = "취소",
                          okayAction: ((UIAlertAction) -> Void)?,
                          cancelAction: ((UIAlertAction) -> Void)? = nil,
                          completion : (() -> Void)? = nil) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        let alertViewController = UIAlertController(title: title,
                                                    message: message,
                                                    preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: cancelTitle,
                                         style: .default,
                                         handler: cancelAction)
        alertViewController.addAction(cancelAction)
        
        let okayAction = UIAlertAction(title: okTitle,
                                     style: .destructive,
                                     handler: okayAction)
        alertViewController.addAction(okayAction)
        
        self.present(alertViewController, animated: true, completion: completion)
    }
    
    func makeActionSheet(title: String? = nil,
                         message: String? = nil,
                         actionTitles:[String?],
                         actionStyle:[UIAlertAction.Style],
                         actions:[((UIAlertAction) -> Void)?]) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .actionSheet)
        
        for (index, title) in actionTitles.enumerated() {
            let action = UIAlertAction(title: title,
                                       style: actionStyle[index],
                                       handler: actions[index])
            alert.addAction(action)
        }
        
        self.present(alert, animated: true, completion: nil)
    }
}
