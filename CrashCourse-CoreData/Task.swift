//
//  Task.swift
//  CrashCourse-CoreData
//
//  Created by Tomas Srna on 15/04/16.
//  Copyright © 2016 SRNA. All rights reserved.
//

import Foundation
import CoreData


class Task: NSManagedObject {

    @NSManaged var name : String
    @NSManaged var dueDate : NSDate
    
    var dueDateFormatted : String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .LongStyle
        dateFormatter.timeStyle = .NoStyle
        return dateFormatter.stringFromDate(dueDate)
    }

}
