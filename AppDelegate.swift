//
//  AppDelegate.swift
//  AIOOTD
//
//  Created by beetonz Mac Mini on 21/01/25.
//

import UIKit
import IQKeyboardManagerSwift
import FirebaseCore
import SwiftyJSON
import FirebaseRemoteConfig
import GoogleMobileAds
import UserMessagingPlatform
import Siren
import FirebaseAnalytics
import FacebookCore
import RevenueCat

var myAlbumName: String = "AI OOTD - Outfits"

var networkAvailability: ReachabilityNetwork = ReachabilityNetwork.shared
var appOpenAd: GADAppOpenAd?
var globalAppOpenAdView : UIView?
var launchAdViewFlag = true
var isAdsShown: Bool = true
var isPremissionPopUpShowed: Bool = false
var openAdDidDismiss: Bool = true

var nativeAdInfo: [String: String]?
//Native Colors
var nativeBgColor:String = "171D12"
var headerTextColor:String = "FFFFFF"
var bodyTextColor:String = "FFFFFF"
var btnBgColor:String = "CBF849"
var btnTextColor:String = "000000"
var adTagBgColor:String = "CBF849"
var adTagTextColor:String = "000000"

//MARK: - App Already launch status check--------------[
var isAlreadyLaunched: Bool {
    get {
        return userDefaults.bool(forKey: "isAlreadyLaunched")
    }
    set{
        userDefaults.setValue(newValue, forKey: "isAlreadyLaunched")
    }
}

//MARK: - UMPFormStatus [Form Already Called or not status]--------------[
let userDefaultFormLoadKey = "userDefaultFormLoadKey"
var userDefaultFormLoad: Bool {
    get {
        return userDefaults.bool(forKey: "userDefaultFormLoadKey")
    }
    set{
        userDefaults.setValue(newValue, forKey: "userDefaultFormLoadKey")
    }
}

var featureSelect: FeatureSelection = .outfit

var videoTemplateJSON: JSON!
var nameOutfitArr: JSON!
var firebaseUrlsDatas: JSON!
var remoteConfig: RemoteConfig!
var keyChain : KeychainSwift = KeychainSwift()

//MARK: - Credit counter--------------[
var creditLeft : Int! {
    get {
        return keyChain.getInt("creditLeft")
    }
    set {
        keyChain.set(newValue!, forKey: "creditLeft")
    }
}
var freeCredits: Int = 00
var ootdVideoDecAmount: Int = 25
var fittingRoomDecAmount: Int = 10
var outfitDecAmount: Int = 10

var revenenueCatPurchaseID = "OutfitOfTheDayProAccess"
var revenueCatAPIKey = "appl_VTCTqYWurMPgySEKYklThWGUMJq"

var oneWeekIdenti = "gl.ootd.com.oneweek"
var oneYearIdenti = "gl.ootd.com.oneyear"
var firstIdenti = "gl.ootd.com.twohundredcredits"
var secondIdenti = "gl.ootd.com.fourhundredcredits"

var subscriptionInfo: String = ""
var weekCreditAmount: Int = 50
var yearCreditAmount: Int = 500
var twoHundCreditAmount: Int = 200
var fourHundCreditAmount: Int = 400

var getExpirationDate1 : Date! {
    get {
        return keyChain.getDate("getExpirationDate1")
    }
    set {
        keyChain.set(newValue!, forKey: "getExpirationDate1")
    }
}
var getExpirationDate2 : Date! {
    get {
        return keyChain.getDate("getExpirationDate2")
    }
    set {
        keyChain.set(newValue!, forKey: "getExpirationDate2")
    }
}

#if DEBUG
var bannerHomeViewController =  ""
var bannerOutfitViewController =  ""
var bannerOotdVideoViewController =  ""
var bannerFittingRoomViewController =  ""
var bannerCustomCropperViewController =  ""
var bannerFinalImagePreviewViewController =  ""
var bannerPreviewViewController =  ""
var bannerFinalVideoPreviewViewController =  ""
var bannerMyCreationViewController =  ""

var interstitialLaunchScreenVc = ""
var interstitialHomeViewController = ""

var nativeOnClickQuitionVc = ""
var nativeOnBoardingVc = ""

var rewardid = ""
var openAd = ""


//var bannerHomeViewController =  "ca-app-pub-3940256099942544/2934735716"
//var bannerOutfitViewController =  "ca-app-pub-3940256099942544/2934735716"
//var bannerOotdVideoViewController =  "ca-app-pub-3940256099942544/2934735716"
//var bannerFittingRoomViewController =  "ca-app-pub-3940256099942544/2934735716"
//var bannerCustomCropperViewController =  "ca-app-pub-3940256099942544/2934735716"
//var bannerFinalImagePreviewViewController =  "ca-app-pub-3940256099942544/2934735716"
//var bannerPreviewViewController =  "ca-app-pub-3940256099942544/2934735716"
//var bannerFinalVideoPreviewViewController =  "ca-app-pub-3940256099942544/2934735716"
//var bannerMyCreationViewController =  "ca-app-pub-3940256099942544/2934735716"
//
//var interstitialLaunchScreenVc = "ca-app-pub-3940256099942544/4411468910"
//var interstitialHomeViewController = "ca-app-pub-3940256099942544/4411468910"
//
//
//var nativeOnClickQuitionVc = "ca-app-pub-3940256099942544/3986624511"
//var nativeOnBoardingVc = "ca-app-pub-3940256099942544/3986624511"
//
//var rewardid = "ca-app-pub-3940256099942544/1712485313"
//var openAd = "ca-app-pub-3940256099942544/5575463023"

#else
var bannerHomeViewController =  ""
var bannerOutfitViewController =  ""
var bannerOotdVideoViewController =  ""
var bannerFittingRoomViewController =  ""
var bannerCustomCropperViewController =  ""
var bannerFinalImagePreviewViewController =  ""
var bannerPreviewViewController =  ""
var bannerFinalVideoPreviewViewController =  ""
var bannerMyCreationViewController =  ""

var interstitialLaunchScreenVc = ""
var interstitialHomeViewController = ""

var nativeOnClickQuitionVc = ""
var nativeOnBoardingVc = ""

var rewardid = ""
var openAd = ""


#endif

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        //MARK: - check app version
        if previousAppVersion == nil {
            let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
            previousAppVersion = version
            print("----------------\(version!)----------------")
        }
//        
        Plistdata = decordPropertyList()
//        #if DEBUG
//            keyChain.clear()
//        #endif
        
        if saveUniqueIdentifierToKeychain() == true {
            creditLeft = freeCredits
        }
        creditLeft = 1000
        networkAvailability.startNetworkReachabilityObserver()
        Purchases.configure(withAPIKey: revenueCatAPIKey)
        Purchases.shared.getCustomerInfo { (purchaserInfo, error) in
            if purchaserInfo != nil {
                if "\(purchaserInfo!.activeSubscriptions)".contains(oneWeekIdenti) {
                    print("Expiration of current plan - \(purchaserInfo!.expirationDate(forProductIdentifier: oneWeekIdenti)!)")
                    if getExpirationDate1 != nil && getExpirationDate2 != nil {
                        getExpirationDate2 = purchaserInfo!.expirationDate(forProductIdentifier: oneWeekIdenti)
                        if getExpirationDate2 > getExpirationDate1 {
                            creditLeft += weekCreditAmount
                            getExpirationDate1 = getExpirationDate2
                        }
                    } else {
                        print("No Purchased Found Yet")
                    }
                } else if "\(purchaserInfo!.activeSubscriptions)".contains(oneYearIdenti) {
                    print("Expiration of current plan - \(purchaserInfo!.expirationDate(forProductIdentifier: oneYearIdenti)!)")
                    if getExpirationDate1 != nil && getExpirationDate2 != nil {
                        getExpirationDate2 = purchaserInfo!.expirationDate(forProductIdentifier: oneYearIdenti)
                        if getExpirationDate2 > getExpirationDate1 {
                            creditLeft += yearCreditAmount
                            getExpirationDate1 = getExpirationDate2
                        }
                    } else {
                        print("No Purchased Found Yet")
                    }
                }
                
                if purchaserInfo?.entitlements.all[revenenueCatPurchaseID]?.isActive == true {
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
                }
            }
        }
        
        FirebaseApp.configure()
        remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings
        
        remoteConfig.fetch { status, error in
            if status == .success {
                print("Config fetched!")
                remoteConfig.activate { changed, error in
                    
                    let jsonValueFire = remoteConfig.configValue(forKey: "AIOOTDCredentials", source: .remote).dataValue
                    firebaseUrlsDatas = try! JSON(data: jsonValueFire)
                    print(firebaseUrlsDatas!)
                    
                    let jsonFromFire = remoteConfig.configValue(forKey: "AIOOTDOutfitPromps", source: .remote).dataValue
                    nameOutfitArr = try! JSON(data: jsonFromFire)
                    print(nameOutfitArr!)
                    
                    let jsonVideoFromFire = remoteConfig.configValue(forKey: "AIOOTDVideoTemplates", source: .remote).dataValue
                    videoTemplateJSON = try! JSON(data: jsonVideoFromFire)
                    print(videoTemplateJSON!)
                    
                    
                    let fireFBDatas = remoteConfig.configValue(forKey: "AIOOTDFBDatas", source: .remote).dataValue
                    let fireFBJson = try! JSON(data: fireFBDatas)
                    Settings.shared.appID = fireFBJson["FBAppID"].stringValue
                    Settings.shared.clientToken = fireFBJson["FBClientToken"].stringValue
                    Settings.shared.isAutoLogAppEventsEnabled = true
                    
                    print("-\(Settings.shared.appID!)")
                    print("-\(Settings.shared.clientToken!)")
                    
                    DispatchQueue.main.async {
                        ApplicationDelegate.shared.application( application, didFinishLaunchingWithOptions: launchOptions)
                        NotificationCenter.default.post(name: .configFetch, object: nil)
                    }
                    
                }
            } else {
                print("Config not fetched")
                print("Error: \(error?.localizedDescription ?? "No error available.")")
            }
        }
        
        
        IQKeyboardManager.shared.enable = true
        StoreReviewHelper.incrementAppOpenedCount()
        UNUserNotificationCenter.current().delegate = self
        UIApplication.shared.applicationIconBadgeNumber = 0
        networkAvailability.startNetworkReachabilityObserver()
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        networkAvailability.stopNetworkReachabilityObserver()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        networkAvailability.stopNetworkReachabilityObserver()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        networkAvailability.startNetworkReachabilityObserver()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        appUpdatePopUp()
        networkAvailability.startNetworkReachabilityObserver()
        NotificationCenter.default.post(name: Notification.Name("networkCheckNotification"), object: nil)
        if userDefaultFormLoad {
            if creditLeft <= 5 && openAdDidDismiss{
                if !isPremissionPopUpShowed {
                    tryToPresentAd()
                }
                isPremissionPopUpShowed = false
            }
        }
    }
    
    
    func tryToPresentAd() {
        if let ad = appOpenAd {
            let rootController = window!.rootViewController
            ad.present(fromRootViewController: rootController!)
        } else {
            requestAppOpenAd()
        }
    }
    
    func requestAppOpenAd() {
        appOpenAd = nil
        GADAppOpenAd.load(withAdUnitID: openAd, request: GADRequest(), completionHandler: { ad, error in
            if let error = error {
                print("Failed to load app open ad: \(error)")
                return
            }
            appOpenAd = ad
            appOpenAd?.fullScreenContentDelegate = self
        })
    }
    
}

//MARK: -------------GADFullScreenContentDelegate----------------------------
extension AppDelegate: GADFullScreenContentDelegate{
    func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
        print("ad did record impression")
        openAdDidDismiss = false
        globalAppOpenAdView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        globalAppOpenAdView?.backgroundColor = .black
        window!.rootViewController?.view.addSubview(globalAppOpenAdView!)
    }
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        requestAppOpenAd()
    }
    
    func adWillDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("adWillDismissFullScreenContent")
        globalAppOpenAdView?.removeFromSuperview()
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("adDidDismissFullScreenContent")
        openAdDidDismiss = true
        requestAppOpenAd()
    }
}


//MARK: -------------previousAppVersion--------this used for App version status------[
var previousAppVersion: String? {
    get {
        return userDefaults.string(forKey: "previousAppVersionKey")
    }
    set {
        userDefaults.setValue(newValue, forKey: "previousAppVersionKey")
    }
}

//MARK: --------------appUpdatePopUp------ [pod 'Siren'] - [this pod used for new version of App is available]---------[
private extension AppDelegate {
    func appUpdatePopUp() {
        let siren = Siren.shared
        siren.rulesManager = RulesManager(globalRules: Rules(promptFrequency: .immediately, forAlertType: .force), showAlertAfterCurrentVersionHasBeenReleasedForDays: 0)
        
        
        siren.presentationManager = PresentationManager(alertTintColor: nil, appName: Bundle.appName(), alertTitle: "Update Available", alertMessage: "A new version of %@ is available. Please update to version %@ now.", forceLanguageLocalization: .english)
        siren.wail(performCheck: .onDemand) { result in
            switch result {
            case .success(let updateResults):
                print(updateResults)
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

//MARK: --------------FB Setup--------------------for app marketing videos user click counting show perpose------[
func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    ApplicationDelegate.shared.application(app, open: url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplication.OpenURLOptionsKey.annotation])
}

extension AppDelegate {
    func isFirstTimeLaunching() -> Bool {
        if UserDefaults.standard.bool(forKey: "isFirstTime"){
            print("App Already Launched......")
            return true
        } else {
            UserDefaults.standard.set(true, forKey: "isFirstTime")
            print("App First Time Launched......")
            return false
        }
    }


    func generateUniqueIdentifier() -> String {
        if let uuid = UIDevice.current.identifierForVendor?.uuidString {
            return uuid
        } else {
            return UUID().uuidString
        }
    }

    func saveUniqueIdentifierToKeychain() -> Bool {
        
        if let storedIdentifier = keyChain.get("uniqueIdentifier") {
            print("Unique Identifier already exists: \(storedIdentifier)")
            return false
        } else {
            let newIdentifier = generateUniqueIdentifier()
            keyChain.set(newIdentifier, forKey: "uniqueIdentifier")
            print("New Unique Identifier saved: \(newIdentifier)")
            return true
        }
    }
}
