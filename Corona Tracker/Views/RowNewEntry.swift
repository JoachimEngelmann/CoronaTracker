//
//  NewEntry.swift
//  Corona Index
//
//  Created by Joachim Engelmann on 03.11.20.
//  Copyright © 2020 Joachim Engelmann. All rights reserved.
//

import SwiftUI

struct RowNewEntry: View {
    var districtCollection: DistrictsCollection
   
    @State private var name: String = ""
    
    var body: some View {
        HStack{
            TextField("Neuer Landkreis", text: $name)
            
            Spacer()
            Divider()
            
            Button(action: {
                self.hideKeyboard()
                if(name != ""){
                    districtCollection.addDistrict(name)
                    name = ""
                }
            }) {
                HStack{
                    Spacer()
                    Text("Hinzufügen")
                    Spacer()
                }
            }
        }
    }
}

struct NewEntry_Previews: PreviewProvider {
    static var previews: some View {
        RowNewEntry(districtCollection: DistrictsCollection())
    }
}
