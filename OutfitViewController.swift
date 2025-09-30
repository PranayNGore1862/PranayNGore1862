//
//  AIOutfitViewController.swift
//  AIOOTD
//
//  Created by beetonz Mac Mini on 22/01/25.
//

import UIKit
import Photos
import QCropper
import SwiftyJSON
import Kingfisher
import GoogleMobileAds

class OutfitViewController: UIViewController, PremiumPurchased {

    var userImage: UIImage!
    
    @IBOutlet var decLbl: UILabel!
    @IBOutlet var imageDisplayView: UIView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var imageWidthConst: NSLayoutConstraint!
    @IBOutlet var imageHeightConst: NSLayoutConstraint!
    @IBOutlet var promptTextView: RSKPlaceholderTextView!
    @IBOutlet var trendingCollectionView: UICollectionView!
    @IBOutlet var nameCollectionView: UICollectionView!
    
    @IBOutlet  var SetHeight: NSLayoutConstraint!
    @IBOutlet var bottomConstraint:NSLayoutConstraint!
    @IBOutlet var bottomSuperView: UIView!
    var bannerView:GADBannerView!
    
    var trendingJSON: [JSON]!
    var selectedIndex: Int = 0
    var selectedNameIndex: Int = -1
    var selectedTag: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        SetTopBarHeight(constraint: SetHeight)
        if creditLeft <= freeCredits {
            bottomConstraint.constant = 75
            loadBannerAd()
        } else {
            bottomConstraint.constant = 0
        }
        decLbl.text = "\(outfitDecAmount)"
        featureSelect = .outfit
        
        selectedTag = Int.random(in: 0...1)
        
        
        nameCollectionView.delegate = self
        nameCollectionView.dataSource = self
        
        TrendingSuperLook(completion: { [self] resArr in
            if resArr!.count > 0 {
                trendingJSON = resArr
                promptTextView.text = stringToJson(string: trendingJSON[0][selectedIndex]["prompt"].stringValue)["idea"].stringValue
                trendingCollectionView.delegate = self
                trendingCollectionView.dataSource = self
            }
        })
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tap)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [self] in
            imageDisplayView.borderWidth = 0
            imageDisplayView.borderColor = .clear
            imageView.image = UIImage(named: "sc9upload_img")
            calculateViewDimensions()
        }
    }
    
    @IBAction func seeAllBtnTapped(_ sender: UIButton) {
        if trendingJSON != nil {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SeeAllOutfitViewController") as! SeeAllOutfitViewController
            vc.selectedTag = selectedTag
            vc.selectedIndex = selectedIndex
            vc.currentJSON = trendingJSON
            vc.delegate = self
            self.present(vc, animated: true)
        } else {
            showAlertBox(message: "Something went wrong")
        }
    }
    
    @IBAction func generateBtnTapped(_ sender: UIButton) {
        if userImage != nil {
            if promptTextView.text != "" {
                if creditLeft >= outfitDecAmount {
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FinalImagePreviewViewController") as! FinalImagePreviewViewController
                    vc.userImage = userImage
                    vc.userPrompt = promptTextView.text
                    presentInterstitialAd(viewController: self)
                    navigationController?.pushViewController(vc, animated: true)
                } else {
                    print("Pro Screen")
                    let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProViewController") as! ProViewController
                    controller.modalPresentationStyle = .fullScreen
                    controller.premiumProtocol = self
                    self.present(controller, animated: true, completion: nil)
                }
            } else {
                showAlertBox(message: "Please enter prompt")
            }
        } else {
            showAlertBox(message: "Please Upload Image")
        }
    }
    
    @IBAction func backTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func imageTapped(){
        let customPicker = UIStoryboard(name: "CustomPhotoPicker", bundle: nil).instantiateViewController(withIdentifier: "CustomLibraryPickerController") as! CustomLibraryPickerController
        customPicker.mediaType = .image
        customPicker.placeHolderImage = UIImage(named: "gallery")
        customPicker.maxSelectedAssets = 1
        customPicker.isRecentFolder = true
        customPicker.pickerDelegate = self
        customPicker.modalPresentationStyle = .fullScreen
        self.present(customPicker, animated: true)
    }

    
    func calculateViewDimensions() {
        let actualHeight = (imageDisplayView.frame.height * 0.95)
        let actualWidth = (imageDisplayView.frame.width * 0.95)
        let actualSize = CGSize(width: actualWidth, height: actualHeight)
        let fittedSize = imageView.image!.size.sizeThatFitsSize(actualSize)
        imageWidthConst.constant = fittedSize.width
        imageHeightConst.constant = fittedSize.height
    }
    
    func stringToJson(string: String) -> JSON {
        let data = string.data(using: .utf8)!
        do {
            let json = try JSON(data: data)
            return json
        } catch {
            return JSON()
        }
    }
    
}

extension OutfitViewController: SeeAllDelegate {
    func selectCloth(index: Int) {
        selectedIndex = index
        promptTextView.text = stringToJson(string: trendingJSON[0][selectedIndex]["prompt"].stringValue)["idea"].stringValue
        trendingCollectionView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [self] in
            trendingCollectionView.scrollToItem(at: IndexPath(row: selectedIndex, section: 0), at: .centeredHorizontally, animated: true)
        }
        
        selectedNameIndex = -1
        nameCollectionView.reloadData()
    }
}

extension OutfitViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == nameCollectionView {
            return nameOutfitArr["outfitPrompts"].arrayValue.count
        } else {
            return trendingJSON[0].count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == nameCollectionView {
            let cell = nameCollectionView.dequeueReusableCell(withReuseIdentifier: "OutfitNameCollectionViewCell", for: indexPath) as! OutfitNameCollectionViewCell
            if selectedNameIndex == indexPath.row {
                cell.contentView.backgroundColor = .fillPromptBG
                cell.cellLbl.textColor = .black
            } else {
                cell.contentView.backgroundColor = .unfillPromptBG
                cell.cellLbl.textColor = .textPrompt
            }
            cell.cellLbl.text = nameOutfitArr["outfitPrompts"][indexPath.row].stringValue
            return cell
        } else {
            let cell = trendingCollectionView.dequeueReusableCell(withReuseIdentifier: "OutfitCollectionViewCell", for: indexPath) as! OutfitCollectionViewCell
            if selectedIndex == indexPath.row {
                cell.contentView.borderColor = .fillPromptBG
                cell.contentView.borderWidth = 2
            } else {
                cell.contentView.borderColor = .clear
                cell.contentView.borderWidth = 0
            }
            cell.layoutIfNeeded()
            cell.cellImage.addShimming()
            let url = URL(string: trendingJSON[0][indexPath.row][selectedTag == 0 ? "imageUrl" : "showcaseImageUrl"].stringValue)
            cell.cellImage.kf.setImage(with: url, options: [.transition(.fade(0.1)), .fromMemoryCacheOrRefresh], completionHandler: { _ in
                cell.cellImage.removeShimming()
            })
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == nameCollectionView {
            selectedNameIndex = indexPath.row
            promptTextView.text = nameOutfitArr["outfitPrompts"][selectedNameIndex].stringValue
            nameCollectionView.reloadData()
            nameCollectionView.scrollToItem(at: IndexPath(row: selectedNameIndex, section: 0), at: .centeredHorizontally, animated: true)
            
            selectedIndex = -1
            trendingCollectionView.reloadData()
        } else {
            selectedIndex = indexPath.row
            promptTextView.text = stringToJson(string: trendingJSON[0][selectedIndex]["prompt"].stringValue)["idea"].stringValue
            trendingCollectionView.reloadData()
            trendingCollectionView.scrollToItem(at: IndexPath(row: selectedIndex, section: 0), at: .centeredHorizontally, animated: true)
            
            selectedNameIndex = -1
            nameCollectionView.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch UIDevice.current.userInterfaceIdiom{
            
        case .phone:
            if collectionView == nameCollectionView {
                let tagSize = nameOutfitArr["outfitPrompts"][indexPath.row].stringValue.size(withAttributes: [
                    NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 15)])
                return CGSize(width: tagSize.width + 25, height: tagSize.height + 15)
            } else {
                let height = collectionView.frame.size.height
                let width = (896/1152) * height
                return CGSize(width: width, height: height)
            }
        case .pad:
            if collectionView == nameCollectionView {
                let tagSize = nameOutfitArr["outfitPrompts"][indexPath.row].stringValue.size(withAttributes: [
                    NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 25)])
                return CGSize(width: tagSize.width + 25, height: tagSize.height + 15)
            } else {
                let height = collectionView.frame.size.height
                let width = (896/1152) * height
                return CGSize(width: width, height: height)
            }
        default:
            return CGSize()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat{
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
}

extension OutfitViewController : CustomLibraryPickerControllerDelegate {
    func singleImagePick(_ didSelectImage: UIImage) {
        DispatchQueue.main.async { [self] in
            if didSelectImage.size.height > 720 || didSelectImage.size.width > 720 {
                if didSelectImage.size.width > didSelectImage.size.height {
                    let i = didSelectImage.resized(withWidth: 720)
                    print(i!.size)
                    let cropper = CropperViewController(originalImage: i!)
                    cropper.delegate = self
                    self.present(cropper, animated: true)
                } else if didSelectImage.size.width < didSelectImage.size.height {
                    let i = didSelectImage.resized(withHeight: 720)
                    print(i!.size)
                    let cropper = CropperViewController(originalImage: i!)
                    cropper.delegate = self
                    self.present(cropper, animated: true)
                } else if didSelectImage.size.height == didSelectImage.size.width {
                    let i = didSelectImage.resized(withHeight: 720)
                    print(i!.size)
                    let cropper = CropperViewController(originalImage: i!)
                    cropper.delegate = self
                    self.present(cropper, animated: true)
                }
            } else {
                let cropper = CropperViewController(originalImage: didSelectImage)
                cropper.delegate = self
                self.present(cropper, animated: true)
            }
        }
    }
}

extension OutfitViewController : CropperViewControllerDelegate {
    func cropperDidConfirm(_ cropper: CropperViewController, state: CropperState?) {
        if let state = state,let image = cropper.originalImage.cropped(withCropperState: state){
            userImage = image
            imageView.image = userImage
            imageDisplayView.cornerRadius = 15
            imageDisplayView.borderWidth = 1.5
            imageDisplayView.borderColor = .borderGreen
            DispatchQueue.main.async { [self] in
                calculateViewDimensions()
            }
            self.dismiss(animated: true)
        } else {
            print("Something went wrong")
        }
    }
    
    func cropperDidCancel(_ cropper: CropperViewController) {
        self.dismiss(animated: true)
    }
}

extension OutfitViewController: GADBannerViewDelegate{
    
    func loadBannerAd() {
        let adaptiveSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(self.view.frame.size.width)
        bannerView = GADBannerView(adSize: adaptiveSize)
        bannerView.adUnitID = bannerOutfitViewController
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
