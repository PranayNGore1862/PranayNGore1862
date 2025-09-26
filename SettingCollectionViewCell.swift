//
//  SettingCollectionViewCell.swift
//  AI_Noise_Remover_APP
//
//  Created by PGNV on 24/09/25.
//

import UIKit

class SettingCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
        
    }
}
