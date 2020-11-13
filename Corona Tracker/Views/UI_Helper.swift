//
//  UI_Helper.swift
//  Corona Index
//
//  Created by Joachim Engelmann on 03.11.20.
//  Copyright © 2020 Joachim Engelmann. All rights reserved.
//

import Foundation
import SwiftUI


func indexColor(_ district: District) -> Color{
    switch district.getWarnLevel(){
        case .low:
             return Color.green
        case .medium:
             return Color.yellow
        case .high:
             return Color.orange
        case .veryHigh:
             return Color.red
        case .undefined:
             return Color.gray
    }
}
