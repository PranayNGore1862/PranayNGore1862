//
//  MyCreationViewController.swift
//  DeepFakeAI
//
//  Created by beetonz Mac Mini on 01/12/23.
//

import UIKit
import Photos
import GoogleMobileAds

class MyCreationViewController: UIViewController {

    var imageArray: [UIImage] = []
    var videoUrlArray : [URL] = []
    var videoThumbsArray : [UIImage] = []
    var tag: Int?
    @IBOutlet var myCollectionView: UICollectionView!
    @IBOutlet var noimage:UIImageView!
    @IBOutlet var allBtns: [UIButton]!
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
        allBtns.forEach({$0.isSelected = false})
        allBtns[0].isSelected = true
        tag = 0
        myCollectionView.delegate = self
        myCollectionView.dataSource = self
        
        setupCollectionView()
        allBtns.forEach({$0.isEnabled = false})
        
        PHPhotoLibrary.shared().getVideosFromAlbum(albumName: myAlbumName) { [self] videoURLs  in
            
            if videoURLs != nil {
                let videoURLsInSortedOrder = videoURLs!.sorted(by: {$0.url.lastPathComponent.localizedStandardCompare($1.url.lastPathComponent) == .orderedDescending })
                
                for i in (0..<(videoURLsInSortedOrder.count)) {
                    self.videoUrlArray.append(videoURLsInSortedOrder[i].url)
                    let yourThumbs = getThumbnailImage(forUrl: videoURLsInSortedOrder[i].url)
                    self.videoThumbsArray.append(yourThumbs!)
                    
                    if i == (videoURLsInSortedOrder.count - 1) {
                        self.myCollectionView.reloadData()
                    }
                }
            }
            DispatchQueue.main.async{ [self] in
                if videoUrlArray.count == 0 {
                    self.noimage.image = UIImage(named: "emptyVideo")
                    noimage.isHidden = false
                    myCollectionView.reloadData()
                } else {
                    noimage.isHidden = true
                    myCollectionView.reloadData()
                }
            }
        }
        
        PHPhotoLibrary.shared().getPhotosFromAlbum(albumName: myAlbumName, targetSize: nil) { yourImagesArr in
            if yourImagesArr!.count > 0{
                for index in 0..<yourImagesArr!.count {
                    self.imageArray.append(yourImagesArr![index])
                    
                    if index == (yourImagesArr!.count - 1) {
                        self.myCollectionView.reloadData()
                    }
                    
                }
                self.myCollectionView.reloadData()
            } else {
                //
            }
            
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [self] in
            allBtns.forEach({$0.isEnabled = true})
            if videoUrlArray.count > 0 || imageArray.count > 0 {
                // Load Banner AD
            }
        }
        
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        myCollectionView.reloadData()
    }
    
    @IBAction func allBtnsTapped(_ sender: UIButton) {
        allBtns.forEach({$0.isSelected = false})
        allBtns[sender.tag].isSelected = true
        if allBtns[sender.tag] == allBtns[0] {
            tag = 0
            if videoThumbsArray.count > 0 {
                self.noimage.isHidden = true
                DispatchQueue.main.async {
                    self.myCollectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                }
            } else {
                self.noimage.image = UIImage(named: "emptyVideo")
                self.noimage.isHidden = false
            }
            
            self.myCollectionView.reloadData()
        } else if allBtns[sender.tag] == allBtns[1] {
            tag = 1
            if imageArray.count > 0 {
                self.noimage.isHidden = true
                DispatchQueue.main.async {
                    self.myCollectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                }
            } else {
                self.noimage.image = UIImage(named: "emptyImage")
                self.noimage.isHidden = false
            }
            self.myCollectionView.reloadData()
        }
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    func setupCollectionView(){
        let layout = CHTCollectionViewWaterfallLayout()
        if UIDevice.current.userInterfaceIdiom == .phone {
            layout.columnCount = 2
        } else {
            layout.columnCount = 3
        }
        layout.minimumColumnSpacing = 5
        layout.minimumInteritemSpacing = 5
        myCollectionView.alwaysBounceVertical = true
        myCollectionView.collectionViewLayout = layout
    }
}

extension MyCreationViewController : UICollectionViewDelegate, UICollectionViewDataSource, CHTCollectionViewDelegateWaterfallLayout {
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if tag == 0 {
            return videoUrlArray.count
        } else if tag == 1 {
            return imageArray.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = myCollectionView.dequeueReusableCell(withReuseIdentifier: "MyCreCollectionViewCell", for: indexPath) as! MyCreCollectionViewCell
        if tag == 0 {
            cell.cellImage.image = videoThumbsArray[indexPath.row]
        } else if tag == 1 {
            cell.cellImage.image = imageArray[indexPath.row]
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // In CollectionView Did Select
        let cell = collectionView.cellForItem(at: indexPath)
        cell!.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        UIView.animate(withDuration: 0.2) {
            cell!.transform = .identity
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) { [self] in
            if tag == 0 {
                let preVc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PreviewViewController") as! PreviewViewController
                preVc.tag = tag
                preVc.videoURL = videoUrlArray[indexPath.row]
                navigationController?.pushViewController(preVc, animated: true)
            } else if tag == 1 {
                let preVc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PreviewViewController") as! PreviewViewController
                preVc.tag = tag
                preVc.thumbImage = imageArray[indexPath.row]
                navigationController?.pushViewController(preVc, animated: true)
            }
            
        }
        
    }
    
    func collectionViewWater(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if tag == 0 {
            let imageSize = videoThumbsArray[indexPath.row].size
            return imageSize
        } else if tag == 1 {
            let imageSize = imageArray[indexPath.row].size
            return imageSize
        }
        return CGSize()
    }
}


class MyCreCollectionViewCell: UICollectionViewCell {

    @IBOutlet var cellImage: UIImageView!
    
    // In CollectionView Cell
    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.2) {
                self.transform = self.isHighlighted ? CGAffineTransform(scaleX: 0.9, y: 0.9) : .identity
            }
        }
    }

}

extension MyCreationViewController: GADBannerViewDelegate{
    
    func loadBannerAd() {
        let adaptiveSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(self.view.frame.size.width)
        bannerView = GADBannerView(adSize: adaptiveSize)
        bannerView.adUnitID = bannerMyCreationViewController
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
