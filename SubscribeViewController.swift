//
//  SubscribeViewController.swift
//  AI_Noise_Remover_APP
//
//  Created by PGNV on 17/09/25.
//

import UIKit
import Purchases
import RevenueCat

class SubscribeViewController: UIViewController {

    @IBOutlet weak var yearBtn: UIButton!
    @IBOutlet weak var weekBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        yearBtn.setImage(UIImage(named: "UnPress_buttonnew"), for: .normal)
        weekBtn.setImage(UIImage(named: "UnPress_buttonnew"), for: .normal)
        Purchases.shared.offerings { (offerings, error) in
            if let offerings = offerings {
                let offer = offerings.current
                let packages = offer?.availablePackages
                
                guard packages != nil else { return }
                
                for i in 0...packages!.count-1 {
                    let package = packages![i] // create a reference to the package
                    let product = package.product // create a reference to the product
                    let title = product.localizedTitle // Product title
                    let price = product.price // Product Price
                    var duration = "" // Product Duration
                    let subscriptionPeriod = product.subscriptionPeriod
                    
                    switch subscriptionPeriod!.unit {
                        
                    case SKProduct.PeriodUnit.week:
                        duration = "\(subscriptionPeriod!.numberOfUnits) Monthly"
                        
                    case SKProduct.PeriodUnit.year:
                        duration = "\(subscriptionPeriod!.numberOfUnits) Yearly"
                        
                    @unknown default:
                        duration = ""
                    }
                }
            }
        }
    }
    
    @IBAction func closeButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true)
    }
    
    var subscribe: String = ""
    @IBAction func yearButton(_ sender: UIButton) {
        yearBtn.setImage(UIImage(named: "Press_button"), for: .normal)
        weekBtn.setImage(UIImage(named: "UnPress_buttonnew"), for: .normal)
        subscribe = "megapack"
    }
    
    @IBAction func weeklyButton(_ sender: UIButton) {
        weekBtn.setImage(UIImage(named: "Press_button"), for: .normal)
        yearBtn.setImage(UIImage(named: "UnPress_buttonnew"), for: .normal)
        subscribe = "normalpack"
    }
    
    @IBAction func subscribeBtn(_ sender: UIButton) {
        if subscribe == "megapack" {
            let alertController = UIAlertController(title: "Subscribe Mega Pack", message: "Will Subscribe the Mega Pack", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            let vc = storyboard?.instantiateViewController(identifier: "ViewController") as! ViewController
            vc.count = 2751
            let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
                UserDefaults.standard.set(2750, forKey:"launchCount")
                let alert = UIAlertController(title: "Subscribed",
                                              message: "Purchase Successfully Done",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
            alertController.addAction(okAction)
            alertController.addAction(cancel)
            present(alertController, animated: true)
        }else if subscribe == "normalpack" {
            UserDefaults.standard.set(50, forKey:"launchCount")
        }
    }
    
//    @objc func purchasedTapped(sender: UIButton) {
//        let package = self.packagesAvailableForPurchase[sender.tag]
//        
//        Purchases.shared.purchasePackage(package) { (transaction, purchaserInfo, error, userCancelled) in
//            if purchaserInfo?.entitlement.all["id"]?.isActive == true {
//                self.dismiss(animated: true, completion: nil)
//            }
//        }
//    }
    func checkSubscriptionStatus() {
        Purchases.shared.getCustomerInfo { customerInfo, error in
            if let customerInfo = customerInfo {
                if customerInfo.entitlements.active["premium"] != nil {
                    print("User has premium")
                } else {
                    print("User is free")
                }
            }
        }
    }

    func purchase(package: Package) {
        Purchases.shared.purchase(package: package) { (transaction, customerInfo, error, userCancelled) in
            if let error = error {
                print("Purchase error: \(error.localizedDescription)")
                return
            }
            
            if let customerInfo = customerInfo {
                if customerInfo.entitlements.active["premium"] != nil {
                    print("Unlocked Premium 🎉")
                    // Save in UserDefaults/Keychain if you want
                }
            }
        }
    }

}
