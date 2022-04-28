//
//  Conversion+Date.swift
//  SumLit
//
//  Created by Junior Etrata on 9/11/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import Foundation

extension Date
{
   func shortenCalenderTimeSinceNow() -> String
   {
      let calendar = Calendar.current
      
      let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self, to: Date())
      
      let years = components.year!
      let months = components.month!
      let days = components.day!
      let hours = components.hour!
      let minutes = components.minute!
      let seconds = components.second!
      
      if years > 0 {
         return "\(years)y"
      } else if months > 0 {
         return "\(months)m"
      } else if days >= 7 {
         let weeks = days / 7
         return "\(weeks)w"
      } else if days > 0 {
         return "\(days)d"
      } else if hours > 0 {
         return "\(hours)h"
      } else if minutes > 0 {
         return "\(minutes)min"
      } else {
         return "\(seconds)s"
      }
   }
   
   func calenderTimeSinceNow() -> String
   {
      let calendar = Calendar.current
      
      let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self, to: Date())
      
      let years = components.year!
      let months = components.month!
      let days = components.day!
      let hours = components.hour!
      let minutes = components.minute!
      let seconds = components.second!
      
      if years > 0 {
         return years == 1 ? "1 year ago" : "\(years) years ago"
      } else if months > 0 {
         return months == 1 ? "1 month ago" : "\(months) months ago"
      } else if days >= 7 {
         let weeks = days / 7
         return weeks == 1 ? "1 week ago" : "\(weeks) weeks ago"
      } else if days > 0 {
         return days == 1 ? "1 day ago" : "\(days) days ago"
      } else if hours > 0 {
         return hours == 1 ? "1 hour ago" : "\(hours) hours ago"
      } else if minutes > 0 {
         return minutes == 1 ? "1 minute ago" : "\(minutes) minutes ago"
      } else {
         return seconds == 1 ? "1 second ago" : "\(seconds) seconds ago"
      }
   }
}
