import CoreData

extension NSManagedObject {

	public class var entityName: String {
		return NSStringFromClass(self).componentsSeparatedByString(".").last!
	}
}
