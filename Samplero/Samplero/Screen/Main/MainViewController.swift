//
//  MainViewController.swift
//  Samplero
//
//  Created by JiwKang on 2022/10/06.
//

import UIKit

class MainViewController: UIViewController {

    @IBAction func estimateButton(_ sender: Any) {

        var cameraVC = CameraViewController()
//        var estimateVC = EstimateViewController()
//        estimateVC.bindViewModel(EstimateViewModel())

        self.navigationController?.pushViewController(cameraVC, animated: true)
    }
    @IBAction func shopBasketButton(_ sender: Any) {
        var shopBasketVC = ShopBasketViewController()
        shopBasketVC.bindViewModel(ShopBasketViewModel())
                self.navigationController?.pushViewController(shopBasketVC, animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.topItem?.title = "카메라"

   }


}

