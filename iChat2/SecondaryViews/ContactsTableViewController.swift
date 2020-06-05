//
//  ContactsTableViewController.swift
//  iChat2
//
//  Created by Taisei Sakamoto on 2020/05/10.
//  Copyright © 2020 Taisei Sakamoto. All rights reserved.
//

import UIKit
import FirebaseFirestore
import ProgressHUD

class ContactsTableViewController: UITableViewController, UISearchResultsUpdating, UserTableViewCellDelegate {
    
    var allUsers: [FUser] = []
    var filteredUsers: [FUser] = []
    var allUsersGroupped = NSDictionary() as! [String: [FUser]]
    var sectionTitleList: [String] = []
    
    let searchController = UISearchController(searchResultsController: nil)

    var isGroup = false
    
    var memberIdsOfGroupChat: [String] = []
    var membersOfGroupChat: [FUser] = []
        
    override func viewWillAppear(_ animated: Bool) {
        
        //to remove empty cell lines
        tableView.tableFooterView = UIView()
        
        loadUsers()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        title = "Contacts"
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.searchController = searchController
            
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
                
        setupButtons()
    }
        
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        if searchController.isActive && searchController.searchBar.text != "" {
            
            return 1
            
        } else {
            
            return allUsersGroupped.count
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchController.isActive && searchController.searchBar.text != "" {
            
            return filteredUsers.count
            
        } else {
            
            //find section title
            let sectionTitle = self.sectionTitleList[section]
            
            //user for given Title
            let users = self.allUsersGroupped[sectionTitle]
            
            return users!.count
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! UserTableViewCell
        
        var user: FUser
        
        if searchController.isActive && searchController.searchBar.text != "" {
            
            user = filteredUsers[indexPath.row]
            
        } else {
            
            let sectionTitle = self.sectionTitleList[indexPath.section]
            let users = self.allUsersGroupped[sectionTitle]
            
            user = users![indexPath.row]
        }
        
        //**fUser: allUsers[indexPath.row] **
        cell.generateCellWith(fUser: user, indexPath: indexPath)
        cell.delegate = self
        
        return cell
    }

    
    //MARK: TableView Delegate
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 70
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if searchController.isActive && searchController.searchBar.text != "" {
            
            return ""
            
        } else {
            
            return self.sectionTitleList[section]
        }
    }
        
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        
        if searchController.isActive && searchController.searchBar.text != "" {
            
            return nil
            
        } else {
            
            return self.sectionTitleList
        }
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        
        return index
    }

        
    //MARK: TableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        var user: FUser
        
        if searchController.isActive && searchController.searchBar.text != "" {
            
            user = filteredUsers[indexPath.row]
        } else {
            
            let sectionTitle = self.sectionTitleList[indexPath.section]
            let users = self.allUsersGroupped[sectionTitle]
            
            user = users![indexPath.row]
        }
        
        if !isGroup {
            //1 on 1 chat
            
            if !checkBlockedStatus(withUser: user) {
                
                let chatVC = ChatViewController()
                chatVC.titleName = user.firstname
                chatVC.membersToPush = [FUser.currentId(), user.objectId]
                chatVC.memberIds = [FUser.currentId(), user.objectId]
                chatVC.chatRoomId = startPrivateChat(user1: FUser.currentUser()!, user2: user)
                
                chatVC.isGroup = false
                chatVC.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(chatVC, animated: true)
            } else {
                ProgressHUD.showError("This user is not available for chat!")
            }
        } else {
            //group chat
            
            //checkmarks
            if let cell = tableView.cellForRow(at: indexPath) {
                
                if cell.accessoryType == .checkmark {
                    cell.accessoryType = .none
                } else {
                    cell.accessoryType = .checkmark
                }
            }
            
            //add/remove user from the array
            let selected = memberIdsOfGroupChat.contains(user.objectId)
            
            if selected {
                let objectIndex = memberIdsOfGroupChat.index(of: user.objectId)
                
                memberIdsOfGroupChat.remove(at: objectIndex!)
                membersOfGroupChat.remove(at: objectIndex!)
            } else {
                
                memberIdsOfGroupChat.append(user.objectId)
                membersOfGroupChat.append(user)
            }
            
            self.navigationItem.rightBarButtonItem?.isEnabled = memberIdsOfGroupChat.count > 0
        }
    }
    
    //MARK: IBActions
    
    @objc func inviteButtonPressed() {
        
        let text = "Hey! Lets chat on iChat \(kAPPURL)"
        
        let objectsToShare:[Any] = [text]
        
        let activityViewController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        
        activityViewController.popoverPresentationController?.sourceView = self.view
        
        activityViewController.setValue("Lets Chat on iChat", forKey: "subject")
        
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @objc func searchNearByButtonPressed() {
                
        let userVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "usersTableView") as! UsersTableViewController
        
        self.navigationController?.pushViewController(userVC, animated: true)
    }
    
    @objc func nextButtonPressed() {
                
        let newGroupVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "newGroupView") as! NewGroupViewController

        newGroupVC.memberIds = memberIdsOfGroupChat
        newGroupVC.allMembers = membersOfGroupChat

        self.navigationController?.pushViewController(newGroupVC, animated: true)
    }

    
    //MARK: LoadUsers
    
    func loadUsers() {
        
        ProgressHUD.show()
        
        var query: Query!
        
        query = reference(.User).order(by: kFIRSTNAME, descending: false)
        
        
        query.getDocuments { (snapshot, error) in
            
            self.allUsers = []
            self.sectionTitleList = []
            self.allUsersGroupped = [:]
            
            if error != nil {
                
                print(error!.localizedDescription)
                ProgressHUD.dismiss()
                self.tableView.reloadData()
                
                return
            }
            
            guard let snapshot = snapshot else {
                ProgressHUD.dismiss(); return
            }
            
            if !snapshot.isEmpty {
                
                for userDictionary in snapshot.documents {
                    
                    let userDictionary = userDictionary.data() as NSDictionary
                    let fUser = FUser(_dictionary: userDictionary)
                    
                    if fUser.objectId != FUser.currentId() {
                        
                        self.allUsers.append(fUser)
                    }
                }
                
                self.splitDataIntoSection()
                self.tableView.reloadData()
            }
            
            self.tableView.reloadData()
            ProgressHUD.dismiss()
        }
        
    }
     

    //MARK: Helper functions
    
    fileprivate func splitDataIntoSection() {
        
        var sectionTitle: String = ""
        
        for i in 0..<self.allUsers.count {
            
            let currentUser = self.allUsers[i]
            
            let firstChar = currentUser.firstname.first!
            
            let firstCarString = "\(firstChar)"
            
            
            if firstCarString != sectionTitle {
                
                sectionTitle = firstCarString
                
                self.allUsersGroupped[sectionTitle] = []
                
                if !sectionTitleList.contains(sectionTitle) {
                    self.sectionTitleList.append(sectionTitle)
                }
            }
            
            self.allUsersGroupped[firstCarString]?.append(currentUser)
        }
    }

    
    //MARK: Search controller functions
    
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        
        filteredUsers = allUsers.filter({ (user) -> Bool in
            
            return user.firstname.lowercased().contains(searchText.lowercased())
        })
        
        tableView.reloadData()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
         
        filterContentForSearchText(searchText: searchController.searchBar.text!)
     }
    
    
    //MARK: UserTableViewCellDelegate
    
    func didTapAvatarImage(indexPath: IndexPath) {
        
        let profileVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "profileView") as! ProfileViewTableViewController
        
        var user: FUser
        
        if searchController.isActive && searchController.searchBar.text != "" {
            
            user = filteredUsers[indexPath.row]
            
        } else {
            
            let sectionTitle = self.sectionTitleList[indexPath.section]
            
            let users = self.allUsersGroupped[sectionTitle]
            
            user = users![indexPath.row]
        }
        
        profileVC.user = user
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    
    //MARK: Helpers
    
    func setupButtons() {
        
        if isGroup {
            //for group chat
            let nextButton = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(self.nextButtonPressed))
            self.navigationItem.rightBarButtonItem = nextButton
            self.navigationItem.rightBarButtonItems!.first!.isEnabled = false
            
        } else {
            //for 1 on 1 chat
            let inviteButton = UIBarButtonItem(image: UIImage(named: "invite"), style: .plain, target: self, action: #selector(self.inviteButtonPressed))
            
            let searchButton = UIBarButtonItem(image: UIImage(named: "nearMe"), style: .plain, target: self, action: #selector(self.searchNearByButtonPressed))
            
            self.navigationItem.rightBarButtonItems = [inviteButton, searchButton]
        }
    }
}
