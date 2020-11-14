//
//  ContentView.swift
//  Corona Index
//
//  Created by Joachim Engelmann on 27.10.20.
//  Copyright © 2020 Joachim Engelmann. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    //Object for current location
    @ObservedObject var currentLocation: District = District()
    //List of saved locations
    @ObservedObject var districtsCollection: DistrictsCollection = DistrictsCollection()

    @State private var showingAddDistrict = false
    
    var body: some View {
        NavigationView {
            List{
                Section(header: Text("Aktueller Landkreis")){
                    DistrictRow(district: currentLocation)
                }
                Section(header: Text("Andere Landkreise")){
                    ForEach(districtsCollection.districts) { district in
                        NavigationLink(destination: DistrictDetails(district: district)){
                            DistrictRow(district: district)
                        }
                    }
                    .onDelete(perform: districtsCollection.remove)
                    .onMove(perform: districtsCollection.move)
                }
            }
            .navigationBarItems(
                leading: EditButton(),
                trailing: Button(action: {
                    self.showingAddDistrict.toggle()
                }){
                    Image(systemName: "plus")
                    
                }.sheet(isPresented: $showingAddDistrict) {
                    addDistrict(districtCollection: districtsCollection)
                }
            )
            
            .navigationBarTitle(Text("Corona Tracker"))
            .listStyle(GroupedListStyle())
        }
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
