//
//  ManagedObjectContext.swift
//  NotesStorage
//
//  Created by James Wolfe on 17/01/2025.
//

import CoreData

internal protocol ManagedObjectContext {
    func fetch<T>(_ request: NSFetchRequest<T>) throws -> [T] where T: NSFetchRequestResult
    func performAndWait(_ block: () -> Void)
    func save() throws
    func execute(_ request: NSPersistentStoreRequest) throws -> NSPersistentStoreResult
    func createObject<T: NSManagedObject>(ofType type: T.Type) -> T
}
extension NSManagedObjectContext: ManagedObjectContext {
    func createObject<T: NSManagedObject>(ofType type: T.Type) -> T {
        return T(context: self)
    }
}
