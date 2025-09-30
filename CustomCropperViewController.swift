//
//  CustomCropperHugViewController.swift
//  FakeSwapper
//
//  Created by beetonz Mac Mini on 13/09/24.
//

import UIKit
import GoogleMobileAds

protocol CustomDelegateCrop: AnyObject {
    func croppedImageFunc(image: UIImage)
}

class CustomCropperViewController: UIViewController {

    @IBOutlet var viewImageCropperStoryboard: AKImageCropperView!
    
    @IBOutlet  var SetHeight: NSLayoutConstraint!
    @IBOutlet var bottomConstraint:NSLayoutConstraint!
    @IBOutlet var bottomSuperView: UIView!
    var bannerView:GADBannerView!
    
    var delegate: CustomDelegateCrop!
    var actualImage: UIImage?
    var croppedImage: UIImage?
    var rotateAngle: Double = 0.0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SetTopBarHeight(constraint: SetHeight)
        if creditLeft <= freeCredits {
            bottomConstraint.constant = 75
            loadBannerAd()
        } else {
            bottomConstraint.constant = 15
        }
        viewImageCropperStoryboard.image = actualImage
        viewImageCropperStoryboard.showOverlayView()
        viewImageCropperStoryboard.overlayView?.fixedRatio(ratioX: 9, ratioY: 16)
        viewImageCropperStoryboard.overlayView?.layoutSubviews()
        viewImageCropperStoryboard.setNeedsLayout()
    }
    
    @IBAction func cropDoneButtonTapped(_ sender: UIButton) {
        delegate.croppedImageFunc(image: viewImageCropperStoryboard.croppedImage!)
        self.dismiss(animated: true)
    }
    
    @IBAction func rotateButtonTapped(_ sender: UIButton) {
        rotateAngle += (Double.pi / 2)
        viewImageCropperStoryboard.rotate(rotateAngle, withDuration: 0.3, completion: { _ in
            if self.rotateAngle == 2 * (Double.pi) {
                self.rotateAngle = 0.0
            }
        })
    }
    
    
    @IBAction func resetButtonTapped(_ sender: UIButton) {
        rotateAngle = 0.0
        viewImageCropperStoryboard.reset(animationDuration: 0.3)
        viewImageCropperStoryboard.overlayView?.fixedRatio(ratioX: 9, ratioY: 16)
        viewImageCropperStoryboard.overlayView?.layoutSubviews()
        viewImageCropperStoryboard.setNeedsLayout()
    }
    
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
}

extension CustomCropperViewController: GADBannerViewDelegate{
    
    func loadBannerAd() {
        let adaptiveSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(self.view.frame.size.width)
        bannerView = GADBannerView(adSize: adaptiveSize)
        bannerView.adUnitID = bannerCustomCropperViewController
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
