//
//  DateManager.swift
//  News
//
//  Created by Yury Khadatovich on 25.01.22.
//

import Foundation
class DateManager {
    static let shared = DateManager()
    
    let currentDate = Date()
    let format = DateFormatter()
    let calendar = Calendar.current
    
    func getCurrentDate() -> String {
            format.timeZone = .current
            format.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            let dateString = format.string(from: currentDate)
            return dateString
        }
    
    func getDate(hoursAgo: Double) -> String {
        format.timeZone = .current
        format.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let dateString = format.string(from: currentDate - hoursAgo * 60 * 60)
        return dateString
    }
    
    func getDate(daysAgo: Double) -> String {
        format.timeZone = .current
        format.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let dateString = format.string(from: currentDate - daysAgo * 24 * 60 * 60)
        return dateString
    }
    
    
}


