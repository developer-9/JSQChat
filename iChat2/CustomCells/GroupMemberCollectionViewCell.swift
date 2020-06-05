//
//  GroupMemberCollectionViewCell.swift
//  iChat2
//
//  Created by Taisei Sakamoto on 2020/05/11.
//  Copyright © 2020 Taisei Sakamoto. All rights reserved.
//

import UIKit

protocol GroupMemberCollectionViewCellDelegate {
    func didClickDeleteButton(indexPath: IndexPath)
}

class GroupMemberCollectionViewCell: UICollectionViewCell {
    
    var indexPath: IndexPath!
    var delegate: GroupMemberCollectionViewCellDelegate?
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!

    
    func generateCell(user: FUser, indexPath: IndexPath) {
        
        self.indexPath = indexPath
        nameLabel.text = user.firstname
        
        if user.avatar != "" {
            
            imageFromData(pictureData: user.avatar) { (avatarImage) in
                
                if avatarImage != nil {
                    
                    self.avatarImageView.image = avatarImage!.circleMasked
                }
            }
        }
    }
    
    
    //MARK: IBActions
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        delegate!.didClickDeleteButton(indexPath: indexPath)
    }
}
