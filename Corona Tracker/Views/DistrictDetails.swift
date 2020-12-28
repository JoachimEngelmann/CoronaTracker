//
//  DistrictDetails.swift
//  Corona Index
//
//  Created by Joachim Engelmann on 03.11.20.
//  Copyright © 2020 Joachim Engelmann. All rights reserved.
//

import SwiftUI
import MapKit

struct DistrictDetails: View {
    @ObservedObject var district: District
    
    var body: some View {
        VStack{
            MapView(coordinate: CLLocationCoordinate2D(latitude: district.latitude, longitude: district.longitude))
                .edgesIgnoringSafeArea(.top)
                .frame(height: 150)
            
            VStack{
                VStack{
                    Text(district.name).font(.title)
                    HStack(alignment: .top) {
                        Text("Latitude: " + String(format: "%.6f", district.latitude))
                        
                        Text("Longtitude: " + String(format: "%.6f", district.longitude))
                    }
                    .foregroundColor(.gray)
                    .font(.caption)
                }
                
                Divider()
                
                HStack{
                    Spacer()
                    VStack{
                        HStack{
                            Text("Index: ")
                            Text(String(format: "%.2f", district.incidenceValue)).foregroundColor(indexColor(district))
                        }
                        HStack{
                            Text(district.lastUpdate, style: .date)
                            Text(district.lastUpdate, style: .time)
                        }
                        .foregroundColor(.gray)
                        .font(.caption)
                    }
                    Spacer()
                    Button(action: {
                        self.hideKeyboard()
                        district.updateIncidenceData()
                        district.updateTrendData(previousDays: -14)
                    }) {
                        Image(systemName: "arrow.clockwise.icloud")
                    }
                }
                
                Divider()
                
                Text("Trends").font(.headline)
                TrendsView(trends: district.reportedInfectedPerDay)
            }
            .padding()
        }
        .onAppear(perform: {district.updateTrendData(previousDays: -14)})
    }
}

struct DistrictDetails_Previews: PreviewProvider {
    static var previews: some View {
        let tmp: District = District("München")
        DistrictDetails(district: tmp)
    }
}
