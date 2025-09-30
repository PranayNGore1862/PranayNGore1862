//
//  SeeAllFittingViewController.swift
//  AIOOTD
//
//  Created by beetonz Mac Mini on 23/01/25.
//

import UIKit
import Alamofire
import SwiftyJSON

protocol FittingSeeAllDelegate {
    func modelGarmentTapped(index: Int, tag: Int)
}

class SeeAllFittingViewController: UIViewController {

    var currentJson: [String]!
    var currentTag: Int!
    
    var userThumbImage: [UIImage] = []
    
    @IBOutlet var headerLbl: UILabel!
    @IBOutlet var allFittingCollectionView: UICollectionView!
    
    var delegate: FittingSeeAllDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if currentTag == 0 {
            headerLbl.text = "Models"
        } else {
            headerLbl.text = "Garments"
        }
        setupCollectionView()
        downloadImage(at: 0)
    }
    
    func setupCollectionView(){
        let layout = CHTCollectionViewWaterfallLayout()
        layout.minimumColumnSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.columnCount = 2
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        allFittingCollectionView.alwaysBounceVertical = true
        allFittingCollectionView.collectionViewLayout = layout
    }
    
    func downloadImage(at index: Int) {
        let imageUrl = URL(string: currentJson[index])!
        AF.download(imageUrl, method: .get).responseData { [self] response in
            switch response.result {
            case .success(let data):
                if let image = UIImage(data: data) {
                    userThumbImage.append(image)
                    allFittingCollectionView.delegate = self
                    allFittingCollectionView.dataSource = self
                    allFittingCollectionView.reloadData()
                    if index == currentJson.count - 1 {
                        //
                    } else {
                        downloadImage(at: index + 1)
                    }
                } else {
                    //
                }
            case .failure(_):
                break
            }
        }
    }
    
    
    @IBAction func closeBtnTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
}

extension SeeAllFittingViewController : UICollectionViewDelegate,UICollectionViewDataSource, CHTCollectionViewDelegateWaterfallLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userThumbImage.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FittingSeeAllCollectionViewCell", for: indexPath) as! FittingSeeAllCollectionViewCell
        cell.cellImage.image = userThumbImage[indexPath.row]
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate.modelGarmentTapped(index: indexPath.row, tag: currentTag)
        self.dismiss(animated: true)
    }
    
    func collectionViewWater(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let imageSize = userThumbImage[indexPath.row].size
        return imageSize
    }
}
