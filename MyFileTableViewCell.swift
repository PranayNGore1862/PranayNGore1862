//
//  MyFileTableViewCell.swift
//  AI_Noise_Remover_APP
//
//  Created by PGNV on 24/09/25.
//

import UIKit

class MyFileTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var fileName: UILabel!
    @IBOutlet weak var selectBtn: UIButton!
    
    var onSelectTapped: (() -> Void)?
    
    @IBAction func selectButton(_ sender: UIButton) {
        onSelectTapped?()
    }
    
    
}
