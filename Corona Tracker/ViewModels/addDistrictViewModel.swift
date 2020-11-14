//
//  addDistrictViewModel.swift
//  Corona Tracker
//
//  Created by Joachim Engelmann on 14.11.20.
//  Copyright © 2020 Joachim Engelmann. All rights reserved.
//

import Foundation
import SwiftUI


class addDistrictViewModel: ObservableObject {
    var districtCollection: DistrictsCollection
    
    @Published var autoSuggestionArray: [String] = [String]()
    @Published var enteredTextValue: String = "" {
        didSet {
            updateSuggestionsList()
        }
    }
    
    init(districtCollection: DistrictsCollection){
        self.districtCollection = districtCollection
    }
    
    func getHeight() -> CGFloat{
        if(autoSuggestionArray.count * 50 > 200){
            return 200
        }else{
            return CGFloat(autoSuggestionArray.count * 50)
        }
    }

    private func updateSuggestionsList(){
        if(!enteredTextValue.isEmpty){
            autoSuggestionArray = districtCollection.listAvailableDistricts.reduce([String]()){(newArray, entry) -> [String] in
                var newArray = newArray
                if(entry.hasPrefix(enteredTextValue)){
                    newArray.append(entry)
                }
                return newArray
            }
        }else{
            autoSuggestionArray.removeAll()
        }
    }
}
