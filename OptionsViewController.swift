//
//  FeedbackViewController.swift
//  TransitionsApp
//
//  Created by MacMini on 23/10/21.
//

import UIKit
import MessageUI
import StoreKit
import UserMessagingPlatform
import Photos

protocol OptionsPremiumPurchased {
    func optionsPremiumPurchased()
}

class OptionsViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
//    @IBOutlet var widthPro: NSLayoutConstraint!
    @IBOutlet var btnPro: UIButton!
    @IBOutlet var optionsCollectionView: UICollectionView!
    
    @IBOutlet weak var SetHeight: NSLayoutConstraint!
    
    var optionsPremiumProtocol : OptionsPremiumPurchased!
    var productResponse : SKProductsResponse!
    
    var status = PHPhotoLibrary.authorizationStatus()
    var optionsNameArray: [Int: [String]] = [0: ["My creation"], 1: ["Feedback", "Rate us", "Review"], 2: [ "Share App", "More Apps"], 3: ["GDPR Consent"]]
       var optionsNameArrayImgs: [Int: [String]] = [0: ["sc12My Creation"], 1: ["sc12Feedback", "sc12Rate Us", "sc12Review"], 2: ["sc12Share App", "sc12More App"], 3: ["sc12Consent From"]]
    
    override func viewDidLoad() {
        print(UMPConsentInformation.sharedInstance.privacyOptionsRequirementStatus == .required)
        super.viewDidLoad()
        SetTopBarHeight(constraint: SetHeight)
        optionsCollectionView.delegate = self
        optionsCollectionView.dataSource = self
        let layout = UICollectionViewCompositionalLayout(section: layoutForMore())
        layout.register(SectionDecorationView.self, forDecorationViewOfKind: SectionDecorationView().kind)
        optionsCollectionView.setCollectionViewLayout(layout, animated: true)
//        if !purchased{
//            btnPro.isHidden = false
////            widthPro = changeMultiplier(widthPro, multiplier: 0.9)
//                       
//        }else{
//            btnPro.isHidden = true
////            widthPro = changeMultiplier(widthPro, multiplier: 0.001)
//        }
    }
    
    @IBAction func btnBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnPro(_ sender: UIButton) {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProViewController") as! ProViewController
        controller.premiumProtocol = self
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true, completion: nil)
    }
    
    func openMailApp() {
        let composer = MFMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            composer.mailComposeDelegate = self
            composer.setToRecipients([Constants.emailID])
            composer.setSubject("Review & Feedback for \(Bundle.appName())")
            composer.setMessageBody("I'm using \(UIDevice.modelName) (\(UIDevice.current.systemVersion)). App version \(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String)", isHTML: false)
            present(composer, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    private func layoutForMore() -> NSCollectionLayoutSection {
           let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
           
           if UIDevice.current.userInterfaceIdiom == .phone {
               let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(70)), subitems: [item])
               let section = NSCollectionLayoutSection(group: group)
               let decorationItem = NSCollectionLayoutDecorationItem.background(elementKind: SectionDecorationView().kind)
               decorationItem.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10)
               section.decorationItems = [decorationItem]
               section.orthogonalScrollingBehavior = .none
               return section
           } else {
               let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(120)), subitems: [item])
               let section = NSCollectionLayoutSection(group: group)
               let decorationItem = NSCollectionLayoutDecorationItem.background(elementKind: SectionDecorationView().kind)
               decorationItem.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10)
               section.decorationItems = [decorationItem]
               section.orthogonalScrollingBehavior = .none
               return section
           }
       }
    
    
}

extension OptionsViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if UMPConsentInformation.sharedInstance.privacyOptionsRequirementStatus != .required{
            return (optionsNameArray.count - 1)
        }else {
            return optionsNameArray.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return optionsNameArray[section]!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "optionCell", for: indexPath) as! optionCell
        
        if optionsNameArray[indexPath.section]?.last != optionsNameArray[indexPath.section]?.first {
            if indexPath.row < optionsNameArray[indexPath.section]!.count - 1{
            }
        }
        
        if indexPath.section == 0{
           
        }
        cell.optionTypeName.text =  optionsNameArray[indexPath.section]![indexPath.row]
        cell.optionImage.image = UIImage(named: optionsNameArrayImgs[indexPath.section]![indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            if status == .authorized {
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MyCreationViewController") as! MyCreationViewController
                navigationController?.pushViewController(vc, animated: true)
            } else {
                alertForNoPhotoLibraryPermission()
            }
        case 1:
            switch indexPath.row {
            case 0:
                openMailApp()
            case 1:
                SKStoreReviewController.requestReview()
            case 2:
                let urlStr = Constants.reviewLink
                guard let url = URL(string: urlStr), UIApplication.shared.canOpenURL(url) else { return }
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            default: break
            }
        case 2:
            switch indexPath.row {
            case 0:
                if let name = URL(string: Constants.appShareLink), !name.absoluteString.isEmpty {
                    let objectsToShare = [name]
                    let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        activityVC.popoverPresentationController?.sourceView = self.view
                        activityVC.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.maxY, width: 0, height: 0)
                    }
                    self.present(activityVC, animated: true, completion: nil)
                }
            case 1:
                let urlStr = Constants.allProductsLink
                guard let url = URL(string: urlStr), UIApplication.shared.canOpenURL(url) else { return }
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            default: break
            }
        case 3:
            switch indexPath.row {
            case 0:
                UMPConsentForm.presentPrivacyOptionsForm(from: self) { error in
                    if error == nil {
                        
                    }else {
                        print(error!.localizedDescription)
                    }
                }
            default: break
            }
        default: break
        }
    }
    
}

extension OptionsViewController : PremiumPurchased {
    
    func premiumPurchased() {
        optionsPremiumProtocol.optionsPremiumPurchased()
        self.dismiss(animated: true, completion: nil)
    }
    
}

class optionCell: UICollectionViewCell {
    @IBOutlet var optionImage: UIImageView!
    @IBOutlet var optionTypeName: UILabel!
   
}

class SectionDecorationView: UICollectionReusableView {
    
    let kind: String = "SectionDecorationView"
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpViews(){
        self.backgroundColor = .unfillPromptBG
        layer.cornerRadius = 16
    }
    
}
