//
//  MainViewController.swift
//  Samplero
//
//  Created by JiwKang on 2022/10/06.
//

import UIKit

class MainViewController: UIViewController {


    @IBAction func shopButton(_ sender: UIButton) {
        let shopBasketVC = ShopBasketViewController()
        self.navigationController?.pushViewController(shopBasketVC, animated: true)
    }
    @IBAction func estimateButton(_ sender: Any) {

        var estimateVC = EstimateViewController()
        estimateVC.bindViewModel(EstimateViewModel())

        self.navigationController?.pushViewController(estimateVC, animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "카메라"

        
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }

   }



