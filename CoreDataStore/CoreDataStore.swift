import CoreData

public class CoreDataStore {
	public static var sharedStore = CoreDataStore()
	
	public var modelName: String = ""

	lazy var applicationDocumentsDirectory: NSURL = {
		let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
		return urls[urls.count-1] 
	}()
	
	lazy var managedObjectModel: NSManagedObjectModel = {
		let modelURL = NSBundle.mainBundle().URLForResource(self.modelName, withExtension: "momd")!
		return NSManagedObjectModel(contentsOfURL: modelURL)!
	}()
	
	lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
		var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
		let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("\(self.modelName).sqlite")
		print(url)
		var error: NSError? = nil
		var failureReason = "There was an error creating or loading the application's saved data."
		do {
			try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
		} catch var error1 as NSError {
			error = error1
			coordinator = nil
			var dict = [String: AnyObject]()
			dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
			dict[NSLocalizedFailureReasonErrorKey] = failureReason
			dict[NSUnderlyingErrorKey] = error
			error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
			NSLog("Unresolved error \(error), \(error!.userInfo)")
			do {
				try NSFileManager.defaultManager().removeItemAtURL(url)
			} catch _ {
			}
		} catch {
			fatalError()
		}
		
		return coordinator
		}()
	
	public lazy var managedObjectContext: NSManagedObjectContext? = {
		let coordinator = self.persistentStoreCoordinator
		if coordinator == nil {
			return nil
		}
		var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
		managedObjectContext.persistentStoreCoordinator = coordinator
		return managedObjectContext
	}()
	
	public func saveContext () {
		if let moc = self.managedObjectContext {
			var error: NSError? = nil
			if moc.hasChanges {
				do {
					try moc.save()
				} catch let error1 as NSError {
					error = error1
					NSLog("Unresolved error \(error), \(error!.userInfo)")
				}
			}
		}
	}

	public func insert<T:NSManagedObject>() -> T {
		return NSEntityDescription.insertNewObjectForEntityForName(T.entityName, inManagedObjectContext: self.managedObjectContext!) as! T
	}
	
	public func deleteObject(object: NSManagedObject) {
		if let moc = self.managedObjectContext {
			moc.deleteObject(object)
		}
	}
	
	public func findObjectWithKey<T:NSManagedObject>(key: String, value: AnyObject) -> T? {
		let fetchRequest = NSFetchRequest(entityName: T.entityName)
		if let value = value as? String {
			fetchRequest.predicate = NSPredicate(format: "\(key) = \"\(value)\"")
		} else {
			fetchRequest.predicate = NSPredicate(format: "\(key) = \(value)")
		}
		let result = try? managedObjectContext!.executeFetchRequest(fetchRequest)
		if let object = result?.first as? T {
			return object
		}
		return nil
	}
	
	public func insertObject<T:NSManagedObject>() -> T {
		let object:T = CoreDataStore.sharedStore.insert()
		return object
	}
	
	public func allObjects<T:NSManagedObject>() -> [T] {
		let fetchRequest = NSFetchRequest(entityName: T.entityName)
		let result = try? managedObjectContext!.executeFetchRequest(fetchRequest) as? [T]
		return (result ?? []) ?? []
	}
	
	public func fetchAll(t: NSManagedObject.Type, sortDescriptors: [NSSortDescriptor]? = nil, predicate: NSPredicate? = nil) -> NSFetchRequest {
		let fetchRequest = NSFetchRequest(entityName: t.entityName)
		fetchRequest.fetchBatchSize = 10
		fetchRequest.sortDescriptors = sortDescriptors
		fetchRequest.predicate = predicate
		return fetchRequest
	}
	
}