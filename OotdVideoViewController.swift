//
//  OotdVideoViewController.swift
//  AIOOTD
//
//  Created by beetonz Mac Mini on 27/01/25.
//

import UIKit
import QCropper
import GoogleMobileAds

class OotdVideoViewController: UIViewController, PremiumPurchased {

    
    @IBOutlet var decLbl: UILabel!
    @IBOutlet var imageDisplayView: UIView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var imageWidthConst: NSLayoutConstraint!
    @IBOutlet var imageHeightConst: NSLayoutConstraint!
    @IBOutlet var templateCollectionView: UICollectionView!
//    @IBOutlet var genderBtns: [UIButton]!
    
    @IBOutlet var btnGender: UIButton!
    @IBOutlet  var SetHeight: NSLayoutConstraint!
    @IBOutlet var bottomConstraint:NSLayoutConstraint!
    @IBOutlet var bottomSuperView: UIView!
    var bannerView:GADBannerView!
    
    var userImage: UIImage!
    var selectedIndex: Int = 0
    
    var selectedGender: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SetTopBarHeight(constraint: SetHeight)
        if creditLeft <= freeCredits {
            bottomConstraint.constant = 75
            loadBannerAd()
        } else {
            bottomConstraint.constant = 0
        }
        decLbl.text = "\(ootdVideoDecAmount)"
        
        templateCollectionView.delegate = self
        templateCollectionView.dataSource = self
        
        featureSelect = .ootd
        let tap = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tap)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [self] in
            imageDisplayView.borderWidth = 0
            imageDisplayView.borderColor = .clear
            imageView.image = UIImage(named: "sc9upload_img")
            calculateViewDimensions()
        }
        
//        genderBtns.forEach({$0.isSelected = false})
//        genderBtns[selectedGender].isSelected = true
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
    
    @IBAction func genderBtnTapped(_ sender: UIButton) {
//        selectedGender = sender.tag
//        genderBtns.forEach({$0.isSelected = false})
//        genderBtns[selectedGender].isSelected = true
//        selectedIndex = 0
//        templateCollectionView.reloadData()
//        templateCollectionView.scrollToItem(at: IndexPath(row: selectedIndex, section: 0), at: .centeredHorizontally, animated: true)
        
        if selectedGender == 0{
            selectedGender = 1
            btnGender.setImage(UIImage(named: "sc2_male"), for: .normal)
        }else{
            selectedGender = 0
            btnGender.setImage(UIImage(named: "sc2_female"), for: .normal)
        }
        selectedIndex = 0
        templateCollectionView.reloadData()
        templateCollectionView.scrollToItem(at: IndexPath(row: selectedIndex, section: 0), at: .centeredHorizontally, animated: true)
    }
    
    @IBAction func generateNowBtnTapped(_ sender: UIButton) {
        if userImage != nil {
            if creditLeft >= ootdVideoDecAmount {
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FinalVideoPreviewViewController") as! FinalVideoPreviewViewController
                if selectedGender == 0 {
                    vc.userImage = userImage
                    vc.userPrompt = videoTemplateJSON["female"][selectedIndex]["prompt"].stringValue
                    print(videoTemplateJSON["female"][selectedIndex]["prompt"].stringValue)
                    print(videoTemplateJSON["female"][selectedIndex]["name"].stringValue)
                    presentInterstitialAd(viewController: self)
                    navigationController?.pushViewController(vc, animated: true)
                } else {
                    vc.userImage = userImage
                    vc.userPrompt = videoTemplateJSON["male"][selectedIndex]["prompt"].stringValue
                    print(videoTemplateJSON["male"][selectedIndex]["prompt"].stringValue)
                    print(videoTemplateJSON["male"][selectedIndex]["name"].stringValue)
                    presentInterstitialAd(viewController: self)
                    navigationController?.pushViewController(vc, animated: true)
                }
            } else {
                print("Pro Screen")
                let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProViewController") as! ProViewController
                controller.modalPresentationStyle = .fullScreen
                controller.premiumProtocol = self
                self.present(controller, animated: true, completion: nil)
            }
        } else {
            showAlertBox(message: "Please Upload Image")
        }
    }
    
    @IBAction func backTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    func manageImageSize(amount: CGFloat, selectedImage: UIImage) -> UIImage {
        if selectedImage.size.height > amount || selectedImage.size.width > amount {
            if selectedImage.size.width > selectedImage.size.height {
                let i = selectedImage.resized(withWidth: amount)!
                print(i.size)
                return i
            } else if selectedImage.size.width < selectedImage.size.height {
                let i = selectedImage.resized(withHeight: amount)!
                print(i.size)
                return i
            } else if selectedImage.size.height == selectedImage.size.width {
                let i = selectedImage.resized(withHeight: amount)!
                print(i.size)
                return i
            } else {
                print(selectedImage.size)
                return selectedImage
            }
        } else {
            print(selectedImage.size)
            return selectedImage
        }
    }
    
    func calculateViewDimensions() {
        let actualHeight = (imageDisplayView.frame.height * 0.95)
        let actualWidth = (imageDisplayView.frame.width * 0.95)
        let actualSize = CGSize(width: actualWidth, height: actualHeight)
        let fittedSize = imageView.image!.size.sizeThatFitsSize(actualSize)
        imageWidthConst.constant = fittedSize.width
        imageHeightConst.constant = fittedSize.height
    }
    
}

extension OotdVideoViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if selectedGender == 0 {
            return videoTemplateJSON["female"].count
        } else {
            return videoTemplateJSON["male"].count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoTemplateCollectionViewCell", for: indexPath) as! VideoTemplateCollectionViewCell
        cell.layoutIfNeeded()
        if selectedGender == 0 {
            cell.cellLbl.text = videoTemplateJSON["female"][indexPath.row]["name"].stringValue
            let name = videoTemplateJSON["female"][indexPath.row]["name"].stringValue
            let videoURLString = "\(OOTD_VideosURLs!)\(name)_f.mp4"
            print(videoURLString)
            cell.configure(with: URL(string: videoURLString)!)
        } else {
            cell.cellLbl.text = videoTemplateJSON["male"][indexPath.row]["name"].stringValue
            let name = videoTemplateJSON["male"][indexPath.row]["name"].stringValue
            let videoURLString = "\(OOTD_VideosURLs!)\(name)_m.mp4"
            print(videoURLString)
            cell.configure(with: URL(string: videoURLString)!)
        }
        if selectedIndex == indexPath.row {
            cell.contentView.borderColor = .fillPromptBG
            cell.contentView.borderWidth = 1
        } else {
            cell.contentView.borderColor = .clear
            cell.contentView.borderWidth = 0
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Deselect the previously selected cell
        presentInterstitialAd(viewController: self)
        if let previousCell = collectionView.cellForItem(at: IndexPath(row: selectedIndex, section: 0)) as? VideoTemplateCollectionViewCell {
            previousCell.contentView.borderColor = .clear
            previousCell.contentView.borderWidth = 0
        }
        
        // Update selected index path
        selectedIndex = indexPath.row
        
        // Apply border to the newly selected cell
        if let currentCell = collectionView.cellForItem(at: indexPath) as? VideoTemplateCollectionViewCell {
            currentCell.contentView.borderColor = .fillPromptBG
            currentCell.contentView.borderWidth = 1
        }
        
        templateCollectionView.scrollToItem(at: IndexPath(row: selectedIndex, section: 0), at: .centeredHorizontally, animated: true)
        
//        templateCollectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? VideoTemplateCollectionViewCell {
            cell.contentView.borderColor = .clear
            cell.contentView.borderWidth = 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch UIDevice.current.userInterfaceIdiom{
            
        case .phone:
            let height = collectionView.frame.size.height
            let width = (334/436) * height
            return CGSize(width: width, height: height)
            
        case .pad:
            let height = collectionView.frame.size.height
            let width = (334/436) * height
            return CGSize(width: width, height: height)
            
        default:
            return CGSize()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat{
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
}


extension OotdVideoViewController : CustomLibraryPickerControllerDelegate {
    func singleImagePick(_ didSelectImage: UIImage) {
        DispatchQueue.main.async { [self] in
            let newImage = manageImageSize(amount: 1300, selectedImage: didSelectImage)
            let customCropVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CustomCropperViewController") as! CustomCropperViewController
            customCropVC.actualImage = didSelectImage
            customCropVC.delegate = self
            self.present(customCropVC, animated: true)
        }
    }
}

extension OotdVideoViewController: CustomDelegateCrop {
    func croppedImageFunc(image: UIImage) {
        userImage = image
        imageView.image = userImage
        imageDisplayView.cornerRadius = 15
        imageDisplayView.borderWidth = 2
        imageDisplayView.borderColor = .borderGreen
        DispatchQueue.main.async {
            self.calculateViewDimensions()
            self.view.layoutIfNeeded()
        }
    }
}

extension OotdVideoViewController: GADBannerViewDelegate{
    
    func loadBannerAd() {
        let adaptiveSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(self.view.frame.size.width)
        bannerView = GADBannerView(adSize: adaptiveSize)
        bannerView.adUnitID = bannerOotdVideoViewController
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
