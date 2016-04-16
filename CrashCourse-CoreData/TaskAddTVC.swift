//
//  TaskAddTVC.swift
//  CrashCourse-CoreData
//
//  Created by Tomas Srna on 15/04/16.
//  Copyright © 2016 SRNA. All rights reserved.
//

import UIKit

protocol TaskAddDelegate {
    func addTask(name: String, dueDate: NSDate)
}

class TaskAddTVC : UITableViewController {
    
    // MARK: Vars
    
    var delegate : TaskAddDelegate?
    
    // MARK: Outlets
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var dueDateDP: UIDatePicker!
    
    // MARK: Actions
    @IBAction func addAction(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true) {
            self.delegate?.addTask(self.nameTF.text!, dueDate: self.dueDateDP.date)
        }
    }
    
}
