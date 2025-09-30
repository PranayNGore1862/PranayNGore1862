//
//  HomeViewController.swift
//  AIOOTD
//
//  Created by beetonz Mac Mini on 21/01/25.
//

import UIKit
import Photos
import QCropper
import UserNotifications
import StoreKit //used for rating review
import GoogleMobileAds

class HomeViewController: UIViewController {

    @IBOutlet var creditLbl: UILabel!
    
    @IBOutlet var OOTDVideo: OOTDMp4!
    
    @IBOutlet var btnOOTDVideos: UIButton!
    @IBOutlet  var SetHeight: NSLayoutConstraint!
    @IBOutlet var bottomConstraint:NSLayoutConstraint!
    @IBOutlet var bottomSuperView: UIView!
    var bannerView:GADBannerView!
    
    var status = PHPhotoLibrary.authorizationStatus()
    let gradientColors: [UIColor] = [
        .clear,
        .dotApp,
        .clear
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        btnOOTDVideos.addShine()
//        btnOOTDVideos.addShimmer()
//        btnOOTDVideos.addLineShimmerEffect()
      
      
        if status == .notDetermined{
            PHPhotoLibrary.requestAuthorization(){ [self] response in
                if response == .authorized {
                    status = .authorized
                }
            }
        }
        SetTopBarHeight(constraint: SetHeight)
        
        if creditLeft <= freeCredits {
            bottomConstraint.constant = 75
            loadBannerAd()
            loadInterstitialAds()
        } else {
            bottomConstraint.constant = 0
        }
        
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        if previousAppVersion != currentVersion {
            //Show new Screen and set current Version
            previousAppVersion = currentVersion
        } else {
            if isAlreadyLaunched {
                checkAndAskForReview()
            }
        }
      
        isAlreadyLaunched = true
        NotificationCenter.default.addObserver(self, selector: #selector(premiumDone), name: .purchasedDoneCalled, object: nil)
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                self.requestAuthorization()
            case .authorized, .provisional:
                self.sendNotification()
            default:
                break // Do nothing
            }
        }
        //Back navigate delegate
      self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        //side menu delegate
      self.navigationController?.delegate = self
    }
    
   
    
    @objc func premiumDone(_ notification: Notification){
        bottomConstraint.constant = 0
        bannerView = nil
        clickInterstitial = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){ [self] in
            btnOOTDVideos.flash()
            btnOOTDVideos.layoutIfNeeded()
                    self.view.layoutIfNeeded()
                }
        OOTDVideo.playVideo()
        creditLbl.text = "\(creditLeft!)"
    }
    
    @IBAction func creditBtnTapped(_ sender: UIButton) {
        print("Pro Screen")
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProViewController") as! ProViewController
        controller.modalPresentationStyle = .fullScreen
        controller.premiumProtocol = self
        self.present(controller, animated: true, completion: nil)
    }
    
    
    @IBAction func moresetting(_ sender: Any) {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OptionsViewController") as! OptionsViewController
        navigationController?.pushViewController(controller, animated: true)
    }
    
    
    @IBAction func ootdVideoBtnTapped(_ sender: UIButton) {
        if status == .authorized {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OotdVideoViewController") as! OotdVideoViewController
            presentInterstitialAd(viewController: self)
            navigationController?.pushViewController(vc, animated: true)
        } else {
            alertForNoPhotoLibraryPermission()
        }
    }
    
    
    @IBAction func outfitBtnTapped(_ sender: UIButton) {
        if status == .authorized {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OutfitViewController") as! OutfitViewController
            presentInterstitialAd(viewController: self)
            navigationController?.pushViewController(vc, animated: true)
        } else {
            alertForNoPhotoLibraryPermission()
        }
    }
    
    @IBAction func fittingRoomBtnTapped(_ sender: UIButton) {
        if status == .authorized {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FittingRoomViewController") as! FittingRoomViewController
            presentInterstitialAd(viewController: self)
            navigationController?.pushViewController(vc, animated: true)
        } else {
            alertForNoPhotoLibraryPermission()
        }
    }
    
    
}
//MARK: purchasedDoneCall
extension Notification.Name {
    static let purchasedDoneCalled: Notification.Name = Notification.Name("purchasedDoneCalled")
}

//MARK:[push notification] -requestAuthorization/sendNotification/checkAndAskForReview
extension HomeViewController{
    func sendNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Outfit Of The Day"
        content.body = "Trending outfit style video maker "
        content.sound = UNNotificationSound.default
        
        // 3
        var dateComponents = DateComponents()
        dateComponents.hour = 10
        dateComponents.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(identifier: "testNotification", content: content, trigger: trigger)
        
        // 4
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    func checkAndAskForReview() {
        if !StoreReviewHelper.checkforAppOpenCount() {
            SKStoreReviewController.requestReview()
        } else {
            if creditLeft <= freeCredits {
                let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProViewController") as! ProViewController
                controller.premiumProtocol = self
                controller.modalPresentationStyle = .fullScreen
                self.present(controller, animated: true, completion: nil)
            }
        }
    }
    
    func requestAuthorization() {
        isPremissionPopUpShowed = true
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) {
            (granted, error) in
            if granted {
                print("Yes")
            } else {
                print("No")
            }
        }
    }
}


//MARK: -side menu[moreOption btn]
extension HomeViewController:UINavigationControllerDelegate  {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch operation {
        case .push:
            if toVC is OptionsViewController {
                return LeftToRightTransition()
            }
            return nil
        case .pop:
            if fromVC is OptionsViewController {
                return RightToLeftTransition()
            }
            return nil
        default: return nil
        }
    }
}

//MARK: -back gesture
extension HomeViewController:UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if navigationController?.viewControllers.last is HomeViewController {
            return false
        } else if navigationController?.viewControllers.last is OptionsViewController {
            return false
        } else if navigationController?.viewControllers.last is FinalImagePreviewViewController {
            return false
        }else if navigationController?.viewControllers.last is FinalVideoPreviewViewController {
            return false
        } else {
            return true
        }
    }
    
}

    
extension HomeViewController : PremiumPurchased {
    
    func premiumPurchased() {
        openAd = ""
        bannerHomeViewController =  ""
        bannerOutfitViewController =  ""
        bannerOotdVideoViewController =  ""
        bannerFittingRoomViewController =  ""
        bannerCustomCropperViewController =  ""
        bannerFinalImagePreviewViewController =  ""
        bannerPreviewViewController =  ""
        bannerFinalVideoPreviewViewController =  ""
        bannerMyCreationViewController =  ""
        interstitialLaunchScreenVc = ""
        interstitialHomeViewController = ""
        nativeOnClickQuitionVc = ""
        nativeOnBoardingVc = ""
        NotificationCenter.default.post(name: .purchasedDoneCalled, object: nil)
        popToViewController(HomeViewController.self)
    }
    
}

extension HomeViewController: GADBannerViewDelegate{
    
    func loadBannerAd() {
        let adaptiveSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(self.view.frame.size.width)
        bannerView = GADBannerView(adSize: adaptiveSize)
        bannerView.adUnitID = bannerHomeViewController
        bannerView.load(GADRequest())
        bannerView.delegate = self
    }
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        bannerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        bannerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("bannerViewDidReceiveAd")
        addBannerViewToView(bannerView)
        bottomSuperView.backgroundColor = .black
        
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        print("bannerView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
}


import UIKit

extension UIButton {
    
    func flash() {
        // Take a snapshot of the button and render as a template
        let snapshot = self.snapshot?.withRenderingMode(.alwaysTemplate)
        let imageView = UIImageView(image: snapshot)
        // Add image view and render close to white
        imageView.tintColor = UIColor(white: 0.9, alpha: 1.0)
        guard let image = imageView.snapshot else { return }
        
        let width = image.size.width
        let height = image.size.height
        
        // Create a CALayer and add light content to it
        let shineLayer = CALayer()
        shineLayer.contents = image.cgImage
        shineLayer.frame = bounds
        
        // Create a CAGradientLayer that will act as a mask (clear = not shown, opaque = rendered)
        // Adjust gradient to increase width and angle of highlight
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.clear.cgColor,
                                UIColor.clear.cgColor,
                                UIColor.black.cgColor,
                                UIColor.clear.cgColor,
                                UIColor.clear.cgColor]
        gradientLayer.locations = [0.0, 0.35, 0.45, 0.65, 0.0]
        // Adjust gradient start and end points to move from top-left to bottom-right
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0) // Diagonal movement
        
        gradientLayer.frame = CGRect(x: -width, y: -height, width: width, height: height)
        
        // Create a CAAnimation that will move the mask from top-left to bottom-right across the button
        let animation = CABasicAnimation(keyPath: "position")
        animation.byValue = CGPoint(x: width * 2, y: height * 2) // Diagonal movement
        animation.duration = 1.5 // How long it takes for glare to move across the button
        animation.repeatCount = Float.greatestFiniteMagnitude // Repeat forever
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        layer.addSublayer(shineLayer)
        shineLayer.mask = gradientLayer
        
        // Add the animation to the gradient layer
        gradientLayer.add(animation, forKey: "shine")
        self.layoutIfNeeded()
    }
    
    func stopFlash() {
        // Search all sublayer masks for "shine" animation and remove it
        layer.sublayers?.forEach {
            $0.mask?.removeAnimation(forKey: "shine")
        }
    }
}

extension UIView {
    // Helper to snapshot a view
    var snapshot: UIImage? {
        let renderer = UIGraphicsImageRenderer(size: bounds.size)
        
        let image = renderer.image { context in
            layer.render(in: context.cgContext)
        }
        return image
    }
}
