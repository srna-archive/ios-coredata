//
//  Note.swift
//  CrashCourse-CoreData
//
//  Created by Tomas Srna on 15/04/16.
//  Copyright © 2016 SRNA. All rights reserved.
//

import Foundation
import CoreData


class Note: NSManagedObject {
    @NSManaged var text: String
    @NSManaged var task: Task
}
