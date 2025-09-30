//
//  QuitionVc.swift
//  AIOOTD
//
//  Created by Gayatri Sonani on 13/02/25.
//

import UIKit
import GoogleMobileAds
import SwiftyGif

class QuitionVc: UIViewController {

//    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var tblQuitionView: UITableView!
    @IBOutlet var tapImageView: UIImageView!
    
    @IBOutlet var nativeHeight: NSLayoutConstraint!
    @IBOutlet var nativeAdPlaceholder: UIView!
       
    @IBOutlet var doneBtn: UIButton!
   

    var arrOptionsName = ["Black Bikini","Latex Suit","Barbie Dress","Formal Suit","Cindrella Dress"]
    var nativeAdView: GADNativeAdView!
    var adLoader: GADAdLoader!
    var selectedIndex: Int = -1
    
    var onClickGADNativdAd: GADNativeAd?
    var onClickGADAdLoader: GADAdLoader?

    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        if isAdsShown {
            if creditLeft <= freeCredits {
                if !isAlreadyLaunched {
                    // PreLoad Ad
                    setAdView(gadNativeAD: launchOnQuestionAd)
                    loadOnClickNativeAds(withAdId: nativeOnClickQuitionVc)
                } else {
                    // New Ad Load
                    setNativeAdView()
                }
            } else {
                nativeAdPlaceholder.isHidden = true
                nativeHeight = changeMultiplier(nativeHeight, multiplier: 0.0001)
            }
        } else {
            nativeAdPlaceholder.isHidden = true
            nativeHeight = changeMultiplier(nativeHeight, multiplier: 0.0001)
        }
        
        
//        if !isAlreadyLaunched {
            // First Time
            doneBtn.isHidden = true
            tblQuitionView.delegate = self
            tblQuitionView.dataSource = self
            tapImageView.isHidden = false
            tapImageView.setGifImage(try! UIImage(gifName: "tap_gif"))
//        } else {
//            // Other Time
//            doneBtn.isHidden = true
//            backBtn.isHidden = false
//            for i in 0..<localizationLangCode.count {
//                if currentLanguage == localizationLangCode[i] {
//                    selectedIndex = i
//                    langTableView.delegate = self
//                    langTableView.dataSource = self
//                }
//            }
//            tapImageView.isHidden = true
//        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    
    @IBAction func doneBtn(_ sender: UIButton) {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OnBoardingVc") as! OnBoardingVc
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    
}

extension QuitionVc: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrOptionsName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblQuitionView.dequeueReusableCell(withIdentifier: "QuitionTableViewCell", for: indexPath) as! QuitionTableViewCell
        cell.lblOptions.text = arrOptionsName[indexPath.row]
        if selectedIndex == indexPath.row {
            cell.imgBg.image = UIImage(named: "Que_press")
        } else {
            cell.imgBg.image = UIImage(named: "Que_unpress")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        if !isAlreadyLaunched {
            tapImageView.isHidden = true
            doneBtn.isHidden = false
            if selectedIndex == -1 {
                if creditLeft <= freeCredits {
                    setAdView(gadNativeAD: onClickGADNativdAd)
                }
            }
        }
        selectedIndex = indexPath.row
        tblQuitionView.reloadData()
        tableView.scrollToRow(at: IndexPath(row: selectedIndex, section: 0), at: .middle, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let width = tblQuitionView.bounds.width
        let height = (UIDevice.current.userInterfaceIdiom == .phone) ? width * (250/1171) + 5 : width * (250/1171) - 20
        return height
    }
}


class QuitionTableViewCell: UITableViewCell {
    
   @IBOutlet var lblOptions: UILabel!
    @IBOutlet var imgBg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}


extension QuitionVc : GADAdLoaderDelegate, GADNativeAdLoaderDelegate, GADNativeAdDelegate, GADVideoControllerDelegate {
    
    
    func setNativeAdView() {
        guard
            let nibObjects = Bundle.main.loadNibNamed("BigNativeAdView", owner: nil, options: nil),
            let adView = nibObjects.first as? GADNativeAdView
        else {
            assert(false, "Could not load nib file for adView")
            return
        }
        nativeAdView = adView
        nativeAdPlaceholder.addSubview(nativeAdView)
        nativeAdView.frame = nativeAdPlaceholder.bounds
        
        addShimming(nativeAdView: adView)
        loadNativeAds(withAdId: nativeOnClickQuitionVc)
        
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
    
    
    func imageOfStars(from starRating: NSDecimalNumber?) -> UIImage? {
        guard let rating = starRating?.doubleValue else {
            return UIImage(named: "stars_3_5")
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
    
    func loadNativeAds(withAdId: String) {
        adLoader = GADAdLoader(
            adUnitID: withAdId, rootViewController: self,
            adTypes: [.native], options: nil)
        adLoader.delegate = self
        adLoaderForOnQuestion = adLoader
        adLoader.load(GADRequest())
    }
    
    func loadOnClickNativeAds(withAdId: String) {
        adLoader = GADAdLoader(
            adUnitID: withAdId, rootViewController: self,
            adTypes: [.native], options: nil)
        adLoader.delegate = self
        onClickGADAdLoader = adLoader
        adLoader.load(GADRequest())
    }
    
    
    
    
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
        
        if adLoader == adLoaderForOnQuestion {
            
            nativeAdView.bodyView?.removeShimming()
            nativeAdView.callToActionView?.removeShimming()
            nativeAdView.iconView?.removeShimming()
            nativeAdView.storeView?.removeShimming()
            nativeAdView.advertiserView?.removeShimming()
            nativeAdView.headlineView?.removeShimming()
            
            nativeAd.delegate = self
            
            nativeAdPlaceholder.isHidden = false
            
            (nativeAdView.headlineView as? UILabel)?.text = nativeAd.headline
            
            //Media Video View
            nativeAdView.mediaView?.mediaContent = nativeAd.mediaContent
            let mediaContent = nativeAd.mediaContent
            
            if mediaContent.hasVideoContent {
                mediaContent.videoController.delegate = self
            }
            
            
            (nativeAdView.bodyView as? UILabel)?.text = nativeAd.body
            nativeAdView.bodyView?.isHidden = nativeAd.body == nil
            
            (nativeAdView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
            nativeAdView.callToActionView?.isHidden = nativeAd.callToAction == nil
            
            (nativeAdView.iconView as? UIImageView)?.image = nativeAd.icon?.image
            nativeAdView.iconView?.isHidden = nativeAd.icon == nil
            
            (nativeAdView.storeView as? UILabel)?.text = nativeAd.store
            nativeAdView.storeView?.isHidden = nativeAd.store == nil
            
            (nativeAdView.priceView as? UILabel)?.text = nativeAd.price
            nativeAdView.priceView?.isHidden = nativeAd.price == nil
            
            (nativeAdView.advertiserView as? UILabel)?.text = nativeAd.advertiser
            nativeAdView.advertiserView?.isHidden = nativeAd.advertiser == nil
            
            (nativeAdView.starRatingView as? UIImageView)?.image = imageOfStars(
                from: nativeAd.starRating)
            
            nativeAdView.callToActionView?.isUserInteractionEnabled = false
            
            setupAdColors(NativeAdsColors: nativeAdView, nativeAdInfo: nativeAdInfo!)
            nativeAdView.nativeAd = nativeAd
            
        } else {
            onClickGADNativdAd = nativeAd
        }
    }
    
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

    
    func nativeAdDidRecordClick(_ nativeAd: GADNativeAd) {
        print("nativeAdDidRecordClick")
    }
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        //
    }
    
    
    
    func setAdView(gadNativeAD: GADNativeAd?) {
        guard
            let nibObjects = Bundle.main.loadNibNamed("BigNativeAdView", owner: nil, options: nil),
            let adView = nibObjects.first as? GADNativeAdView
        else {
            assert(false, "Could not load nib file for adView")
            return
        }
        
        
        nativeAdPlaceholder.subviews.forEach { $0.removeFromSuperview() }
        
        nativeAdView = adView
        nativeAdPlaceholder.addSubview(nativeAdView)
        nativeAdView.frame = nativeAdPlaceholder.bounds
        self.view.layoutIfNeeded()
        
        
        gadNativeAD?.delegate = self
        
        nativeAdPlaceholder.isHidden = false
        
        (nativeAdView.headlineView as? UILabel)?.text = gadNativeAD?.headline
        
        //Media Video View
        nativeAdView.mediaView?.mediaContent = gadNativeAD?.mediaContent
        let mediaContent = gadNativeAD?.mediaContent
        
        if mediaContent != nil {
            if mediaContent!.hasVideoContent {
                mediaContent!.videoController.delegate = self
            }
        }
        
        
        (nativeAdView.bodyView as? UILabel)?.text = gadNativeAD?.body
        nativeAdView.bodyView?.isHidden = gadNativeAD?.body == nil
        
        (nativeAdView.callToActionView as? UIButton)?.setTitle(gadNativeAD?.callToAction, for: .normal)
        nativeAdView.callToActionView?.isHidden = gadNativeAD?.callToAction == nil
        
        (nativeAdView.iconView as? UIImageView)?.image = gadNativeAD?.icon?.image
        nativeAdView.iconView?.isHidden = gadNativeAD?.icon == nil
        
        (nativeAdView.storeView as? UILabel)?.text = gadNativeAD?.store
        nativeAdView.storeView?.isHidden = gadNativeAD?.store == nil
        
        (nativeAdView.priceView as? UILabel)?.text = gadNativeAD?.price
        nativeAdView.priceView?.isHidden = gadNativeAD?.price == nil
        
        (nativeAdView.advertiserView as? UILabel)?.text = gadNativeAD?.advertiser
        nativeAdView.advertiserView?.isHidden = gadNativeAD?.advertiser == nil
        
        (nativeAdView.starRatingView as? UIImageView)?.image = imageOfStars(
            from: gadNativeAD?.starRating)
        
        nativeAdView.callToActionView?.isUserInteractionEnabled = false
        
        setupAdColors(NativeAdsColors: nativeAdView, nativeAdInfo: nativeAdInfo!)
        
        nativeAdView.nativeAd = gadNativeAD
    }
}

