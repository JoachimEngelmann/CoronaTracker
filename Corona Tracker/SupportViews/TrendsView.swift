//
//  TrendsView.swift
//  Corona Index
//
//  Created by Joachim Engelmann on 10.11.20.
//  Copyright © 2020 Joachim Engelmann. All rights reserved.
//

import SwiftUI
import SwiftUICharts

struct TrendsView: View {
    let trends: Dictionary<Int, Int>
        
    var body: some View {
        VStack{
            LineView(
                data: Array(trends.sorted(by: <).map({(key, value) in Double(value)})),
                xAxisData: ["-13 Tage","-12 Tage","-11 Tage","-10 Tage","-8 Tage","-7 Tage","-6 Tage","-5 Tage","-4 Tage","-3 Tage","-2 Tage","-1 Tage","Heute"]
            ).offset(x: 0, y: -20)
        }
    }
}

struct TrendsView_Previews: PreviewProvider {
    static var previews: some View {
        let dict = [1:10, 2:16, 3:23, 4:19, 5:7, 6:25, 7:18]
        TrendsView(trends: dict)
    }
}
