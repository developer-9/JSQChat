//
//  ProfileViewTableViewController.swift
//  iChat2
//
//  Created by Taisei Sakamoto on 2020/04/25.
//  Copyright © 2020 Taisei Sakamoto. All rights reserved.
//

import UIKit
import ProgressHUD

class ProfileViewTableViewController: UITableViewController {
    
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var messageButtonOutlet: UIButton!
    @IBOutlet weak var callButtonOutlet: UIButton!
    @IBOutlet weak var blockButtonOutlet: UIButton!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    var user: FUser?
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    
    //MARK: IBActions
    
    @IBAction func callButtonPressed(_ sender: Any) {
        
        print("call user \(user!.fullname)")
    }
    
    @IBAction func messageButtonPressed(_ sender: Any) {
        
        print("chat user \(user!.fullname)")
        
        if !checkBlockedStatus(withUser: user!) {
            
            let chatVC = ChatViewController()
            chatVC.titleName = user!.firstname
            chatVC.membersToPush = [FUser.currentId(), user!.objectId]
            chatVC.memberIds = [FUser.currentId(), user!.objectId]
            chatVC.chatRoomId = startPrivateChat(user1: FUser.currentUser()!, user2: user!)
            
            chatVC.isGroup = false
            chatVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(chatVC, animated: true)
        } else {
            ProgressHUD.showError("This user is available for chat!")
        }
    }
    
    @IBAction func blockUserButtonPressed(_ sender: Any) {
        
        var currentBlockedIds = FUser.currentUser()!.blockedUsers
        
        if currentBlockedIds.contains(user!.objectId) {
            currentBlockedIds.remove(at: currentBlockedIds.index(of: user!.objectId)!)
        } else {
            currentBlockedIds.append(user!.objectId)
        }
        
        updateCurrentUserInFirestore(withValues: [kBLOCKEDUSERID : currentBlockedIds]) { (error) in
            
            if error != nil {
                print("error updating user \(error!.localizedDescription)")
                return
            }
            
            self.updateBlockStatus()
        }
        
        blockUser(userToBlock: user!)
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0 {
            return 0
        }
        return 30
    }

    
    //MARK: setupUI
    
    func setupUI() {
        
        if user != nil {
            
            self.title = "Profile"
            
            fullNameLabel.text = user!.fullname
            phoneNumberLabel.text = user!.phoneNumber
            
            updateBlockStatus()
            
            imageFromData(pictureData: user!.avatar) { (avatarImage) in
                
                if avatarImage != nil {
                    self.avatarImageView.image = avatarImage!.circleMasked
                }
            }
        }
    }
    
    func updateBlockStatus() {
        
        if user!.objectId != FUser.currentId() {
            blockButtonOutlet.isHidden = false
            messageButtonOutlet.isHidden = false
            callButtonOutlet.isHidden = false
        } else {
            blockButtonOutlet.isHidden = true
            messageButtonOutlet.isHidden = true
            callButtonOutlet.isHidden = true
        }
        
        if FUser.currentUser()!.blockedUsers.contains(user!.objectId) {
            
            blockButtonOutlet.setTitle("Unblock User", for: .normal)
        } else {
            blockButtonOutlet.setTitle("Block User", for: .normal)
        }
    }
}
