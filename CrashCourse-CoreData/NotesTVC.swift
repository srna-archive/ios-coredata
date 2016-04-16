//
//  NotesTVC.swift
//  CrashCourse-CoreData
//
//  Created by Tomas Srna on 15/04/16.
//  Copyright © 2016 SRNA. All rights reserved.
//

import UIKit
import CoreData

class NotesTVC : UITableViewController, NSFetchedResultsControllerDelegate {
    
    enum Constants: String {
        case TaskCellReuseIdentifier = "NoteCell"
    }
    
    var task : Task!
    
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
    
    // MARK: Core Data
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    lazy var fetchedResultsController : NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Note")
        let fetchPredicate = NSPredicate(format: "task = %@", self.task)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "text", ascending: true)]
        fetchRequest.predicate = fetchPredicate
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
        
        if let note = fetchedResultsController.objectAtIndexPath(indexPath) as? Note {
            cell.textLabel?.text = note.text
        }
        
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        return [UITableViewRowAction(style: .Destructive, title: "Delete", handler: { action, indexPath in
            self.managedObjectContext.deleteObject(self.fetchedResultsController.objectAtIndexPath(indexPath) as! Note)
        })]
    }
    
    // MARK: Add Action
    
    @IBAction func addAction(sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add Note", message: "Add note for \(task.name)", preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Note"
        }
        alert.addAction(UIAlertAction(title: "Save", style: .Default, handler: { (action) in
            if let tfs = alert.textFields {
                let noteTF = tfs[0]
                let entityDescription = NSEntityDescription.entityForName("Note", inManagedObjectContext: self.managedObjectContext)!
                let newNote = Note(entity: entityDescription, insertIntoManagedObjectContext: self.managedObjectContext)
                newNote.text = noteTF.text!
                newNote.task = self.task
                
                do {
                    try self.managedObjectContext.save()
                } catch let error as NSError {
                    let alert = UIAlertController(title: "Error Saving Task", message: error.localizedDescription, preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
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
