//
//  ProViewController.swift
//  Panoragram
//
//  Created by MacMini on 21/12/20.
//  Copyright © 2020 Mac. All rights reserved.
//

import UIKit
import RevenueCat
import StoreKit

 

class ProViewController: UIViewController {
    
    var currencyCode : String = ""
    var premiumProtocol : PremiumPurchased!
    var availablePackages = [Package]()
    var selectedTag = 1
    var isNavigatedFromOnboarding: Bool! = false
    
    
    @IBOutlet var vwOff: UIView!
    @IBOutlet weak var activatorView: UIView!
    @IBOutlet weak var restore: UIButton!
    @IBOutlet var priceLabel: [UILabel]!
    @IBOutlet var durationLabel: [UILabel]!
    @IBOutlet var perWeekPriceLabel: [UILabel]!
    @IBOutlet var saveLbl: [UILabel]!
    @IBOutlet var optionsButton: [UIButton]!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
   
    @IBOutlet var awareLbl: UILabel!

    @IBOutlet var saveImgBg: UIImageView!
    @IBOutlet var planStackView: UIStackView!
    @IBOutlet var planStackWidth: NSLayoutConstraint!
   
    @IBOutlet var creditStackView: UIStackView!
    @IBOutlet var creditStackWidth: NSLayoutConstraint!
    var timer: Timer!
  
    var isIntroDuctOn: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timer = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(shakeBtn), userInfo: nil, repeats: true)    
        activatorView.isHidden = false

        loadInAppPurchases()
        
        DispatchQueue.main.async{
            Purchases.shared.getCustomerInfo { [self] (purchaserInfo, error) in
                if purchaserInfo != nil {
                    subscriptionInfo = "\(purchaserInfo!.activeSubscriptions)"
                    print("--------------------\(subscriptionInfo)--------------------")
//                    setContinueImage()
                    if subscriptionInfo.contains(oneWeekIdenti) || subscriptionInfo.contains(oneYearIdenti){
                        // Display Credit Details
                        selectedTag = 2
                        optionsButton.forEach({$0.isSelected = false})
                        optionsButton[selectedTag].isSelected = true
                        durationLabel.forEach({$0.textColor = .white})
                        durationLabel[selectedTag].textColor = .white
                        planStackWidth = changeMultiplier(planStackWidth, multiplier: 0.001)
                        planStackView.isHidden = true
                        vwOff.isHidden = true
                    } else {
                        // Display Plan Details
                        selectedTag = 1
                        optionsButton.forEach({$0.isSelected = false})
                        optionsButton[selectedTag].isSelected = true
                        durationLabel.forEach({$0.textColor = .white})
                        durationLabel[selectedTag].textColor = .white
                        creditStackWidth = changeMultiplier(creditStackWidth, multiplier: 0.001)
                        creditStackView.isHidden = true
                        perWeekPriceLabel.forEach({$0.textColor = .textPrompt})
                        perWeekPriceLabel[selectedTag].textColor = .textPrompt
                    }
                    
                    if selectedTag != 0 {
                        awareLbl.isHidden = true
                    } else {
                        awareLbl.isHidden = false
                    }
                }
            }
        }
        
    }
    @objc func shakeBtn(){
        continueButton.zoomInZoomOut()
    }
    
    
    
    
    @IBAction func optionsButton(_ sender: UIButton) {
        optionsButton.forEach { $0.isSelected = false }
        optionsButton[sender.tag].isSelected = true
        selectedTag = sender.tag
        durationLabel.forEach({$0.textColor = .white})
        priceLabel.forEach({$0.textColor = .white})
        durationLabel[selectedTag].textColor = .white
        priceLabel[selectedTag].textColor = .white
        if sender.tag < 2 {
            perWeekPriceLabel.forEach({$0.textColor = .textPrompt})
            perWeekPriceLabel[selectedTag].textColor = .white
        }
        
        if selectedTag == 1 {
            saveImgBg.image = UIImage(named: "img%Press")
        }else{
            saveImgBg.image = UIImage(named: "img%Unpress")
        }
        if isIntroDuctOn{
            if selectedTag != 0 {
                
                awareLbl.isHidden = true
            } else {
                
                awareLbl.isHidden = false
            }
        } else {
            awareLbl.isHidden = true
        }
    }
    
    @IBAction func continueBtnTapped(_ sender: UIButton) {
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()

        isPremissionPopUpShowed = true
        activatorView.isHidden = false
        self.view.isUserInteractionEnabled = false
        Purchases.shared.purchase(package: availablePackages[selectedTag]) { [self](transaction, purchaserInfo, error, userCancelled) in
            if error == nil {
                
                if purchaserInfo!.entitlements[revenenueCatPurchaseID]?.isActive == true {
                    var alertController = UIAlertController()
                    if selectedTag == 0 {
                        creditLeft += weekCreditAmount
                        Purchases.shared.getCustomerInfo { (purchaserInfo, error) in
                            getExpirationDate1 = purchaserInfo!.expirationDate(forProductIdentifier: oneWeekIdenti)
                            getExpirationDate2 = purchaserInfo!.expirationDate(forProductIdentifier: oneWeekIdenti)
                        }
                        alertController = UIAlertController(title: "Successful", message: "Subscription purchased successfully. \(weekCreditAmount) Bonus credits added in your app.", preferredStyle: .alert)
                    } else if selectedTag == 1 {
                        creditLeft += yearCreditAmount
                        Purchases.shared.getCustomerInfo { (purchaserInfo, error) in
                            getExpirationDate1 = purchaserInfo!.expirationDate(forProductIdentifier: oneYearIdenti)
                            getExpirationDate2 = purchaserInfo!.expirationDate(forProductIdentifier: oneYearIdenti)
                        }
                        alertController = UIAlertController(title: "Successful", message: "Subscription purchased successfully. \(yearCreditAmount) Bonus credits added in your app.", preferredStyle: .alert)
                    } else if selectedTag == 2 {
                        creditLeft += twoHundCreditAmount
                        alertController = UIAlertController(title: "Purchased", message: "Successful. Credits Added in your app.", preferredStyle: .alert)
                    } else if selectedTag == 3 {
                        creditLeft += fourHundCreditAmount
                        alertController = UIAlertController(title: "Purchased", message: "Successful. Credits Added in your app.", preferredStyle: .alert)
                    }
                    activatorView.isHidden = true
                    self.view.isUserInteractionEnabled = true
                    print("Purchased")
                    
                    alertController.addAction(UIAlertAction(title: "Done", style: .default, handler: { [self] action in
                        if isAlreadyLaunched {
                            self.dismiss(animated: true)
                        } else {
                            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
                            navigationController?.pushViewController(vc, animated: true)
                        }
                        isAlreadyLaunched = true
                        premiumProtocol.premiumPurchased!()
                    }))
                    
                    self.present(alertController, animated: true, completion: nil)
                    //self.presentAlert(withTitle: "Purchased", message: "Successful. You need to restart your application to enjoy pro access")
                }
            } else if userCancelled {
                activatorView.isHidden = true
                self.view.isUserInteractionEnabled = true
            } else if let err = error as NSError? {
                activatorView.isHidden = true
                self.view.isUserInteractionEnabled = true
                // handle specific errors
                switch ErrorCode(_bridgedNSError: err) {
                case .purchaseNotAllowedError:
                    self.presentAlert(withTitle: "Failed", message: "Purchases not allowed on this device.")
                case .purchaseInvalidError:
                    self.presentAlert(withTitle: "Failed", message: "Purchase invalid, check payment source.")
                case .productAlreadyPurchasedError:
                    self.presentAlert(withTitle: "Failed", message: "This product is already purchased")
                default:
                    break
                }
            }
        }
    }
    
    
    
    @IBAction func back(_ sender: Any) {
        if isAlreadyLaunched == false{
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeViewController")as! HomeViewController
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func loadInAppPurchases() {
        Purchases.shared.getOfferings { [self] (offerings, error) in
            
            if error != nil {
                activatorView.isHidden = true
                self.presentAlert(withTitle: "Failed", message: "Purchase failed. Please try again later")
                continueButton.isEnabled = false
            }
            
            if (offerings?.current?.availablePackages) != nil {
                continueButton.isEnabled = true
                let offer = offerings?.current
                let packages = offer?.availablePackages
                guard packages != nil else {
                    return
                }
                
                for i in 0..<packages!.count {
                    let package = packages![i]
                    self.availablePackages.append(package)
                    let product = package.storeProduct
                    let price = product.localizedPriceString
                    currencyCode = product.currencyCode ?? "USD"
                   
                    print("packageType:\(package.packageType)")
                    print(price)
                    print("IntroPrice - \(product.localizedIntroductoryPriceString ?? "")")
                    
                    
                    
                    if product.productIdentifier == oneWeekIdenti {
                        durationLabel[0].text = "+\(weekCreditAmount) Bonus Coins"
                        
                        if product.localizedIntroductoryPriceString != nil {
                            // Introductory is ON
                            isIntroDuctOn = true
                        } else {
                            // Introductory is OFF
                            isIntroDuctOn = false
                        }
                        
                        if isIntroDuctOn {
                            awareLbl.text = "You will be charged \(price) per week after your subscription expires. Cancel anytime"
                            Purchases.shared.checkTrialOrIntroDiscountEligibility(product: product) { [self] eligibility in
                                if eligibility == .eligible {
                                    priceLabel[0].text = "\(product.localizedIntroductoryPriceString!)"
                                    calculatePerWeekAmount(subPrice: packages![0].storeProduct.introductoryDiscount!.price) { [self] weekCal, monthCal, yearCal in
                                        perWeekPriceLabel[0].text = "\(weekCal ?? "")/Week"
                                    }
                                } else {
                                    priceLabel[0].text = "\(price)"
                                    calculatePerWeekAmount(subPrice: packages![0].storeProduct.price) { [self] weekCal, monthCal, yearCal in
                                        perWeekPriceLabel[0].text = "\(weekCal ?? "")/Week"
                                    }
                                }
                            }
                        } else {
                            priceLabel[0].text = "\(price)"
                            calculatePerWeekAmount(subPrice: packages![0].storeProduct.price) { [self] weekCal, monthCal, yearCal in
                                perWeekPriceLabel[0].text = "\(weekCal ?? "")/Week"
                            }
                        }
                        
                        calculateSavings(weeklyPrice: packages![0].storeProduct.price,yearlyPrice: packages![1].storeProduct.price) { [self] monthSaving, yearSaving in
                            saveLbl[1].text = "Save \(yearSaving ?? "")%"
                        }
                        
                    }
                    
                    if product.productIdentifier == oneYearIdenti {
                        durationLabel[1].text = "+\(yearCreditAmount) Bonus Coins"
                        priceLabel[1].text = "\(price)"
                        calculatePerWeekAmount(subPrice: packages![1].storeProduct.price) { [self] weekCal, monthCal, yearCal in
                            perWeekPriceLabel[1].text = "\(yearCal ?? "")/Week"
                        }
                    }
                    
                    if product.productIdentifier == firstIdenti {
                        durationLabel[2].text = "\(twoHundCreditAmount) credits"
                        priceLabel[2].text = "\(price)"
                    }
                    
                    if product.productIdentifier == secondIdenti {
                        durationLabel[3].text = "\(fourHundCreditAmount) credits"
                        priceLabel[3].text = "\(price)"
                    }
                }
                activatorView.isHidden = true
            }
        }
    }
    
    @IBAction func restoreBtnTapped(_ sender: UIButton) {
        activatorView.isHidden = false
        Purchases.shared.restorePurchases { [self] purchaserInfo, error in
            if purchaserInfo?.entitlements.all[revenenueCatPurchaseID]?.isActive == true {
                // NotificationCenter.default.post(name: NSNotification.Name("ProAccessUser"), object: nil)
                print("Purchased")
                activatorView.isHidden = true
                var alertController : UIAlertController = UIAlertController()
                
                if "\(purchaserInfo!.activeSubscriptions)".contains(oneWeekIdenti) {
                    alertController = UIAlertController(title: "Purchased", message: "Successful. Enjoy the premium version of the app.", preferredStyle: .alert)
                } else if "\(purchaserInfo!.activeSubscriptions)".contains(oneYearIdenti) {
                    alertController = UIAlertController(title: "Purchased", message: "Successful. Enjoy the premium version of the app.", preferredStyle: .alert)
                } else {
                    alertController = UIAlertController(title: "No Purchases Found", message: "You've no active subscriptions. Kindly purchase any of the given subscriptions.", preferredStyle: .alert)
                }
                
                
                alertController.addAction(UIAlertAction(title: "Done", style: .default, handler: { [self] action in
                    if isAlreadyLaunched {
                        self.dismiss(animated: true)
                    } else {
                        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
                        navigationController?.pushViewController(vc, animated: true)
                    }
                    isAlreadyLaunched = true
                    premiumProtocol.premiumPurchased!()
                }))

                self.present(alertController, animated: true, completion: nil)


                //self.presentAlert(withTitle: "Restored", message: "Successful. You need to restart your application to enjoy pro access")
              //self.dismiss(animated: true, completion: nil)
            } else if purchaserInfo?.entitlements.all[revenenueCatPurchaseID]?.isActive == false {
                activatorView.isHidden = true
                DispatchQueue.main.async {
                    let alert = UIAlertController(
                        title: "No Purchases Found",
                        message: "You've no active subscriptions. Kindly purchase any of the given subscriptions.",
                        preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    self.present(alert, animated: true)
                }
            } else if error != nil {
                activatorView.isHidden = true
                self.presentAlert(withTitle: "Failed", message: "Purchase failed. Please try again later")
                print("Purchase failed. Please try again later")
            } else if purchaserInfo!.entitlements.active.isEmpty {
                activatorView.isHidden = true
                self.presentAlert(withTitle: "No Purchases Found", message: "You've no active subscriptions. Kindly purchase any of the given subscriptions.")
                print("You've no active subscriptions. Kindly purchase any of the given subscriptions.")
            }
        }
    }
    
  
    @IBAction func privacyPolicy(_ sender: Any) {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
        controller.urlString = "https://appsatgeetaviradiya.blogspot.com/2025/02/geeta-viradiyas-privacy-policy.html"
        controller.topText = "Privacy Policy"
        self.present(controller, animated: true, completion: nil)
    }


    @IBAction func termsOfUse(_ sender: Any) {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
        controller.urlString = "https://appsatgeetaviradiya.blogspot.com/2025/02/geeta-viradiyas-terms-of-use.html"
        controller.topText = "Terms of use"
        self.present(controller, animated: true, completion: nil)
    }
    
    
}



extension ProViewController {
    
//    func setContinueImage(){
//        if subscriptionInfo.contains(oneWeekIdenti) || subscriptionInfo.contains(oneYearIdenti) {
//            continueBtn.setImage(UIImage(named: "get_credits_sc1718"), for: .normal)
//            continueBtn.setImage(UIImage(named: "get_credits_sc1718_h"), for: .highlighted)
//        } else {
//            continueBtn.setImage(UIImage(named: "subscribe_sc1718"), for: .normal)
//            continueBtn.setImage(UIImage(named: "subscribe_sc1718_h"), for: .highlighted)
//        }
//    }
    func calculateSavings(weeklyPrice: Decimal = 0.0, monthlyPrice: Decimal = 0.0, yearlyPrice: Decimal = 0.0, completion: @escaping(_ monthSaving: String?, _ yearSaving: String?) -> Void) {
        let weeksInMonth = 4
        let weeksInYear = 52
        
        let weeklyPrice = NSDecimalNumber(decimal: weeklyPrice).doubleValue
        let monthlyPrice = NSDecimalNumber(decimal: monthlyPrice).doubleValue
        let yearlyPrice = NSDecimalNumber(decimal: yearlyPrice).doubleValue
        
        let totalMonthlyCost = weeklyPrice * Double(weeksInMonth)
        let monthlySavings = ((totalMonthlyCost - monthlyPrice) / totalMonthlyCost) * 100
        let totalYearlyCost = weeklyPrice * Double(weeksInYear)
        let yearlySavings = ((totalYearlyCost - yearlyPrice) / totalYearlyCost) * 100
        
        let roundedMonthlySavings = "\(Int(ceil(monthlySavings)))"
        let roundedYearlySavings = "\(Int(ceil(yearlySavings)))"
        completion(roundedMonthlySavings, roundedYearlySavings)
    }
    func calculatePerWeekAmount(subPrice: Decimal, completion: @escaping(_ weekCal: String?,_ monthCal: String?, _ yearCal: String?)-> Void) {
        
        let subPrice = NSDecimalNumber(decimal: subPrice).doubleValue
        
        let weekPriceCal = getLocalizedPrice(for: subPrice/1)
        let monthPriceCal = getLocalizedPrice(for: subPrice/4)
        let yearPriceCal = getLocalizedPrice(for: subPrice/52)
        completion(weekPriceCal, monthPriceCal, yearPriceCal)
    }
    
    func getLocalizedPrice(for amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        formatter.currencyCode = currencyCode
        return formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
    }
    
    func getPriceFormatted(for product: SKProduct) -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = product.priceLocale
        return formatter.string(from: product.price)
    }
    
}
