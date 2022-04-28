//
//  NumberFormatter+Int.swift
//  SumLit
//
//  Created by Junior Etrata on 9/17/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import Foundation

extension Int {
    
    func formatUsingAbbrevation () -> String {
        
        let num = abs(Double(self))
        let sign = (self < 0) ? "-" : ""
        
        switch num {
            
        case 1_000_000_000...:
            var formatted = num / 1_000_000_000
            formatted = formatted.truncate(places: 1)
            var formattedString = "\(formatted)"
            if formattedString.last == "0"{
                formattedString.removeLast()
                formattedString.removeLast()
            }
            return "\(sign)\(formattedString)B"
            
        case 1_000_000...:
            var formatted = num / 1_000_000
            formatted = formatted.truncate(places: 1)
            var formattedString = "\(formatted)"
            if formattedString.last == "0"{
                formattedString.removeLast()
                formattedString.removeLast()
            }
            return "\(sign)\(formattedString)M"
            
        case 1_000...:
            var formatted = num / 1_000
            formatted = formatted.truncate(places: 1)
            var formattedString = "\(formatted)"
            if formattedString.last == "0"{
                formattedString.removeLast()
                formattedString.removeLast()
            }
            return "\(sign)\(formattedString)K"
            
        case 0...:
            return "\(self)"
            
        default:
            return "\(sign)\(self)"
        }
    }
}

extension Double {
    func truncate(places: Int) -> Double {
        return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
    }
}
