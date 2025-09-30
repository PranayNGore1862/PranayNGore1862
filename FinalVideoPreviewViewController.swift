//
//  FinalVideoPreviewViewController.swift
//  AIOOTD
//
//  Created by beetonz Mac Mini on 28/01/25.
//

import UIKit
import Lottie
import AVFoundation
import Photos
import SwiftyGif
import GoogleMobileAds

class FinalVideoPreviewViewController: UIViewController {

    var userImage: UIImage!
    var userPrompt: String!
    
    @IBOutlet var displayView: UIView!
    @IBOutlet var displayWidthConst: NSLayoutConstraint!
    @IBOutlet var displayHeightConst: NSLayoutConstraint!
    @IBOutlet var videoView: UIView!
    @IBOutlet var loaderView: UIView!
    @IBOutlet var gifImgPro: UIImageView!
    
    var playerLayer : AVPlayerLayer!
    var player : AVPlayer!
    
    var thumbImage: UIImage!
    var genVideoDoc = documentsDirectoryURL.appendingPathComponent("AI-Outfit-Video").appendingPathExtension("mp4")
    @IBOutlet  var SetHeight: NSLayoutConstraint!
    @IBOutlet var bottomConstraint:NSLayoutConstraint!
    @IBOutlet var bottomSuperView: UIView!
    var bannerView:GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gifImgPro.setGifImage(try! UIImage(gifName: "loader"))
        SetTopBarHeight(constraint: SetHeight)
        if creditLeft <= freeCredits {
            bottomConstraint.constant = 75
        } else {
            bottomConstraint.constant = 0
        }
      
        loaderView.isHidden = false
       
        DispatchQueue.main.async { [self] in
            
            if featureSelect == .ootd {
                
                FinalVideoDataFromVidu(userImage: userImage, userPrompt: userPrompt, completion: { [self] videoData in
                    if videoData != nil {
                        creditLeft -= ootdVideoDecAmount
                        createFile(atPath: genVideoDoc.path, contentsOf: videoData!, overwrite: true, completion: { [self] succ in
                            if succ {
                                generateThumbnailInGlobalQueue(url: URL(fileURLWithPath: genVideoDoc.path), completion: { [self] genThumbImage in
                                    thumbImage = genThumbImage
                                    calculateViewDimensions()
                                    if creditLeft <= freeCredits {
                                        loadBannerAd()
                                    }
                                    self.view.layoutIfNeeded()
                                    setUpVideoPlayer(myUrl: genVideoDoc)
                                    NotificationCenter.default.addObserver(self, selector: #selector(backgroundVideoDidEnd), name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
                                    loaderView.isHidden = true
                                })
                            } else {
                                somethingWrongAlert()
                            }
                        })
                    } else {
                        somethingWrongAlert()
                    }
                })
            }
        }
    }
    
    @objc func backgroundVideoDidEnd() {
        player.seek(to: .zero)
        player.play()
    }
    
    @IBAction func saveBtnTapped(_ sender: UIButton) {
        PHPhotoLibrary.shared().saveVideo(fileURL: genVideoDoc, albumName: myAlbumName)
        showAlertBox(message: "Outfit Video Saved Successfully")
    }
    
    @IBAction func shareBtnTapped(_ sender: UIButton) {
        let yourVideo = genVideoDoc
        let shareItems : [Any] = [yourVideo]
        let activityController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        if UIDevice.current.userInterfaceIdiom == .pad{
            activityController.popoverPresentationController?.sourceView = self.view
            activityController.popoverPresentationController?.sourceRect = sender.frame
        }
        self.present(activityController, animated: true)
    }
    
    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popToViewController(ofClass: HomeViewController.self)
    }
    
    func setUpVideoPlayer(myUrl: URL) {
        player = AVPlayer(url: myUrl)
        playerLayer = AVPlayerLayer(player: self.player)
        playerLayer.videoGravity = .resizeAspectFill
        self.view.layoutIfNeeded()
        playerLayer.frame = videoView.bounds
        videoView.layer.masksToBounds = true
        videoView.layer.addSublayer(self.playerLayer)
        player.volume = 0
        player.play()
    }
    
    func calculateViewDimensions() {
        let actualHeight = (displayView.frame.height * 0.95)
        let actualWidth = (displayView.frame.width * 0.95)
        let actualSize = CGSize(width: actualWidth, height: actualHeight)
        let fittedSize = thumbImage.size.sizeThatFitsSize(actualSize)
        displayWidthConst.constant = fittedSize.width
        displayHeightConst.constant = fittedSize.height
    }

}

extension FinalVideoPreviewViewController: GADBannerViewDelegate{
    
    func loadBannerAd() {
        let adaptiveSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(self.view.frame.size.width)
        bannerView = GADBannerView(adSize: adaptiveSize)
        bannerView.adUnitID = bannerFinalVideoPreviewViewController
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
