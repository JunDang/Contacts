//
//  ContactsTableTableViewController.swift
//  Contacts
//
//  Created by Jun Dang on 12/19/18.
//  Copyright © 2018 Jun Dang. All rights reserved.
//

protocol HandleButtonDelegate: class {
    func handleFavoriteMark(cell: UITableViewCell)
    func handleExpandClose(button: UIButton)
}

import UIKit
import Contacts

class ContactsTableTableViewController: UITableViewController, HandleButtonDelegate {
    
    let cellId = "cellId"
  
    var contactsDictionary = [String: ExpandableNames]()
    var familyArray = [String]()
    var familyKeys = [String]()
    
    private func fetchContacts() {
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { (granted, error) in
            if let error = error {
                print("failed to request:", error)
                return
            }
            if granted {
                let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
                let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                do {
                    
                    var favoritableContacts = [FavoritableContact]()
                    var familyKeysWithDuplicates = [String]()
                    
                    try store.enumerateContacts(with: request, usingBlock: { (contact, stopPointerIfYouWantToStopEnumerating) in
                        print(contact.givenName)
                        print(contact.familyName)
                        print(contact.phoneNumbers.first?.value.stringValue ?? "")
                        self.familyArray.append(contact.familyName)
                        familyKeysWithDuplicates = (self.familyArray.map{String($0.prefix(1))}).sorted()
                        favoritableContacts.append(FavoritableContact(contact: contact, hasFavorited: false))
                
                    })
                     for familyKey in familyKeysWithDuplicates {
                        var newFavoritableContacts = [FavoritableContact]()
                        for favoritableContact in favoritableContacts {
                            if favoritableContact.contact.familyName.prefix(1) == familyKey {
                                    newFavoritableContacts.append(favoritableContact)
                            }
                            let contacts = ExpandableNames(isExpanded: true, names: newFavoritableContacts)
                            self.contactsDictionary[familyKey] = contacts
                         }
                        
                    }
                    self.familyKeys = [String](self.contactsDictionary.keys).sorted()
            
                } catch let error {
                    print("Failed to enumerate contacts:", error)
                }
            } else {
                print("denied")
            }
        }
    }
    
    var showIndexPath = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchContacts()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Show IndexPath", style: .plain, target: self, action: #selector(handleShowIndexPath))
        navigationItem.title = "Contacts"
        navigationController?.navigationBar.prefersLargeTitles = true
        tableView.register(ContactCell.self, forCellReuseIdentifier: cellId)

    }
    @objc func handleShowIndexPath() {
        
        var indexPathsToReload = [IndexPath]()
     
        for section in familyKeys.indices {
            if let expandableNames = contactsDictionary[familyKeys[section]] {
               if expandableNames.isExpanded {
                   for row in expandableNames.names.indices {
                       let indexPath = IndexPath(row: row, section: section)
                        indexPathsToReload.append(indexPath)
                   }
                }
            }
        }
    
        showIndexPath = !showIndexPath
        let animationStyle = showIndexPath ? UITableView.RowAnimation.right : .left
        
        tableView.reloadRows(at: indexPathsToReload, with: animationStyle)
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = HeaderView()
        headerView.delegate = self
        headerView.backgroundColor = .yellow
        headerView.sectionLabel.text = familyKeys[section]
        headerView.button.tag = section
        return headerView
    }
    
    @objc func handleExpandClose(button: UIButton) {
        
        let section = button.tag
        var indexPaths = [IndexPath]()
        guard let expandableNames = contactsDictionary[familyKeys[section]] else {
            return
        }
        
        for row in expandableNames.names.indices {
            let indexPath = IndexPath(row: row, section: section)
            indexPaths.append(indexPath)
        }
        let isExpanded = expandableNames.isExpanded
        expandableNames.isExpanded = !isExpanded
        button.setTitle(isExpanded ? "Open" : "Close", for: .normal)
        
        if isExpanded {
            tableView.deleteRows(at: indexPaths, with: .fade)
        } else {
            tableView.insertRows(at: indexPaths, with: .fade)
        }
        
        
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return contactsDictionary.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       guard let expandableNames = contactsDictionary[familyKeys[section]] else {
            return 0
        }
        if expandableNames.isExpanded == false {
            return 0
        }
        let count = expandableNames.names.count
        return count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return familyKeys.sorted()[section]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       // let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ContactCell
        let cell = ContactCell(style: .subtitle, reuseIdentifier: cellId)
        cell.delegate = self
        let favoritableContact = contactsDictionary[familyKeys[indexPath.section]]?.names[indexPath.row]
        if let favoritableContact = favoritableContact {
        
             cell.textLabel?.text = favoritableContact.contact.givenName + " " + favoritableContact.contact.familyName
             cell.detailTextLabel?.text = favoritableContact.contact.phoneNumbers.first?.value.stringValue
             cell.accessoryView?.tintColor = favoritableContact.hasFavorited ? .red : .lightGray
             if showIndexPath {
                 cell.textLabel?.text = "\(favoritableContact.contact.givenName) Section: \(indexPath.section) Row: \(indexPath.row)"
             }
        }
       
        return cell
    }
    
    func handleFavoriteMark(cell: UITableViewCell) {
       
        guard  let indexPathTapped = tableView.indexPath(for: cell) else {
            return
        }
        guard let expandableNames = contactsDictionary[familyKeys[indexPathTapped.section]] else {
            return
        }
        let favoritableContact = expandableNames.names[indexPathTapped.row]
        
        let hasFavorited = favoritableContact.hasFavorited
        favoritableContact.hasFavorited = !hasFavorited
        cell.accessoryView?.tintColor = hasFavorited ? .lightGray : .red
    }
}
