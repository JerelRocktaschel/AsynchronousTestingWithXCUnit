//
//  ViewController.swift
//  NetworkTest
//
//  Created by Jerel Rocktaschel rMBP on 2/11/21.
//  Copyright © 2021 HighScoreApps. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        //call getToDo
        let networkManager = NetworkManager()
        networkManager.getToDo { toDo, error in
            guard let toDo = toDo else {
                return
            }
            print(toDo.title)
        }
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
}

