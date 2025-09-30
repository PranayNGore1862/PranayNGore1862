//
//  SeeAllOutfitViewController.swift
//  AIOOTD
//
//  Created by beetonz Mac Mini on 22/01/25.
//

import UIKit
import SwiftyJSON

protocol SeeAllDelegate {
    func selectCloth(index: Int)
}

class SeeAllOutfitViewController: UIViewController {

    var selectedTag: Int!
    var selectedIndex: Int!
    var currentJSON: [JSON]!
    
    
    @IBOutlet var allCollectionView: UICollectionView!
    
    var delegate: SeeAllDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        allCollectionView.delegate = self
        allCollectionView.dataSource = self
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [self] in
            allCollectionView.scrollToItem(at: IndexPath(row: selectedIndex, section: 0), at: .centeredVertically, animated: true)
        }
    }
    
    @IBAction func closeTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}

extension SeeAllOutfitViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentJSON[0].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SeeAllOutfitCollectionViewCell", for: indexPath) as! SeeAllOutfitCollectionViewCell
        if selectedIndex == indexPath.row {
            cell.contentView.borderColor = .green
            cell.contentView.borderWidth = 2
        } else {
            cell.contentView.borderColor = .clear
            cell.contentView.borderWidth = 0
        }
        cell.layoutIfNeeded()
        cell.cellImage.addShimming()
        let url = URL(string: currentJSON[0][indexPath.row][selectedTag == 0 ? "imageUrl" : "showcaseImageUrl"].stringValue)
        cell.cellImage.kf.setImage(with: url, options: [.transition(.fade(0.1)), .fromMemoryCacheOrRefresh], completionHandler: { _ in
            cell.cellImage.removeShimming()
        })
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        allCollectionView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [self] in
            delegate.selectCloth(index: selectedIndex)
            self.dismiss(animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch UIDevice.current.userInterfaceIdiom{
            
        case .phone:
            let width = (collectionView.frame.size.width/2) - 10
            let height = (1152/896)*width
            return CGSize(width: width, height: height)
            
        case .pad:
            let width = (collectionView.frame.size.width/3) - 10
            let height = (1152/896)*width
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
