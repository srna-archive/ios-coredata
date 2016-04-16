//
//  TaskListTVC.swift
//  CrashCourse-CoreData
//
//  Created by Tomas Srna on 15/04/16.
//  Copyright © 2016 SRNA. All rights reserved.
//

import UIKit
import CoreData

class TaskListTVC : UITableViewController, NSFetchedResultsControllerDelegate, TaskAddDelegate {
    
    enum Constants: String {
        case TaskCellReuseIdentifier = "TaskCell"
        case TaskAddSegueIdentifier = "TaskAddSegue"
        case NotesSegueIdentifier = "NotesSegue"
    }
    
    var selectedTask : Task?
    
    // MARK: View Controller Lifecycle
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        refresh()
    }
    
    func refresh() {
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            let alert = UIAlertController(title: "Error Fetching Tasks", message: error.localizedDescription, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        if let segueIdentifier = segue.identifier {
            switch segueIdentifier {
            case Constants.TaskAddSegueIdentifier.rawValue:
                if let navigationVC = segue.destinationViewController as? UINavigationController, taskAddVC = navigationVC.topViewController as? TaskAddTVC {
                    taskAddVC.delegate = self
                }
            case Constants.NotesSegueIdentifier.rawValue:
                if let notesVC = segue.destinationViewController as? NotesTVC, selected = selectedTask {
                    notesVC.navigationItem.title = "Notes for \(selected.name)"
                    notesVC.task = selected
                }
            default:
                break
            }
        }
    }
    
    @IBAction func unwindToTasks(segue: UIStoryboardSegue) {
    }
    
    // MARK: Core Data
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    lazy var fetchedResultsController : NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Task")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dueDate", ascending: false), NSSortDescriptor(key: "name", ascending: true)]
        let _fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        _fetchedResultsController.delegate = self
        return _fetchedResultsController
    }()
    
    // MARK: UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let sections = fetchedResultsController.sections {
            return sections.count
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let sections = fetchedResultsController.sections {
            let currentSection = sections[section]
            return currentSection.name
        }
        return nil
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            let currentSection = sections[section]
            return currentSection.numberOfObjects
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.TaskCellReuseIdentifier.rawValue)!
        
        if let task = fetchedResultsController.objectAtIndexPath(indexPath) as? Task {
            cell.textLabel?.text = task.name
            cell.detailTextLabel?.text = task.dueDateFormatted
        }
        
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let selected = fetchedResultsController.objectAtIndexPath(indexPath) as? Task {
            selectedTask = selected
            performSegueWithIdentifier(Constants.NotesSegueIdentifier.rawValue, sender: self.tableView)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        return [UITableViewRowAction(style: .Destructive, title: "Delete", handler: { action, indexPath in
            self.managedObjectContext.deleteObject(self.fetchedResultsController.objectAtIndexPath(indexPath) as! Task)
        })]
    }
    
    // MARK: TaskAddDelegate
    
    func addTask(name: String, dueDate: NSDate) {
        let entityDescription = NSEntityDescription.entityForName("Task", inManagedObjectContext: self.managedObjectContext)!
        let newTask = Task(entity: entityDescription, insertIntoManagedObjectContext: self.managedObjectContext)
        newTask.name = name
        newTask.dueDate = dueDate
        
        do {
            try managedObjectContext.save()
        } catch let error as NSError {
            let alert = UIAlertController(title: "Error Saving Task", message: error.localizedDescription, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch(type) {
        case .Insert:
            if let newIndexPath = newIndexPath {
                tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Automatic)
            }
        case .Delete:
            if let indexPath = indexPath {
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            }
        case .Update:
            if let indexPath = indexPath {
                tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
            }
        case .Move:
            if let indexPath = indexPath {
                if let newIndexPath = newIndexPath {
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                    tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Automatic)
                }
            }
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
}
