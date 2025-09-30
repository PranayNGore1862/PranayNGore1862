//
//  FittingRoomViewController.swift
//  AIOOTD
//
//  Created by beetonz Mac Mini on 23/01/25.
//

import UIKit
import QCropper
import Kingfisher
import Alamofire
import Photos
import GoogleMobileAds

class FittingRoomViewController: UIViewController, PremiumPurchased {

    
    @IBOutlet var decLbl: UILabel!
    @IBOutlet var typeBtns: [UIButton]!
    @IBOutlet var genderBtn: UIButton!
    @IBOutlet var modelImageView: UIImageView!
    @IBOutlet var garmentImageView: UIImageView!
    @IBOutlet var modelCollectionView: UICollectionView!
    @IBOutlet var garmentCollectionView: UICollectionView!
    @IBOutlet  var SetHeight: NSLayoutConstraint!
    @IBOutlet var bottomConstraint:NSLayoutConstraint!
    @IBOutlet var bottomSuperView: UIView!
    var bannerView:GADBannerView!
    var currentSelImageTag = 0
    
    
    var modelImage: UIImage!
    var garmentImage: UIImage!
    var genderTag: Int = 0
    var typeTag: Int = 0
    
    var modelsArr: [Int:[String]] = [:]
    var clothesArr: [Int:[String]] = [:]
    
    
    let clothesPackages: [String] = [
        "AI_OOTD_TV/AI_OOTD_Top",
        "AI_OOTD_TV/AI_OOTD_Bottom",
        "AI_OOTD_TV/AI_OOTD_One_Piece"
    ]
    
    let modelPackages: [String] = [
        "AI_OOTD_TV/AI_OOTD_Models/AI_OOTD_Models_Female",
        "AI_OOTD_TV/AI_OOTD_Models/AI_OOTD_Models_Male"
    ]
    
    
    var selectedModelInd: Int = -1
    var selectedClothInd: Int = -1
     
    override func viewDidLoad() {
        super.viewDidLoad()
        SetTopBarHeight(constraint: SetHeight)
        if creditLeft <= freeCredits {
            bottomConstraint.constant = 75
            loadBannerAd()
        } else {
            bottomConstraint.constant = 15
        }
        decLbl.text = "\(fittingRoomDecAmount)"
        
        featureSelect = .fittingRoom
        
        modelImageView.image = UIImage(named: "sc5Model Image")
        garmentImageView.image = UIImage(named: "sc5Garment Image")
        
        typeBtns.forEach({$0.isSelected = false})
        typeBtns[typeTag].isSelected = true
        allTapGesture()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){ [self] in
            loadDataFromServer(package: modelPackages[genderTag], completion: { [self] resArr in
                modelsArr[genderTag] = resArr
                modelCollectionView.delegate = self
                modelCollectionView.dataSource = self
            })
            
            loadDataFromServer(package: clothesPackages[typeTag], completion: { [self] resArr in
                clothesArr[typeTag] = resArr
                garmentCollectionView.delegate = self
                garmentCollectionView.dataSource = self
            })
        }
        
    }
    
    @IBAction func genderBtnTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        selectedModelInd = -1
        if !sender.isSelected {
            genderTag = 0
            loadDataFromServer(package: modelPackages[genderTag], completion: { [self] resArr in
                modelsArr[genderTag] = resArr
                modelCollectionView.reloadData()
                modelCollectionView.scrollToItem(at: IndexPath(row: selectedModelInd, section: 0), at: .centeredHorizontally, animated: true)
            })
        } else {
            genderTag = 1
            loadDataFromServer(package: modelPackages[genderTag], completion: { [self] resArr in
                modelsArr[genderTag] = resArr
                modelCollectionView.reloadData()
                modelCollectionView.scrollToItem(at: IndexPath(row: selectedModelInd, section: 0), at: .centeredHorizontally, animated: true)
            })
        }
    }
    
    @IBAction func typeChanged(_ sender: UIButton) {
        presentInterstitialAd(viewController: self)
        selectedClothInd = -1
        typeTag = sender.tag
        typeBtns.forEach({$0.isSelected = false})
        typeBtns[typeTag].isSelected = true
        loadDataFromServer(package: clothesPackages[typeTag], completion: { [self] resArr in
            clothesArr[typeTag] = resArr
            garmentCollectionView.reloadData()
            garmentCollectionView.scrollToItem(at: IndexPath(row: selectedClothInd, section: 0), at: .centeredHorizontally, animated: true)
        })
    }
    
    
    @IBAction func generateBtnTapped(_ sender: UIButton) {
        if modelImage != nil && garmentImage != nil {
            if creditLeft >= fittingRoomDecAmount {
                var typeString = ""
                if typeTag == 0 {
                    typeString = "upperInput"
                } else if typeTag == 1 {
                    typeString = "lowerInput"
                } else if typeTag == 2 {
                    typeString = "dressInput"
                }
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FinalImagePreviewViewController") as! FinalImagePreviewViewController
                vc.userImage = modelImage
                vc.garmentImage = garmentImage
                vc.typeString = typeString
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
            showAlertBox(message: "Please Upload Image")
        }
    }
    
    
    @IBAction func seeAllModelTapped(_ sender: UIButton) {
        if !modelsArr.isEmpty {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SeeAllFittingViewController") as! SeeAllFittingViewController
            vc.currentJson = modelsArr[genderTag]
            vc.currentTag = 0
            vc.delegate = self
            navigationController?.present(vc, animated: true)
        }
    }
    
    
    @IBAction func seeAllGarmentTapped(_ sender: UIButton) {
        if !clothesArr.isEmpty {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SeeAllFittingViewController") as! SeeAllFittingViewController
            vc.currentJson = clothesArr[typeTag]
            vc.currentTag = 1
            vc.delegate = self
            navigationController?.present(vc, animated: true)
        }
    }
    
    
    
    
    @IBAction func backTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    func allTapGesture(){
        let sep1ImageTap = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        modelImageView.isUserInteractionEnabled = true
        modelImageView.addGestureRecognizer(sep1ImageTap)
        
        let sep2ImageTap = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        garmentImageView.isUserInteractionEnabled = true
        garmentImageView.addGestureRecognizer(sep2ImageTap)
    }
    
    @objc func imageTapped(_ tap: UITapGestureRecognizer){
        currentSelImageTag = tap.view!.tag
        print(currentSelImageTag)
        let customPicker = UIStoryboard(name: "CustomPhotoPicker", bundle: nil).instantiateViewController(withIdentifier: "CustomLibraryPickerController") as! CustomLibraryPickerController
        customPicker.mediaType = .image
        customPicker.placeHolderImage = UIImage(named: "gallery")
        customPicker.maxSelectedAssets = 1
        customPicker.isRecentFolder = true
        customPicker.pickerDelegate = self
        customPicker.modalPresentationStyle = .fullScreen
        self.present(customPicker, animated: true)
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
    
}

extension FittingRoomViewController: FittingSeeAllDelegate {
    func modelGarmentTapped(index: Int, tag: Int) {
        if tag == 0 {
            selectedModelInd = index
            modelCollectionView.reloadData()
            modelCollectionView.scrollToItem(at: IndexPath(row: selectedModelInd, section: 0), at: .centeredHorizontally, animated: true)
            AF.download(modelsArr[genderTag]![selectedModelInd], method: .get).responseData(completionHandler: { [self] response in
                switch response.result {
                case .success(let data):
                    modelImage = manageImageSize(amount: 1300, selectedImage: UIImage(data: data)!)
                    modelImageView.image = modelImage
                case .failure(_):
                    showAlertBox(message: "Something went wrong")
                }
            })
        } else if tag == 1 {
            selectedClothInd = index
            garmentCollectionView.reloadData()
            garmentCollectionView.scrollToItem(at: IndexPath(row: selectedClothInd, section: 0), at: .centeredHorizontally, animated: true)
            AF.download(clothesArr[typeTag]![selectedClothInd], method: .get).responseData(completionHandler: { [self] response in
                switch response.result {
                case .success(let data):
                    garmentImage = manageImageSize(amount: 1300, selectedImage: UIImage(data: data)!)
                    garmentImageView.image = garmentImage
                case .failure(_):
                    showAlertBox(message: "Something went wrong")
                }
            })
        }
    }
}

extension FittingRoomViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == modelCollectionView {
            return modelsArr[genderTag]!.count
        } else {
            return clothesArr[typeTag]!.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == modelCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FittingModelCollectionViewCell", for: indexPath) as! FittingModelCollectionViewCell
            cell.layoutIfNeeded()
            cell.cellImage.addShimming()
            let url = URL(string: modelsArr[genderTag]![indexPath.row])
            cell.cellImage.kf.setImage(with: url, options: [.transition(.fade(0.1)), .fromMemoryCacheOrRefresh], completionHandler: { _ in
                cell.cellImage.removeShimming()
            })
            if selectedModelInd == indexPath.row {
                cell.contentView.borderColor = .fillPromptBG
                cell.contentView.borderWidth = 3
            } else {
                cell.contentView.borderColor = .clear
                cell.contentView.borderWidth = 0
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FittingClothesCollectionViewCell", for: indexPath) as! FittingClothesCollectionViewCell
            cell.layoutIfNeeded()
            cell.cellImage.addShimming()
            let url = URL(string: clothesArr[typeTag]![indexPath.row])
            cell.cellImage.kf.setImage(with: url, options: [.transition(.fade(0.1)), .fromMemoryCacheOrRefresh], completionHandler: { _ in
                cell.cellImage.removeShimming()
            })
            if selectedClothInd == indexPath.row {
                cell.contentView.borderColor = .fillPromptBG
                cell.contentView.borderWidth = 3
            } else {
                cell.contentView.borderColor = .clear
                cell.contentView.borderWidth = 0
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == modelCollectionView {
            selectedModelInd = indexPath.row
            modelCollectionView.reloadData()
            modelCollectionView.scrollToItem(at: IndexPath(row: selectedModelInd, section: 0), at: .centeredHorizontally, animated: true)
            AF.download(modelsArr[genderTag]![indexPath.row], method: .get).responseData(completionHandler: { [self] response in
                switch response.result {
                case .success(let data):
                    modelImage = manageImageSize(amount: 1300, selectedImage: UIImage(data: data)!)
                    modelImageView.image = modelImage
                case .failure(_):
                    showAlertBox(message: "Something went wrong")
                }
            })
        } else {
            selectedClothInd = indexPath.row
            garmentCollectionView.reloadData()
            garmentCollectionView.scrollToItem(at: IndexPath(row: selectedClothInd, section: 0), at: .centeredHorizontally, animated: true)
            AF.download(clothesArr[typeTag]![indexPath.row], method: .get).responseData(completionHandler: { [self] response in
                switch response.result {
                case .success(let data):
                    garmentImage = manageImageSize(amount: 1300, selectedImage: UIImage(data: data)!)
                    garmentImageView.image = garmentImage
                case .failure(_):
                    showAlertBox(message: "Something went wrong")
                }
            })
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch UIDevice.current.userInterfaceIdiom {
            
        case .phone:
            if collectionView == modelCollectionView {
                let height = collectionView.frame.size.height
                let width = (2348/3572) * height
                return CGSize(width: width, height: height)
            } else {
                let height = collectionView.frame.size.height
                let width = (2348/3572) * height
                return CGSize(width: width, height: height)
            }
        case .pad:
            if collectionView == modelCollectionView {
                let height = collectionView.frame.size.height
                let width = (2348/3572) * height
                return CGSize(width: width, height: height)
            } else {
                let height = collectionView.frame.size.height
                let width = (2348/3572) * height
                return CGSize(width: width, height: height)
            }
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




extension FittingRoomViewController : CustomLibraryPickerControllerDelegate {
    func singleImagePick(_ didSelectImage: UIImage) {
        DispatchQueue.main.async { [self] in
            let newImage = manageImageSize(amount: 1300, selectedImage: didSelectImage)
            let cropper = CropperViewController(originalImage: newImage)
            cropper.delegate = self
            self.present(cropper, animated: true)
        }
    }
}

extension FittingRoomViewController : CropperViewControllerDelegate {
    func cropperDidConfirm(_ cropper: CropperViewController, state: CropperState?) {
        if let state = state,let image = cropper.originalImage.cropped(withCropperState: state){
            if currentSelImageTag == 0 {
                modelImage = image
                modelImageView.image = modelImage
                selectedModelInd = -1
                modelCollectionView.reloadData()
            } else if currentSelImageTag == 1 {
                garmentImage = image
                garmentImageView.image = garmentImage
                selectedClothInd = -1
                garmentCollectionView.reloadData()
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

extension FittingRoomViewController: GADBannerViewDelegate{
    
    func loadBannerAd() {
        let adaptiveSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(self.view.frame.size.width)
        bannerView = GADBannerView(adSize: adaptiveSize)
        bannerView.adUnitID = bannerFittingRoomViewController
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
