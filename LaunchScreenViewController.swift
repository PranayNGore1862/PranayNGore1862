//
//  LaunchScreenViewController.swift
//  AIOOTD
//
//  Created by beetonz Mac Mini on 21/01/25.
//

import UIKit
import GoogleMobileAds
import UserMessagingPlatform
import FirebaseRemoteConfig
import AppTrackingTransparency
import SwiftyJSON
import RevenueCat

var launchNativeAd: GADNativeAd?
var launchOnQuestionAd: GADNativeAd?

var adLoaderForHome: GADAdLoader?
var adLoaderForOnQuestion: GADAdLoader?

class LaunchScreenViewController: UIViewController {
    
    var networkCheckTimer: Timer!
    var launchAdViewFlag = true
    var interstitial:GADInterstitialAd!
    var adLoader: GADAdLoader!
    @IBOutlet var adLbl: UILabel!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    var isRootDone: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if creditLeft > freeCredits {
            adLbl.isHidden = true
        }
        getDataFromServer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.removeObserver(self, name: .applicationDidBecomeActiveTriggered, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActiveTriggered), name: .applicationDidBecomeActiveTriggered, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(configFetchTriggered), name: .configFetch, object: nil)
    }
    
    
//    func getDataFromServer(){
//        APIHandler.shared.callAPI(baseUrl: Plistdata["ServerLink"] as! String, password: Plistdata["Password"] as! String, package: Plistdata["MainPackage"] as! String) { result in
//            switch result {
//            case .success(let json):
//                let data = JSON(json!)
//                var posts = data["data"]["posts"].arrayValue
//                print(posts)
//                 
//                for item in data["data"]["posts"].arrayValue {
//                     if let fileName = item["file_name"].string {
//                         // Extracting the package name by removing the base URL
//                         if let lastIndex = fileName.range(of: "/hekrbmyeyvxh/")?.upperBound {
//                             let packageName = String(fileName[lastIndex...])
//                             print(packageName)
//                         }
//                     }
//                 }
//            
//            case .failure(let error):
//                // Handle failure
//                print("Request failed with error: \(error)")
//            }
//        }
//    }
    
    func getDataFromServer() {
        APIHandler.shared.callAPI(
            baseUrl: Plistdata["ServerLink"] as! String,
            password: Plistdata["Password"] as! String,
            package: Plistdata["MainPackage"] as! String
        ) { result in
            switch result {
            case .success(let json):
                let data = JSON(json!)
                var posts = data["data"]["posts"].arrayValue
                print(posts)
                
                for item in posts {
                    if let fileName = item["file_name"].string {
                        // Extract package name
                        if let lastIndex = fileName.range(of: "/hekrbmyeyvxh/")?.upperBound {
                            let packageName = String(fileName[lastIndex...])
                            print(packageName)
                            
                            // Check if the package name is "AI_OOTD_Videos" and append URL
                            if packageName.contains("AI_OOTD_Videos"), let videoURL = URL(string: fileName + "/") {
                                // Array to store extracted video URLs
                                OOTD_VideosURLs = videoURL
                            }
                        }
                    }
                }
                
                print("Filtered videoURLs:", OOTD_VideosURLs) // Final extracted video URL array
                
            case .failure(let error):
                print("Request failed with error: \(error)")
            }
        }
    }

    @objc func applicationDidBecomeActiveTriggered(_ notification: Notification) {
        if networkCheckTimer != nil {
            networkCheckTimer.invalidate()
            networkCheckTimer = nil
        }
        networkCheckTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(checkNetworkAvailability), userInfo: nil, repeats: true)
    }
    
    @objc func checkNetworkAvailability(_ timer: Timer) {
        if networkAvailability.isNetworkAvailable {
            print("Network active")
            timer.invalidate()
            networkCheckTimer = nil
        } else {
            print("Still Checking Network Availability")
        }
    }
    
    @objc func configFetchTriggered(_ notification: Notification) {
        
//#if DEBUG
//        if launchAdViewFlag {
//            if creditLeft <= 10 {
//                if isAdsShown {
//                    if !isOnBoardAlreadyDisplay {
//                        loadNativeQuestion(withAdId: nativeOnClickQuitionVc)
//                    }
////                   loadNativeHomeScreen(withAdId: nativeHomeViewController)
//                }
//                self.loadInterstitialAds()
//            }
//            if networkAvailability.isNetworkAvailable {
//                remoteConfig.fetch { [self] (status, error) -> Void in
//                    switch status {
//                    case .success:
//                        remoteConfig.activate { changed, error in
//                            nativeAdInfo = remoteConfig.configValue(forKey: "AIOOTDNativeDatas", source: .remote).jsonValue as? [String : String]
//                        }
//                    case .failure, .noFetchYet, .throttled:
//                        print(error?.localizedDescription ?? "")
//                    default: break
//                    }
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [self] in
//                        rootDecide()
//                    }
//                }
//            } else {
//                self.showAlertBox(message: "Internet not Available")
//            }
//        }
//#else
        if creditLeft <= freeCredits {
            if launchAdViewFlag {
                UMPSetup { [self] isUMPSetupDone, error in
                    if error == nil && isUMPSetupDone == true {
                        if networkAvailability.isNetworkAvailable {
                            remoteConfig.fetch { (status, error) -> Void in
                                switch status {
                                case .success:
                                    remoteConfig.activate {changed, error in
                                        let adIdsData = remoteConfig.configValue(forKey: "AIOOTDAdsIDs", source: .remote).jsonValue as? [String : Any]
                                        bannerHomeViewController = adIdsData?["bannerHomeViewController"] as! String
                                        bannerOutfitViewController = adIdsData?["bannerOutfitViewController"] as! String
                                        bannerOotdVideoViewController = adIdsData?["bannerOotdVideoViewController"] as! String
                                        bannerFittingRoomViewController = adIdsData?["bannerFittingRoomViewController"] as! String
                                        bannerCustomCropperViewController = adIdsData?["bannerCustomCropperViewController"] as! String
                                        bannerFinalImagePreviewViewController = adIdsData?["bannerFinalImagePreviewViewController"] as! String
                                        bannerPreviewViewController = adIdsData?["bannerPreviewViewController"] as! String
                                        bannerFinalVideoPreviewViewController = adIdsData?["bannerFinalVideoPreviewViewController"] as! String
                                        bannerMyCreationViewController = adIdsData?["bannerMyCreationViewController"] as! String
                                        
                                        interstitialLaunchScreenVc = adIdsData?["interstitialLaunchScreenVc"] as! String
                                        interstitialHomeViewController = adIdsData?["interstitialHomeViewController"] as! String
                                        
                                        nativeOnClickQuitionVc = adIdsData?["nativeOnClickQuitionVc"] as! String
                                        nativeOnBoardingVc = adIdsData?["nativeOnBoardingVc"] as! String
                                        
                                        openAd = adIdsData?["openAd"] as! String
                                        isAdsShown = adIdsData?["isAdsShown"] as! Bool
                                        adsShowCounter = adIdsData?["adsShowCounter"] as! Int
                                        nativeAdInfo = remoteConfig.configValue(forKey: "AIOOTDNativeDatas").jsonValue as? [String : String]
                                        
                                        if isAdsShown {
                                            if !isAlreadyLaunched {
                                                loadNativeQuestion(withAdId: nativeOnClickQuitionVc)
                                            }
//                                                            loadNativeHomeScreen(withAdId: nativeHomeViewController)
                                        }
                                        
                                        self.loadInterstitialAds()
                                    }
                                case .failure, .noFetchYet, .throttled:
                                    DispatchQueue.main.async { [self] in
                                        rootDecide()
                                    }
                                default: break
                                }
                            }
                        } else {
                            if isAdsShown {
                                if !isAlreadyLaunched {
                                    loadNativeQuestion(withAdId: nativeOnClickQuitionVc)
                                }
//                                loadNativeHomeScreen(withAdId: nativeHomeViewController)
                            }
                            self.loadInterstitialAds()
                            self.showAlertBox(message: "Internet not Available")
                        }
                    }else {
                        if #available(iOS 14, *) {
                            ATTrackingManager.requestTrackingAuthorization { status in
                                DispatchQueue.main.async { [self] in
                                    switch status {
                                    case .authorized, .denied, .restricted:
                                        if networkAvailability.isNetworkAvailable {
                                            remoteConfig.fetch { (status, error) -> Void in
                                                switch status {
                                                case .success:
                                                    remoteConfig.activate {changed, error in
                                                        let adIdsData = remoteConfig.configValue(forKey: "AIOOTDAdsIDs", source: .remote).jsonValue as? [String : Any]
                                                        bannerHomeViewController = adIdsData?["bannerHomeViewController"] as! String
                                                        bannerOutfitViewController = adIdsData?["bannerOutfitViewController"] as! String
                                                        bannerOotdVideoViewController = adIdsData?["bannerOotdVideoViewController"] as! String
                                                        bannerFittingRoomViewController = adIdsData?["bannerFittingRoomViewController"] as! String
                                                        bannerCustomCropperViewController = adIdsData?["bannerCustomCropperViewController"] as! String
                                                        bannerFinalImagePreviewViewController = adIdsData?["bannerFinalImagePreviewViewController"] as! String
                                                        bannerPreviewViewController = adIdsData?["bannerPreviewViewController"] as! String
                                                        bannerFinalVideoPreviewViewController = adIdsData?["bannerFinalVideoPreviewViewController"] as! String
                                                        bannerMyCreationViewController = adIdsData?["bannerMyCreationViewController"] as! String
                                                        
                                                        interstitialLaunchScreenVc = adIdsData?["interstitialLaunchScreenVc"] as! String
                                                        interstitialHomeViewController = adIdsData?["interstitialHomeViewController"] as! String
                                                        
                                                        nativeOnClickQuitionVc = adIdsData?["nativeOnClickQuitionVc"] as! String
                                                        nativeOnBoardingVc = adIdsData?["nativeOnBoardingVc"] as! String
                                                        
                                                        openAd = adIdsData?["openAd"] as! String
                                                        isAdsShown = adIdsData?["isAdsShown"] as! Bool
                                                        adsShowCounter = adIdsData?["adsShowCounter"] as! Int
                                                        nativeAdInfo = remoteConfig.configValue(forKey: "AIOOTDNativeDatas").jsonValue as? [String : String]
                                                        
                                                        if isAdsShown {
                                                            if !isAlreadyLaunched {
                                                                loadNativeQuestion(withAdId: nativeOnClickQuitionVc)
                                                            }
//                                                            loadNativeHomeScreen(withAdId: nativeHomeViewController)
                                                        }
                                                        
                                                        self.loadInterstitialAds()
                                                    }
                                                case .failure, .noFetchYet, .throttled:
                                                    DispatchQueue.main.async { [self] in
                                                        rootDecide()
                                                    }
                                                default: break
                                                }
                                            }
                                        }else {
                                            if isAdsShown {
                                                if !isAlreadyLaunched {
                                                    loadNativeQuestion(withAdId: nativeOnClickQuitionVc)
                                                }
//                                               loadNativeHomeScreen(withAdId: nativeHomeViewController)
                                            }
                                            self.loadInterstitialAds()
                                            self.showAlertBox(message: "Internet not Available")
                                        }
                                        
                                    case .notDetermined :
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: { [self] in
                                            rootDecide()
                                        })
                                    @unknown default:
                                        break
                                    }
                                }
                            }
                        }
                    }
                }
            }
        } else {
            isAdsShown = false
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
            rootDecide()
        }
        
//#endif
        
    }
    
    func rootDecide(){
        if !isRootDone {
            isRootDone = true
            if isAlreadyLaunched {
                let homeVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
                navigationController?.pushViewController(homeVC, animated: true)
            } else {
                let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "QuitionVc") as! QuitionVc
                self.navigationController?.pushViewController(controller, animated: false)
            }
        }
    }
    
    
    
    func UMPSetup(completion: (@escaping( _ isUMPSetupDone: Bool?, _ error: Error?) -> Void)) {
        let parameters = UMPRequestParameters()
        
        //        let debugSettings = UMPDebugSettings()
        //        debugSettings.testDeviceIdentifiers = ["B37E7246-B3D9-4682-B503-750BE36A82F3"]
        //        debugSettings.geography = .EEA
        //        parameters.debugSettings = debugSettings
        
        parameters.tagForUnderAgeOfConsent = false
        UMPConsentInformation.sharedInstance.requestConsentInfoUpdate(with: parameters) { requestConsentError in
            if requestConsentError != nil {
                // Consent gathering failed.
                print("Error: \(requestConsentError!.localizedDescription)")
                completion(nil, requestConsentError)
            }else {
                
                if UMPConsentInformation.sharedInstance.privacyOptionsRequirementStatus != .required {
                    completion(false, nil)
                } else {
                    let formStatus = UMPConsentInformation.sharedInstance.formStatus
                    if formStatus == UMPFormStatus.available {
                        self.loadForm(completion: completion)
                    } else if formStatus == UMPFormStatus.unavailable {
                        
                        print("---------Form Already Called----------")
                        UserDefaults.standard.set(true, forKey: userDefaultFormLoadKey)
                        completion(true, nil)
                    } else if formStatus == UMPFormStatus.unknown {
                        self.loadForm(completion: completion)
                    }
                }
            }
            
        }
    }
    
    
    func loadForm(completion: (@escaping(_ isUMPSetupDone: Bool?, _ error: Error?) -> Void)) {
        UMPConsentForm.loadAndPresentIfRequired(from: self) { error in
            if error != nil{
                // Consent gathering failed.
                completion(nil, error)
                print("Error: \(error!.localizedDescription)")
            }else {
                
                print("---------Form Called---------")
                UserDefaults.standard.set(true, forKey: userDefaultFormLoadKey)
                completion(true, nil)
            }
            
        }
    }
    
    func loadNativeQuestion(withAdId: String) {
        adLoader = GADAdLoader(
            adUnitID: withAdId, rootViewController: self,
            adTypes: [.native], options: nil)
        adLoader.delegate = self
        adLoaderForOnQuestion = adLoader
        adLoader.load(GADRequest())
    }
    
    func loadNativeHomeScreen(withAdId: String) {
        adLoader = GADAdLoader(
            adUnitID: withAdId, rootViewController: self,
            adTypes: [.native], options: nil)
        adLoader.delegate = self
        adLoaderForHome = adLoader
        adLoader.load(GADRequest())
    }
}

extension LaunchScreenViewController : GADFullScreenContentDelegate {
    
    func loadInterstitialAds() {
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID: interstitialLaunchScreenVc,
                               request: request,
                               completionHandler: {[self] ad, error in
            if let error = error {
                print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                rootDecide()
                return
            }
            interstitial = ad
            interstitial?.fullScreenContentDelegate = self
            activityIndicator.stopAnimating()
            if interstitial != nil {
                launchAdViewFlag = false
                self.interstitial?.present(fromRootViewController: self)
            }
        })
    }
    
    //    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
    //        interstitial = nil
    //        loadInterstitialAds()
    //    }
    
    func adWillDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        rootDecide()
    }
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        rootDecide()
    }
}

extension LaunchScreenViewController : GADNativeAdLoaderDelegate {
    
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
        if adLoader == adLoaderForHome {
            launchNativeAd = nativeAd
        } else if adLoader == adLoaderForOnQuestion {
            launchOnQuestionAd = nativeAd
        }
    }
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        
        return
    }
}

extension Notification.Name {
    static let configFetch: Notification.Name = Notification.Name("configFetch")
}





