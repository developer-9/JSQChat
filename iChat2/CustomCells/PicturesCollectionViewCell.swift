//
//  PicturesCollectionViewCell.swift
//  iChat2
//
//  Created by Taisei Sakamoto on 2020/05/07.
//  Copyright © 2020 Taisei Sakamoto. All rights reserved.
//

import UIKit

class PicturesCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var imageView: UIImageView!
    
    func generateCell(image: UIImage) {
        
        self.imageView.image = image
    }
}
