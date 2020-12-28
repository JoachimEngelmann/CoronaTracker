//
//  district.swift
//  Corona Index
//
//  Created by Joachim Engelmann on 28.10.20.
//  Copyright © 2020 Joachim Engelmann. All rights reserved.
//

import Foundation
import SwiftUI
import CoreData

class District: ObservableObject, Identifiable {
    @Published var name: String = "Unknown"
    @Published var districtID: String = ""
    @Published var incidenceValue: Double = 0.0
    @Published var longitude : Double = 0.0
    @Published var latitude : Double = 0.0
    @Published var lastUpdate: Date = Date()
    @Published var reportedInfectedPerDay: Dictionary<Int, Int> = Dictionary<Int, Int>()
    
    private var valid: Bool = false
    private var locationProvider: LocationProvider?
    
    enum Warnlevel: Int {
        case low = 0
        case medium
        case high
        case veryHigh
        case undefined
    }
    
    ///Create an object that uses the current GPS position
    init(){
        locationProvider = LocationProvider()
        locationProvider?.aquireGpsPosition() { coordinates in
            self.locationProvider = nil
            
            self.longitude = coordinates.longitude
            self.latitude = coordinates.latitude
            
            self.aquireRkiValues_coordinates()
        }
    }
    
    ///Create an object with district name for data aquiration
    init(_ name: String){
        self.name = name
        
        //Create Instance
        locationProvider = LocationProvider()
        locationProvider?.aquireCoordinates(name: name){coordinates in
            self.locationProvider = nil
            
            self.longitude = coordinates.longitude
            self.latitude = coordinates.latitude
            
            //Get RKI values
            self.aquireRkiValues_name(){
                self.updateCoreData()
            }
        }
    }
    
    ///Create object from persistand data
    init(_ name: String, _ incidenceValue: Double, _ longitude: Double, _ latitude: Double, _ lastUpdate: Date, _ districtID: String){
        self.name = name
        self.incidenceValue = incidenceValue
        self.longitude = longitude
        self.latitude = latitude
        self.lastUpdate = lastUpdate
        self.districtID = districtID
        valid = true
        
        //Only update RKI values if they are older than 1 hour
        if(lastUpdate.timeIntervalSinceNow.isLessThanOrEqualTo(-3600)){
            aquireRkiValues_name(){
                DispatchQueue.main.async {
                    self.lastUpdate = Date()
                }
                self.updateCoreData()
            }
        }
    }
    
    func getWarnLevel() -> Warnlevel {
        if(valid == true){
            if(incidenceValue >= 0.0 && incidenceValue < 35.0){
                return Warnlevel.low
            }else if(incidenceValue >= 35.0 && incidenceValue < 50.0){
                return Warnlevel.medium
            }else if(incidenceValue >= 50.0 && incidenceValue < 100.0){
                return Warnlevel.high
            }else{
                return Warnlevel.veryHigh
            }
        }else{
            return Warnlevel.undefined
        }
    }
    
    func updateTrendData(previousDays: Double){
        Rki_Api.getTrendData(districtID: districtID, previousDays: previousDays){ data in
            
            let tmpTrends = data.reduce([Int: Int]()) { (dict, entry) -> [Int: Int] in
                var dict = dict
                dict[entry.reportingDate] = (dict[entry.reportingDate] ?? 0) + entry.cases
                return dict
            }
            
            DispatchQueue.main.async {
                self.reportedInfectedPerDay = tmpTrends
            }
        }
    }
    
    func updateIncidenceData(){
        aquireRkiValues_name(){
            DispatchQueue.main.async {
                self.lastUpdate = Date()
            }
            self.updateCoreData()
        }
    }
    
    
    func updateCoreData(){
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let reqVar = NSFetchRequest<NSFetchRequestResult>(entityName: "Locations")
        reqVar.predicate = NSPredicate(format: "name == %@", self.name)
        let results = try? context.fetch(reqVar) as? [NSManagedObject]
        
        if (results?.count != 0){
            //Set new coreData values
            results?[0].setValue(self.incidenceValue, forKey: "incidenceValue")
            results?[0].setValue(self.lastUpdate, forKey: "lastUpdate")
            
            do{
                try context.save()
            }catch{
                print("CoreData:", error)
            }
        }else{
            //Write new element
            context.perform {
                do{
                    let entity = NSEntityDescription.entity(forEntityName: "Locations", in: context)
                    let locations = NSManagedObject(entity: entity!, insertInto: context)
                    locations.setValue(self.name, forKey: "name")
                    locations.setValue(self.districtID, forKey: "districtID")
                    locations.setValue(self.incidenceValue, forKey: "incidenceValue")
                    locations.setValue(self.longitude, forKey: "longitude")
                    locations.setValue(self.latitude, forKey: "latitude")
                    locations.setValue(self.lastUpdate, forKey: "lastUpdate")
                    
                    try context.save()
                } catch {
                    print("CoreData:", error)
                }
            }
        }
    }
    
    
    private func aquireRkiValues_coordinates(completion: @escaping () -> Void = {}){
        Rki_Api.getIncidenceData(latitude: latitude, longtitude: longitude){ data in
            DispatchQueue.main.async {
                self.name = data.name
                self.incidenceValue = data.cases7Per100K
                self.valid = true
                completion()
            }
        }
    }
    
    private func aquireRkiValues_name(completion: @escaping () -> Void = {}){
        Rki_Api.getIncidenceData(districtName: self.name){ data in
            DispatchQueue.main.async {
                self.incidenceValue = data.cases7Per100K
                self.districtID = data.districtID
                self.valid = true
                completion()
            }
        }
    }
}
