//
//  HomeViewController.swift
//  CarRepos
//
//  Created by Vamshi Krishna on 08/11/17.
//  Copyright © 2017 VamshiKrishna. All rights reserved.
//

import UIKit
import CoreData

class HomeViewController: UIViewController {
    
    var managedObjectContext:NSManagedObjectContext!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func fetchCarsClicked(_ sender: Any) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "segueMyVehicles"){
            let controller = segue.destination as! MyVehicleViewController
            controller.managedObjectContext = managedObjectContext
        }
    }
}

