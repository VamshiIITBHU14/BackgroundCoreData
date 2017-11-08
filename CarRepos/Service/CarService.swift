//
//  CarService.swift
//  CarRepos
//
//  Created by Vamshi Krishna on 08/11/17.
//  Copyright © 2017 VamshiKrishna. All rights reserved.
//

import Foundation
import CoreData

class CarService{
    
    internal var managedObjectContext: NSManagedObjectContext!
    
    internal init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
    }
    
    deinit {
        self.managedObjectContext = nil
    }
    
    internal func getMyVehicles() -> [Car] {
        var cars = [Car]()
        
        let request: NSFetchRequest<Car> = Car.fetchRequest()
        
        do {
            cars = try managedObjectContext.fetch(request)
        }
        catch {
            fatalError("Error loading cars")
        }
        
        return cars
    }
    
    internal func deleteVehicle(_ car: Car) {
        managedObjectContext.delete(car)
        saveState()
    }
    
    fileprivate func saveState() {
        do {
            try self.managedObjectContext.save()
        }
        catch {
            fatalError("Error inserting service record")
        }
    }
    
    func loadVehicleData() {
        
        let url = Bundle.main.url(forResource: "cars", withExtension: "json")
        let data = NSData(contentsOf: url!)
        
                self.managedObjectContext.perform({
                    do {
                        
                        let jsonResult =  try JSONSerialization.jsonObject(with: data! as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                        let jsonArray = jsonResult.value(forKey: "makes") as! NSArray
                        
                        for json in jsonArray {
                            let carData = json as! [String: AnyObject]
                            
                            guard let makeName = carData["name"] else { return }
                            let autoMaker = AutoMaker(context: self.managedObjectContext)
                            autoMaker.make = makeName as? String
                            
                            // Get the current AutoModels under the current AutoMaker
                            let autoModels = autoMaker.autoModel!.mutableCopy() as! NSMutableSet
                            
                            // Get the available AutoModel in JSON object for the current AutoMaker
                            guard let arrModelNames = carData["models"] as? NSArray else { return }
                            for modelName in arrModelNames {
                                let jsonModel = modelName as! [String: AnyObject]
                                let modelName = jsonModel["name"] as? String
                                
                                let autoModel = AutoModel(context: self.managedObjectContext)
                                autoModel.model = modelName
                                
                                let autoYears = autoModel.autoYear!.mutableCopy() as! NSMutableSet
                                
                                guard let arrModelYears = jsonModel["years"] as? NSArray else { return }
                                for modelYear in arrModelYears {
                                    let jsonYear = modelYear as! [String: AnyObject]
                                    let year = jsonYear["year"] as? NSNumber
                                    
                                    let autoYear = AutoYear(context: self.managedObjectContext)
                                    autoYear.year = (year?.int16Value)!
                                    autoYears.add(autoYear)
                                }
                                
                                // Set AutoYear into AutoModel for CoreData
                                autoModel.autoYear = autoYears.copy() as? NSSet
                                
                                autoModels.add(autoModel)
                            }
                            
                            // Set the AutoModel into AutoMaker for CoreData
                            autoMaker.autoModel = autoModels.copy() as? NSSet
                        }
                        
                        try self.managedObjectContext.save()
                    }
                    catch let error as NSError {
                        print("Error in parsing JSON data: \(error.localizedDescription)")
                    }
                })
                self.showVehicle()
    }
    
    
    func deleteVehicleData() {
        let makerRequest: NSFetchRequest<AutoMaker> = AutoMaker.fetchRequest()
        let modelRequest: NSFetchRequest<AutoModel> = AutoModel.fetchRequest()
        let yearRequest: NSFetchRequest<AutoYear> = AutoYear.fetchRequest()
        
        do {
            let makerResult = try self.managedObjectContext.fetch(makerRequest)
            
            for maker in makerResult {
                self.managedObjectContext.delete(maker)
            }
            
            let modelResult = try self.managedObjectContext.fetch(modelRequest)
            for model in modelResult {
                self.managedObjectContext.delete(model)
            }
            
            let yearResult = try self.managedObjectContext.fetch(yearRequest)
            for year in yearResult {
                self.managedObjectContext.delete(year)
            }
            
            try self.managedObjectContext.save()
        }
        catch {
            fatalError("Error deleting objects")
        }
    }
    
    func showVehicle() {
        let request: NSFetchRequest<AutoMaker> = AutoMaker.fetchRequest()
        request.predicate = NSPredicate(format: "make = 'Acura'")
        
        do {
            let results = try managedObjectContext.fetch(request)
            let autoMaker = results.first
            print("Automaker: \(String(describing: autoMaker?.make))")
        }
        catch {
            fatalError()
        }
    }
}
