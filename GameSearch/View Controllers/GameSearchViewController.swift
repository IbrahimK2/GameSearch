//
//  ViewController.swift
//  GameSearch
//
//  Created by Ibrahim Kurabi on 2018-05-21.
//  Copyright © 2018 Ibrahim Kurabi. All rights reserved.
//

import UIKit

class GameSearchViewController: UITableViewController {

    let client = GiantBombClient()
    var searchResults = [VideoGame]()
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavbar()
    }
    
    func setupNavbar() {
        searchController.searchBar.placeholder = "Search by game title"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController?.searchBar.delegate = self
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = searchResults[indexPath.row].name
        
        return cell
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showGameDetail" {
            let detailVC = segue.destination as! GameDetailTableViewController
            detailVC.game = searchResults[(self.tableView.indexPathForSelectedRow?.row)!]
        }
    }
}

extension GameSearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        guard let searchTerm = searchBar.text else { return }
        
        let params = ["field_list": "name,image,deck",
                      "query": searchTerm]
        
        client.request(resource: "searchh", withParameters: params) { (res) in
            switch res {
            case .response(let data):
                if let results = data.results {
                    self.searchResults = results
                    self.searchController.isActive = false
                    self.tableView.reloadData()
                    
                    if results.count == 0 {
                        let alertController = UIAlertController(title: "Could not find game", message: "Try a different game name", preferredStyle:.alert)
                        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            case .error(let error):
                self.searchController.isActive = false

                let alertController = UIAlertController(title: "Error Searching", message: (error as NSError).userInfo.debugDescription, preferredStyle:.alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
}
