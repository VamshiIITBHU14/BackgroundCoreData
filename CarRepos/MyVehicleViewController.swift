//
//  MyVehicleViewController.swift
//  CarRepos
//
//  Created by Vamshi Krishna on 08/11/17.
//  Copyright © 2017 VamshiKrishna. All rights reserved.
//

import UIKit
import CoreData

class MyVehicleViewController: UIViewController {

    var managedObjectContext:NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let carService = CarService(managedObjectContext: managedObjectContext)
        carService.showVehicle()
    }

    @IBAction func backToHome(_ sender:AnyObject){
        dismiss(animated: true, completion: nil)
    }
   

}
