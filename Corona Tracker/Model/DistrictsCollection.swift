//
//  LocationsList.swift
//  Corona Index
//
//  Created by Joachim Engelmann on 01.11.20.
//  Copyright © 2020 Joachim Engelmann. All rights reserved.
//

import Foundation
import CoreData
import Combine
import SwiftUI

class DistrictsCollection: ObservableObject {
    @Published var districts: [District] = [District]()
    var listAvailableDistricts: [String] = [String]()
    
    private var anyCancellable: [AnyCancellable?] = [AnyCancellable]()
    
    init(){
        loadAvailableDistricts()
        
        loadLocationsCoreData().forEach(){ location in
            districts.append(District(location.name!, location.incidenceValue, location.longitude, location.latitude, location.lastUpdate!, location.districtID!))
        }
    }
    
    func remove(at offsets: IndexSet) {
        offsets.forEach(){ offset in
            deleteLocationCoreData(districts[offset].name)
        }
        districts.remove(atOffsets: offsets)
    }
    
    func move(source: IndexSet, destination: Int) {
        districts.move(fromOffsets: source, toOffset: destination)
        
        //Delete coreData and write new order
        deleteAllCoreData()
        districts.forEach(){district in
            district.updateCoreData()
        }
    }
    
    func addDistrict(_ name: String){
        //Prevent double entry in list
        if districts.contains(where: {$0.name == name}){
            return
        }

        districts.append(District(name))
        
        //Add event listener for nested districts
        anyCancellable.append(districts[districts.count-1].objectWillChange.sink(receiveValue: { [weak self] (_) in
            //Send event that self will change
            self?.objectWillChange.send()
        }))
        
        //Send notification in case event was already lost
        self.objectWillChange.send()
        
    }
    
    func deleteLocationCoreData(_ name: String){
        let mainContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let reqVar = NSFetchRequest<NSFetchRequestResult>(entityName: "Locations")
        reqVar.predicate = NSPredicate(format: "name == %@", name)
        let DelAllReqVar = NSBatchDeleteRequest(fetchRequest: reqVar)
        do { try mainContext.execute(DelAllReqVar) }
        catch { print(error) }
    }
    
    private func deleteAllCoreData() {
        let mainContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let ReqVar = NSFetchRequest<NSFetchRequestResult>(entityName: "Locations")
        let DelAllReqVar = NSBatchDeleteRequest(fetchRequest: ReqVar)
        do { try mainContext.execute(DelAllReqVar) }
        catch { print(error) }
    }
    
    private func loadLocationsCoreData() -> [Locations] {
        let mainContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Locations> = Locations.fetchRequest()
        do {
            let results = try mainContext.fetch(fetchRequest)
            return results
        }
        catch {
            debugPrint(error)
            return [Locations()]
        }
    }
    
    private func loadAvailableDistricts(){
        let file = Bundle.main.path(forResource: "districts.txt", ofType: nil)!
        let text: String = try! String(contentsOfFile: file, encoding: String.Encoding.utf8)

        listAvailableDistricts =  text.split(separator: "\n").map(String.init)
    }
}
