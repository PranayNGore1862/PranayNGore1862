//
//  FinalImagePreviewViewController.swift
//  AIOOTD
//
//  Created by beetonz Mac Mini on 22/01/25.
//

import UIKit
import Alamofire
import Photos
import SwiftyGif
import GoogleMobileAds

class FinalImagePreviewViewController: UIViewController {

    // FittingRoom
    var garmentImage: UIImage!
    var typeString: String!
    
    // Outfit
    var userPrompt: String!
    
    var userImage: UIImage!
    
    @IBOutlet var gifImgPro: UIImageView!
    @IBOutlet var imageDisplayView: UIView!
    @IBOutlet var previewCollectionView: UICollectionView!
    @IBOutlet var collWidthConst: NSLayoutConstraint!
    @IBOutlet var collHeightConst: NSLayoutConstraint!
    @IBOutlet var pageController: UIPageControl!
    @IBOutlet var loadingView: UIView!
    @IBOutlet  var SetHeight: NSLayoutConstraint!
    @IBOutlet var bottomConstraint:NSLayoutConstraint!
    @IBOutlet var bottomSuperView: UIView!
    var bannerView:GADBannerView!
    var imageArray: [UIImage] = []
    var imageArrayWeb: [String] = []
    var selectedIndex: Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gifImgPro.setGifImage(try! UIImage(gifName: "loader"))
        SetTopBarHeight(constraint: SetHeight)
        if creditLeft <= freeCredits {
            bottomConstraint.constant = 75
        } else {
            bottomConstraint.constant = 0
        }
       
        loadingView.isHidden = false
        if featureSelect == .outfit {
            let totalImageCount = 2
            for _ in 0..<totalImageCount {
                OutfitFromLightX(userImage: userImage, userPrompt: userPrompt, completion: { [self] resultArr in
                    if resultArr!.count > 0 {
                        imageArrayWeb.append(resultArr![0])
                        if imageArrayWeb.count == totalImageCount {
                            creditLeft -= outfitDecAmount
                            downloadImageRecc(at: 0)
                        }
                    } else {
                        somethingWrongAlert()
                    }
                })
            }
        } else if featureSelect == .fittingRoom {
            OneFuncForKling(modelImage: userImage, garmentImage: garmentImage, typeString: typeString, completion: { [self] resultArr in
                if resultArr!.count > 0 {
                    imageArrayWeb = resultArr!
                    if imageArrayWeb.count == resultArr!.count {
                        creditLeft -= fittingRoomDecAmount
                        downloadImageRecc(at: 0)
                    }
                } else {
                    somethingWrongAlert()
                }
            })
        }
    }
    
    func downloadImageRecc(at index: Int) {
        AF.download(imageArrayWeb[index], method: .get).responseData { [self] response in
            switch response.result {
            case .success(let data):
                imageArray.append(UIImage(data: data)!)
                if index == imageArrayWeb.count - 1 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [self] in
                        pageController.numberOfPages = imageArray.count
                        previewCollectionView.delegate = self
                        previewCollectionView.dataSource = self
                        calculateViewDimensions()
                        if creditLeft <= freeCredits {
                            loadBannerAd()
                        }
                        self.view.layoutIfNeeded()
                        loadingView.isHidden = true
                    }
                } else {
                    downloadImageRecc(at: index + 1)
                }
            case .failure(_):
                somethingWrongAlert()
            }
        }
    }
    
    
    @IBAction func saveTapped(_ sender: UIButton) {
        PHPhotoLibrary.shared().savePhoto(image: imageArray[selectedIndex], albumName: myAlbumName)
        showAlertBox(message: "Image Saved Successfully")
    }
    
    @IBAction func shareTapped(_ sender: UIButton) {
        let item = imageArray[selectedIndex]
        let shareBoth : [Any] = [item]
        let activityController = UIActivityViewController(activityItems: shareBoth, applicationActivities: nil)
        // For iPad
        if UIDevice.current.userInterfaceIdiom == .pad{
            activityController.popoverPresentationController?.sourceView = self.view
            activityController.popoverPresentationController?.sourceRect = sender.frame
        }
        self.present(activityController, animated: true)
    }
    
    
    @IBAction func backTapped(_ sender: UIButton) {
        navigationController?.popToViewController(ofClass: HomeViewController.self)
    }
    
    func calculateViewDimensions() {
        let actualHeight = (imageDisplayView.frame.height * 0.95)
        let actualWidth = (imageDisplayView.frame.width * 0.95)
        let actualSize = CGSize(width: actualWidth, height: actualHeight)
        let fittedSize = imageArray[selectedIndex].size.sizeThatFitsSize(actualSize)
        collWidthConst.constant = fittedSize.width
        collHeightConst.constant = fittedSize.height
    }
    
}

extension FinalImagePreviewViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = previewCollectionView.dequeueReusableCell(withReuseIdentifier: "FinalImagePreCollectionViewCell", for: indexPath) as! FinalImagePreCollectionViewCell
        cell.cellImage.image = imageArray[indexPath.row]
        cell.userOriImage = userImage
                    cell.userGenImage = imageArray[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        pageController.currentPage = selectedIndex
        DispatchQueue.main.async { [self] in
            calculateViewDimensions()
            self.view.layoutIfNeeded()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return previewCollectionView.frame.size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
}
extension FinalImagePreviewViewController: GADBannerViewDelegate{
    
    func loadBannerAd() {
        let adaptiveSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(self.view.frame.size.width)
        bannerView = GADBannerView(adSize: adaptiveSize)
        bannerView.adUnitID = bannerFinalImagePreviewViewController
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
