//
//  OnBoardingVc.swift
//  AIOOTD
//
//  Created by Gayatri Sonani on 13/02/25.
//

import UIKit
import GoogleMobileAds
import SwiftyGif
import RevenueCat

class OnBoardingVc: UIViewController {
 
    @IBOutlet var swipeGif: UIImageView!
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet var intro1Video: Intro1!
    @IBOutlet var nativeFullWidth: NSLayoutConstraint!
    @IBOutlet var nativeFullAdPlaceholder: UIView!
    var nativeFullAdView: GADNativeAdView!
    var fullAdLoader: GADAdLoader!
    
    var nativeAdView: GADNativeAdView!
    
    var totalPage = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        intro1Video.playVideo()
        scrollView.isPagingEnabled = true
        swipeGif.setGifImage(try! UIImage(gifName: "swap_gif"))
        
        if creditLeft <= freeCredits{
            if isAdsShown {
                totalPage = 4
                self.fullScreenNativeAdView()
            } else {
                totalPage = 3
                nativeFullAdPlaceholder.isHidden = true
                nativeFullWidth = changeMultiplier(nativeFullWidth, multiplier: 0.0001)
            }
        } else {
            totalPage = 3
            nativeFullAdPlaceholder.isHidden = true
            nativeFullWidth = changeMultiplier(nativeFullWidth, multiplier: 0.0001)
        }
       
        scrollView.delegate = self
 
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
   
    @IBAction func nextBtnTap(_ sender: Any) {
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        let currentPage = Int(scrollView.contentOffset.x / scrollView.frame.width)
        
        if currentPage < totalPage - 1 {
            let nextOffsetX = scrollView.frame.width * CGFloat(currentPage + 1)
            scrollView.setContentOffset(CGPoint(x: nextOffsetX, y: 0), animated: true)
            handlePageLogic(for: currentPage + 1)
        } else {
            
            let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProViewController") as! ProViewController
            controller.premiumProtocol = self
            controller.isNavigatedFromOnboarding = true
            navigationController?.pushViewController(controller, animated: true)
        }
        
        self.view.isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.view.isUserInteractionEnabled = true
        }
    }
    
    
    func handlePageLogic(for currentPage: Int) {
        if creditLeft > freeCredits {
            nativeFullAdPlaceholder.isHidden = true
            nativeFullWidth = changeMultiplier(nativeFullWidth, multiplier: 0.0001)
        } else {
            if isAdsShown {
                if currentPage < totalPage - 1 {
                    if currentPage == 0 {
                        print("Logic for page 0")
                    } else if currentPage == 1 {
                        print("Logic for page 1")
                    } else if currentPage == 2 {
                        print("Logic for page 2")
                    } else if currentPage == 3 {
                        print("Logic for page 3")
                    } else if currentPage == totalPage - 1 {
                         print("Logic for the last page")
                    }
                } else if currentPage == totalPage - 1 {
                    if currentPage == 0 {
                       print("Logic for page 0")
                    } else if currentPage == 1 {
                         print("Logic for page 1")
                    } else if currentPage == 2 {
                        print("Logic for page 2")
                    } else if currentPage == totalPage - 1 {
                         print("Logic for the last page")
                    }
                }
            }
        }
    }
}

extension OnBoardingVc : UIScrollViewDelegate{
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentPage = Int(scrollView.contentOffset.x / scrollView.frame.width)
        handlePageLogic(for: currentPage)
    }
    
//    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
//        let currentPage = Int(scrollView.contentOffset.x / scrollView.frame.width)
//        handlePageLogic(for: currentPage)
//    }
}


// MARK: Full Screen Native
extension OnBoardingVc : GADAdLoaderDelegate, GADNativeAdLoaderDelegate, GADNativeAdDelegate, GADVideoControllerDelegate {
    
    func fullScreenNativeAdView() {
        guard
            let nibObjects = Bundle.main.loadNibNamed("FullNativeAdsView", owner: nil, options: nil),
            let adView = nibObjects.first as? GADNativeAdView
        else {
            assert(false, "Could not load nib file for adView")
            return
        }
        nativeFullAdView = adView
        nativeFullAdPlaceholder.addSubview(nativeFullAdView)
        nativeFullAdView.frame = nativeFullAdPlaceholder.bounds
        
        addShimming(nativeAdView: adView)
        loadFullScreenNativeAds(withAdId: nativeOnBoardingVc)
    }
    
    func imageOfStars(from starRating: NSDecimalNumber?) -> UIImage? {
        guard let rating = starRating?.doubleValue else {
            return nil
        }
        if rating >= 5 {
            return UIImage(named: "stars_5")
        } else if rating >= 4.5 {
            return UIImage(named: "stars_4_5")
        } else if rating >= 4 {
            return UIImage(named: "stars_4")
        } else if rating >= 3.5 {
            return UIImage(named: "stars_3_5")
        } else {
            return UIImage(named: "stars_3_5")
        }
    }
    
    func addShimming(nativeAdView: GADNativeAdView){
        nativeAdView.layoutIfNeeded()
        nativeAdView.headlineView?.addShimming()
        nativeAdView.bodyView?.addShimming()
        nativeAdView.callToActionView?.addShimming()
        nativeAdView.iconView?.addShimming()
        nativeAdView.storeView?.addShimming()
        nativeAdView.advertiserView?.addShimming()
    }
    
    func loadFullScreenNativeAds(withAdId: String) {
        fullAdLoader = GADAdLoader(
            adUnitID: withAdId, rootViewController: self,
            adTypes: [.native], options: nil)
        fullAdLoader.delegate = self
        fullAdLoader.load(GADRequest())
    }
    
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
        
        nativeFullAdPlaceholder.isHidden = false
        
        nativeFullAdView.bodyView?.removeShimming()
        nativeFullAdView.callToActionView?.removeShimming()
        nativeFullAdView.iconView?.removeShimming()
        nativeFullAdView.storeView?.removeShimming()
        nativeFullAdView.advertiserView?.removeShimming()
        nativeFullAdView.headlineView?.removeShimming()
        
        nativeAd.delegate = self
        
        nativeFullAdPlaceholder.isHidden = false
        
        (nativeFullAdView.headlineView as? UILabel)?.text = nativeAd.headline
        
        //Media Video View
        
        nativeFullAdView.mediaView?.mediaContent = nativeAd.mediaContent
        let mediaContent = nativeAd.mediaContent
        
        if mediaContent.hasVideoContent {
            mediaContent.videoController.delegate = self
        }
        
        (nativeFullAdView.bodyView as? UILabel)?.text = nativeAd.body
        nativeFullAdView.bodyView?.isHidden = nativeAd.body == nil
        
        (nativeFullAdView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
        nativeFullAdView.callToActionView?.isHidden = nativeAd.callToAction == nil
        
        (nativeFullAdView.iconView as? UIImageView)?.image = nativeAd.icon?.image
        nativeFullAdView.iconView?.isHidden = nativeAd.icon == nil
        
        (nativeFullAdView.storeView as? UILabel)?.text = nativeAd.store
        nativeFullAdView.storeView?.isHidden = nativeAd.store == nil
        
        (nativeFullAdView.priceView as? UILabel)?.text = nativeAd.price
        nativeFullAdView.priceView?.isHidden = nativeAd.price == nil
        
        (nativeFullAdView.advertiserView as? UILabel)?.text = nativeAd.advertiser
        nativeFullAdView.advertiserView?.isHidden = nativeAd.advertiser == nil
        
        (nativeFullAdView.starRatingView as? UIImageView)?.image = imageOfStars(
            from: nativeAd.starRating)
        nativeFullAdView.starRatingView?.isHidden = nativeAd.starRating == nil
        
        nativeFullAdView.callToActionView?.isUserInteractionEnabled = false
        
        setupAdColors(NativeAdsColors: nativeFullAdView, nativeAdInfo: nativeAdInfo!)
        
        nativeFullAdView.nativeAd = nativeAd
    }
    
    func nativeAdDidRecordClick(_ nativeAd: GADNativeAd) {
        print("nativeAdDidRecordClick")
    }
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        DispatchQueue.main.async{ [self] in
            totalPage = 3
            nativeFullAdPlaceholder.isHidden = true
            nativeFullWidth = changeMultiplier(nativeFullWidth, multiplier: 0.0001)
            self.view.layoutIfNeeded()
        }
    }
}
//MARK:- NativeAds_Colors
extension OnBoardingVc {
    func setupAdColors(NativeAdsColors: GADNativeAdView, nativeAdInfo: [String: String]) {
        // Background color for the full ad view
        NativeAdsColors.backgroundColor = UIColor(rgb: nativeAdInfo["nativeBgColor"] ?? nativeBgColor)
        
        // Text color for headline and body
        (NativeAdsColors.headlineView as? UILabel)?.textColor = UIColor(rgb: nativeAdInfo["headerTextColor"] ?? headerTextColor)
        (NativeAdsColors.bodyView as? UILabel)?.textColor = UIColor(rgb: nativeAdInfo["bodyTextColor"] ?? bodyTextColor)
        
        // Background and text color for Call To Action button
        NativeAdsColors.callToActionView?.backgroundColor = UIColor(rgb: nativeAdInfo["btnBgColor"] ?? btnBgColor)
        (NativeAdsColors.callToActionView as? UIButton)?.setTitleColor(UIColor(rgb: nativeAdInfo["btnTextColor"] ?? btnTextColor), for: .normal)
        
        // Customization for the "Ad" label
        NativeAdsColors.subviews.forEach { view in
            if let label = view as? UILabel, label.text == "Ad" {
                label.backgroundColor = UIColor(rgb: nativeAdInfo["adTagBgColor"] ?? adTagBgColor)
                label.textColor = UIColor(rgb: nativeAdInfo["adTagTextColor"] ?? adTagTextColor)
            }
        }
    }

}

extension OnBoardingVc : PremiumPurchased {
    
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
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeViewController")as! HomeViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
