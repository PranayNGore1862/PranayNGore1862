//
//  IntroViewController.swift
//  AI_Noise_Remover_APP
//
//  Created by PGNV on 18/09/25.
//

import UIKit

class IntroViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var View1: UIView!
    @IBOutlet weak var View2: UIView!
    @IBOutlet weak var View3: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.isPagingEnabled = true
        navigationController?.isNavigationBarHidden = true
    }

    @IBAction func continueButton1(_ sender: UIButton) {
        let pageWidth = scrollView.frame.width
        scrollView.setContentOffset(CGPoint(x: pageWidth, y: 0), animated: true)
    }

    @IBAction func continueButton2(_ sender: UIButton) {
        let pageWidth = scrollView.frame.width
        scrollView.setContentOffset(CGPoint(x: pageWidth * 2, y: 0), animated: true)
    }

    @IBAction func continueButton3(_ sender: UIButton) {
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
        let homeVC = storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        navigationController?.pushViewController(homeVC, animated: true)
    }
}

