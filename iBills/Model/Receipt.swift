//
//  Receipt.swift
//  iBills
//
//  Created by Sebastian Yanni on 05/08/2024.
//

import SwiftUI
import SwiftData

@Model
class Receipt {
    var explanation: String
    var date: Date
    var alarmSet: Bool
    
    init(explanation: String, date: Date, alarmSet: Bool) {
        self.explanation = explanation
        self.date = date
        self.alarmSet = alarmSet
    }
}
