//
//  SettingViewController.swift
//  AI_Noise_Remover_APP
//
//  Created by PGNV on 17/09/25.
//

import UIKit

struct SettingItem {
    let title: String
    let icon: String   // SF Symbol name or asset name
}


class SettingViewController: UIViewController, UICollectionViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBAction func backButton(_ sender: UIButton) {
            self.navigationController?.popViewController(animated: true)}
    
    // Sections data
    let sections: [[SettingItem]] = [
        [
            SettingItem(title: "My Creation", icon: "My creation"),
            SettingItem(title: "Share App", icon: "Share App"),
            SettingItem(title: "Rate Us", icon: "Rate_us"),
            SettingItem(title: "Privacy Policy", icon: "Privacy Policy"),
            SettingItem(title: "GDPR", icon: "GDPR")
        ],
        [
            SettingItem(title: "More Apps", icon: "More Apps"),
            SettingItem(title: "Feed Back", icon: "Feed Back"),
            SettingItem(title: "Review", icon: "Review")
        ]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.collectionViewLayout = createLayout()

    }
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, _ in
            
            // Item
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(55)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            // Group
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(50)
            )
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
            
            // Section
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 16, trailing: 0)
            section.interGroupSpacing = 1 // spacing between cells (like divider)
            
            return section
        }
    }
}

extension SettingViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectioncell", for: indexPath) as! SettingCollectionViewCell
        let item = sections[indexPath.section][indexPath.item]
        
        cell.titleLabel.text = item.title
        cell.iconImageView.image = UIImage(named: item.icon)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = sections[indexPath.section][indexPath.item]
        if item.title == "My Creation" {
            let myfileVC = storyboard?.instantiateViewController(withIdentifier: "MyFileViewController") as! MyFileViewController
            self.navigationController?.pushViewController(myfileVC, animated: true)
        }
    }
}
