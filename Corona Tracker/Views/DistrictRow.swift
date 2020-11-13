//
//  DistrictRow.swift
//  Corona Index
//
//  Created by Joachim Engelmann on 03.11.20.
//  Copyright © 2020 Joachim Engelmann. All rights reserved.
//

import SwiftUI

struct DistrictRow: View {
    @ObservedObject var district: District
    
    var body: some View {
        HStack{
            Text(district.name)
            Spacer()
            Text(String(format: "%.2f", district.incidenceValue)).foregroundColor(indexColor(district))
        }
    }
}

struct DistrictRow_Previews: PreviewProvider {
    static var previews: some View {
        let tmp: District = District("München")
        DistrictRow(district: tmp)
    }
}
