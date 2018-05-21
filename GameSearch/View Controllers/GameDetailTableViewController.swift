//
//  GameDetailTableViewController.swift
//  GameSearch
//
//  Created by Ibrahim Kurabi on 2018-05-21.
//  Copyright © 2018 Ibrahim Kurabi. All rights reserved.
//

import UIKit

class GameDetailTableViewController: UITableViewController {

    var game: VideoGame?
    
    @IBOutlet weak var gameDescription: UILabel!
    @IBOutlet weak var gameScreenshot: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = game?.name ?? ""
        gameDescription.text = game?.deck ?? "No description available."
        loadScreenshot()
    }
    
    func loadScreenshot() {
        spinner.isHidden = false
        if let game = self.game, let image = game.image, let imgString = image["thumbUrl"], let urlString = imgString {
            guard let url = URL(string: urlString) else { return }
            
            DispatchQueue.global().async {
                do {
                    let data = try Data(contentsOf: url)
                    DispatchQueue.main.async {
                        self.spinner.isHidden = true
                        self.gameScreenshot.image = UIImage(data: data)
                    }
                } catch let imgError {
                    print(imgError)
                }
            }
            
        }
    }

}
