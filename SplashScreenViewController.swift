//
//  SplashScreenViewController.swift
//  AI_Noise_Remover_APP
//
//  Created by PGNV on 12/09/25.
//

import UIKit

class SplashScreenViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        // Delay to show splash
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.navigateToNextScreen()
        }
    }
    
    func navigateToNextScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let hasSeenOnboarding = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
        
        if hasSeenOnboarding {
            // Go directly to MainViewController
            let mainVC = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
            self.navigationController?.setViewControllers([mainVC], animated: true)
        } else {
            // Show Question screen first
            let questionVC = storyboard.instantiateViewController(withIdentifier: "QuestionViewController") as! QuestionViewController
            self.navigationController?.pushViewController(questionVC, animated: true)
        }
    }
}
