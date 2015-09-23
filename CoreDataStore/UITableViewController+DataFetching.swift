import UIKit
import CoreData

public extension UITableViewController {
	
	var fetchedResultsController: NSFetchedResultsController? {
		return nil
	}
	
	func controllerWillChangeContent(controller: NSFetchedResultsController) {
		if controller == self.fetchedResultsController {
			self.tableView.beginUpdates()
		}
	}
	
	func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
		if controller == self.fetchedResultsController {
			switch type {
			case .Insert:
				self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
			case .Delete:
				self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
			case .Move, .Update:
				break
			}
		}
	}
	
	func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
		if controller != self.fetchedResultsController {
			return
		}
		
		switch type {
		case .Insert:
			self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
		case .Delete:
			self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
		case .Update:
			if let cell = self.tableView.cellForRowAtIndexPath(indexPath!) {
				self.configureCell(cell, atIndexPath: indexPath!)
			}
		case .Move:
			self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
			self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
		}
	}
	
	func controllerDidChangeContent(controller: NSFetchedResultsController) {
		if controller != self.fetchedResultsController {
			return
		}
		self.tableView.endUpdates()
	}

	func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
	}

}
