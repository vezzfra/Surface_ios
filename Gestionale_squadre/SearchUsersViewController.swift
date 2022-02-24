//
//  SearchUsersViewController.swift
//  Gestionale_squadre
//
//  Created by Francesco Vezzoli on 15/12/2018.
//  Copyright © 2018 Ro.v.er. All rights reserved.
//

import UIKit
import Parse

class SearchUsersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var utenti = [String]()
    var utentiFiltrati = [String]()
    var usersArray = [String]()
    var delegate = GestioneSquadreViewController()
    var tag = 0
    var firstMember: String = String()
    var secondMember: String = String()
    var thirdMember: String = String()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.tableHeaderView = searchController.searchBar
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let username = UserDefaults.standard.object(forKey: "app_username") as! String
        self.usersArray.append(username)
        
        if !self.firstMember.isEmpty {
            self.usersArray.append(self.firstMember)
        }
        if !self.secondMember.isEmpty {
            self.usersArray.append(self.secondMember)
        }
        if !self.thirdMember.isEmpty {
            self.usersArray.append(self.thirdMember)
        }
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        
        let query = PFQuery(className: "users")
        query.whereKey("username", notContainedIn: self.usersArray)
        query.limit = 10000
        query.findObjectsInBackground { (users, error) in
            if error == nil {
                for user in users! {
                    self.utenti.append(user["username"] as! String)
                }
                self.tableView.reloadData()
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }

    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        tableView.deselectRow(at: indexPath, animated: true)
        if isFiltering() {
            self.delegate.updateTextField(tag: self.tag, user: self.utentiFiltrati[indexPath.row])
        } else {
            self.delegate.updateTextField(tag: self.tag, user: self.utenti[indexPath.row])
        }
        self.dismiss(animated: true, completion: nil)
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath)
        if isFiltering() {
            cell.textLabel?.text = self.utentiFiltrati[indexPath.row]
        } else {
            cell.textLabel?.text = self.utenti[indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return self.utentiFiltrati.count
        } else {
            return self.utenti.count
        }
    }
    
    @IBAction func close(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        utentiFiltrati = utenti.filter({( user : String) -> Bool in
            return user.lowercased().contains(searchText.lowercased())
        })
        self.tableView.reloadData()
    }
    
}

extension SearchUsersViewController: UISearchResultsUpdating {
    
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
