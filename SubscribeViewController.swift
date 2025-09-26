//
//  SubscribeViewController.swift
//  AI_Noise_Remover_APP
//
//  Created by PGNV on 17/09/25.
//

import UIKit

class SubscribeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func closeButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}
