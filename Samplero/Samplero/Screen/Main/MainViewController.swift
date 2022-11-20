//
//  MainViewController.swift
//  Samplero
//
//  Created by JiwKang on 2022/10/06.
//

import UIKit

class MainViewController: UIViewController {

    @IBAction func estimateButton(_ sender: Any) {

        let cameraVC = CameraViewController()

        self.navigationController?.pushViewController(cameraVC, animated: true)
    }
    @IBAction func shopBasketButton(_ sender: Any) {

    }
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.topItem?.title = "카메라"

   }


}

