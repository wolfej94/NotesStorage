//
//  MockManagedObjectContext.swift
//  NotesStorage
//
//  Created by James Wolfe on 17/01/2025.
//

import CoreData
@testable import NotesStorage

final class MockManagedObjectContext: ManagedObjectContext {

    private let context: NSManagedObjectContext

    init() {
        self.context = StorageService().container.viewContext
    }

    private(set) var insertCalled = false
    private(set) var insertedObject: NSManagedObject?
    func createObject<T: NSManagedObject>(ofType type: T.Type) -> T {
        let object = context.createObject(ofType: type)
        insertCalled = true
        insertedObject = object
        return object
    }

    private(set) var executeCalled = false
    private(set) var executedRequest: NSPersistentStoreRequest?
    var executeResult: Result<Void, Error>?
    func execute(_ request: NSPersistentStoreRequest) throws -> NSPersistentStoreResult {
        executeCalled = true
        executedRequest = request
        switch executeResult {
        case .success:
            return try context.execute(request)
        case .failure(let error):
            throw error
        case nil:
            fatalError("Execute result should have a value.")
        }
    }

    private(set) var fetchCalled = false
    private(set) var fetchRequest: NSFetchRequest<NSFetchRequestResult>?
    var fetchResult: Result<[NSFetchRequestResult], Error>?
    func fetch<T>(_ request: NSFetchRequest<T>) throws -> [T] where T: NSFetchRequestResult {
        fetchCalled = true
        switch fetchResult {
        case .success(let success):
            guard let result = success as? [T] else { fatalError("Invalid result type") }
            return result
        case .failure(let error):
            throw error
        case nil:
            fatalError("Fetch result should have a value.")
        }
    }

    private(set) var performAndWaitCalled = false
    func performAndWait(_ block: () -> Void) {
        performAndWaitCalled = true
        context.performAndWait(block)
    }

    private(set) var saveCalled = false
    var saveResult: Result<Void, Error>?
    func save() throws {
        saveCalled = true
        switch saveResult {
        case .success:
            try context.save()
            return
        case .failure(let error):
            throw error
        case nil:
            fatalError("Save result should have a value.")
        }
    }

}
