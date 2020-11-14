//
//  addDistrict.swift
//  Corona Tracker
//
//  Created by Joachim Engelmann on 14.11.20.
//  Copyright © 2020 Joachim Engelmann. All rights reserved.
//

import SwiftUI

struct addDistrict: View {
    var districtCollection: DistrictsCollection
    @ObservedObject var viewModel: addDistrictViewModel
    
    @Environment(\.presentationMode) var presentation
    
    init(districtCollection: DistrictsCollection){
        self.districtCollection = districtCollection
        viewModel = addDistrictViewModel(districtCollection: districtCollection)
    }
    
    var body: some View {
        VStack{
            VStack{
                Text("Landkreis hinzufügen").font(.title).padding()
                
                HStack{
                    Spacer()
                    
                    Button(action: {
                        self.hideKeyboard()
                        presentation.wrappedValue.dismiss()
                    }) {
                        Text("Abbrechen")
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        self.hideKeyboard()
                        if(!viewModel.enteredTextValue.isEmpty){
                            districtCollection.addDistrict(viewModel.enteredTextValue)
                            presentation.wrappedValue.dismiss()
                        }
                    }) {
                        Text("Hinzufügen")
                    }
                    
                    Spacer()
                }
                
                TextField("Neuer Landkreis", text: $viewModel.enteredTextValue)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                
            }
            
            if !viewModel.autoSuggestionArray.isEmpty {
                VStack {
                    List {
                        ForEach(viewModel.autoSuggestionArray, id: \.self) { item in
                            Button(action: {
                                viewModel.enteredTextValue = item
                                viewModel.autoSuggestionArray.removeAll()
                            }) {
                                Text(item)
                            }
                        }
                    }.frame(height: viewModel.getHeight())
                    Spacer()
                }
                .padding()
                .shadow(radius: 5)
                .cornerRadius(5)
            }else{Spacer()}
        }
    }
}


struct addDistrict_Previews: PreviewProvider {
    static var previews: some View {
        addDistrict(districtCollection: DistrictsCollection())
    }
}
