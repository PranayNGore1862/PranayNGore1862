//
//  PreviewViewController.swift
//  BigBrain
//
//  Created by beetonz Mac Mini on 28/05/24.
//

import UIKit
import AVFoundation
import GoogleMobileAds

class PreviewViewController: UIViewController {

    var tag: Int!
    var videoURL: URL!
    
    var thumbImage: UIImage?
    
    var playerLayer : AVPlayerLayer!
    var player : AVPlayer!
    
    @IBOutlet var displayView: UIView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var imageWidthConst: NSLayoutConstraint!
    @IBOutlet var imageHeightConst: NSLayoutConstraint!
    
    @IBOutlet var btnVshare: UIButton!
    @IBOutlet var btnShare: UIButton!
    
    @IBOutlet  var SetHeight: NSLayoutConstraint!
    @IBOutlet var bottomConstraint:NSLayoutConstraint!
    @IBOutlet var bottomSuperView: UIView!
    var bannerView:GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SetTopBarHeight(constraint: SetHeight)
        if creditLeft <= freeCredits {
            bottomConstraint.constant = 75
            loadBannerAd()
        } else {
            bottomConstraint.constant = 0
        }
        DispatchQueue.main.async{ [self] in
            if tag == 0 {
                // Video
                btnVshare.isHidden = false
                btnShare.isHidden = true
                 thumbImage = getThumbnailImage(forUrl: videoURL!)
                calculateViewDimensions()
                player = AVPlayer(url: videoURL!)
                playerLayer = AVPlayerLayer(player: self.player)
                playerLayer.videoGravity = .resizeAspect
                imageView.layoutIfNeeded()
                self.view.layoutIfNeeded()
                playerLayer.frame = imageView.bounds
                imageView.layer.masksToBounds = true
                imageView.layer.addSublayer(self.playerLayer)
                player.volume = 1
                player.play()
            } else {
                // Image
                btnVshare.isHidden = true
                btnShare.isHidden = false
                imageView.image = thumbImage
                calculateViewDimensions()
                self.view.layoutIfNeeded()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if tag == 0 {
            if player != nil{
                NotificationCenter.default.addObserver(self,selector: #selector(playerItemDidReachEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        if player != nil {
            player.pause()
        }
    }

    
    @IBAction func shareBtnTapped(_ sender: UIButton) {
        if tag == 0 {
           
            let yourData = videoURL
            let shareItems : [Any] = [yourData!]
            let activityController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
            // For iPad
            if UIDevice.current.userInterfaceIdiom == .pad{
                activityController.popoverPresentationController?.sourceView = self.view
                activityController.popoverPresentationController?.sourceRect = sender.frame
            }
            self.present(activityController, animated: true)
        } else {
            
            let yourData = thumbImage
            let shareItems : [Any] = [yourData!]
            let activityController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
            // For iPad
            if UIDevice.current.userInterfaceIdiom == .pad{
                activityController.popoverPresentationController?.sourceView = self.view
                activityController.popoverPresentationController?.sourceRect = sender.frame
            }
            self.present(activityController, animated: true)
        }
        
    }
    
    @IBAction func backBtnTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    
    
    @objc func playerItemDidReachEnd(notification: NSNotification) {
        player.seek(to: CMTime.zero)
        player.play()
    }

    
    
    func calculateViewDimensions() {
        let actualHeight = (displayView.frame.height * 0.95)
        let actualWidth = (displayView.frame.width * 0.95)
        
        let actualSize = CGSize(width: actualWidth, height: actualHeight)
        
        if thumbImage != nil {
            let fittedSize = thumbImage!.size.sizeThatFitsSize(actualSize)

            imageWidthConst.constant = fittedSize.width
            imageHeightConst.constant = fittedSize.height
            
        }
    }
}

extension PreviewViewController: GADBannerViewDelegate{
    
    func loadBannerAd() {
        let adaptiveSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(self.view.frame.size.width)
        bannerView = GADBannerView(adSize: adaptiveSize)
        bannerView.adUnitID = bannerPreviewViewController
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
