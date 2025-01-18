//
//  CoreDataHelper.swift
//  Storage
//
//  A comprehensive Core Data helper that provides:
//  1. Synchronous CRUD operations.
//  2. Async/Await support for modern concurrency.
//  3. Closure-based methods for compatibility with legacy codebases.
//  4. Combine publishers for reactive programming.
//
//  Features:
//  - Reusable fetch methods with customizable predicates.
//  - Graceful error handling using Result types and structured error propagation.
//  - Modern Swift paradigms like withCheckedThrowingContinuation and Combine.
//
//  Created by James Wolfe on 03/12/2024.
//

import CoreData
import Combine

typealias CoreDataHelper = SynchronousCoreDataHelper &
                           AsyncCoreDataHelper &
                           ClosureCoreDataHelper &
                           CombineCoreDataHelper

internal struct DefaultCoreDataHelper: SynchronousCoreDataHelper {

    /// Fetches a managed object of a specific type by its UUID.
    /// - Parameters:
    ///   - type: The `NSManagedObject` subclass type.
    ///   - id: The UUID of the object to fetch.
    ///   - context: The managed object context to fetch from.
    /// - Returns: The fetched object, or `nil` if not found.
    /// - Throws: An error if the fetch request fails.
    func fetchManagedObject<T: NSManagedObject>(ofType type: T.Type,
                                                byID id: UUID,
                                                in context: ManagedObjectContext) throws -> T? {
        let fetchRequest = T.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = %@", id.uuidString)
        return try context.fetch(fetchRequest).first as? T
    }

    /// Fetches managed objects of a specific type by their UUIDs.
    /// - Parameters:
    ///   - type: The `NSManagedObject` subclass type.
    ///   - ids: An optional array of UUIDs to filter by. If nil, all objects of the type are fetched.
    ///   - context: The managed object context to fetch from.
    /// - Returns: An array of fetched objects.
    /// - Throws: An error if the fetch request fails.
    func fetchManagedObjects<T: NSManagedObject>(ofType type: T.Type,
                                                 byIDs ids: [UUID]?,
                                                 in context: ManagedObjectContext) throws -> [T] {
        let fetchRequest = T.fetchRequest()
        if let ids {
            fetchRequest.predicate = NSPredicate(format: "id IN %@", ids)
        }
        guard let result = try context.fetch(fetchRequest) as? [T] else {
            throw StorageError.typeMismatch
        }
        return result
    }

    /// Fetches object IDs of managed objects by their UUIDs.
    /// - Parameters:
    ///   - type: The `NSManagedObject` subclass type.
    ///   - ids: An array of UUIDs to fetch object IDs for.
    ///   - context: The managed object context to fetch from.
    /// - Returns: An array of `NSManagedObjectID` corresponding to the given UUIDs.
    /// - Throws: An error if fetching fails.
    func fetchObjectIDs<T: NSManagedObject>(ofType type: T.Type,
                                            for ids: [UUID],
                                            in context: ManagedObjectContext) throws -> [NSManagedObjectID] {
        return try ids.compactMap { id in
            try fetchManagedObject(ofType: type, byID: id, in: context)?.objectID
        }
    }

}

// MARK: - Async/Await Methods
extension DefaultCoreDataHelper: AsyncCoreDataHelper {

    /// Inserts a note asynchronously.
    /// - Parameters:
    ///   - note: The `NoteViewModel` representing the note to insert.
    ///   - context: The managed object context to insert into.
    /// - Throws: An error if insertion fails.
    func insert(note: NoteViewModel, in context: ManagedObjectContext) async throws {
        try await withCheckedThrowingContinuation { continuation in
            insert(note: note, in: context, completion: { continuation.resume(with: $0) })
        }
    }

    /// Updates a note asynchronously.
    /// - Parameters:
    ///   - note: The `NoteViewModel` representing the note to update.
    ///   - context: The managed object context to update in.
    /// - Throws: An error if update fails.
    func update(note: NoteViewModel, in context: ManagedObjectContext) async throws {
        try await withCheckedThrowingContinuation { continuation in
            update(note: note, in: context, completion: { continuation.resume(with: $0) })
        }
    }

    /// Deletes objects asynchronously by their IDs.
    /// - Parameters:
    ///   - ids: An array of `NSManagedObjectID` to delete.
    ///   - context: The managed object context to delete from.
    /// - Throws: An error if deletion fails.
    func delete(ids: [NSManagedObjectID], in context: ManagedObjectContext) async throws {
        try await withCheckedThrowingContinuation { continuation in
            delete(ids: ids, in: context, completion: { continuation.resume(with: $0) })
        }
    }

}

// MARK: - Closure Methods
extension DefaultCoreDataHelper: ClosureCoreDataHelper {

    /// Inserts a note using a closure-based completion handler.
    /// - Parameters:
    ///   - note: The `NoteViewModel` representing the note to insert.
    ///   - context: The managed object context to insert into.
    ///   - completion: A completion handler called with the result of the operation.
    func insert(note: NoteViewModel,
                in context: ManagedObjectContext,
                completion: @escaping (Result<Void, Error>) -> Void) {
        context.performAndWait {
            do {
                let storageObject = context.createObject(ofType: Note.self)
                storageObject.id = note.id
                storageObject.title = note.title
                storageObject.body = note.body
                storageObject.createdAt = note.createdAt
                storageObject.updatedAt = note.updatedAt
                try context.save()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Updates a note using a closure-based completion handler.
    /// - Parameters:
    ///   - note: The `NoteViewModel` representing the note to update.
    ///   - context: The managed object context to update in.
    ///   - completion: A completion handler called with the result of the operation.
    func update(note: NoteViewModel,
                in context: ManagedObjectContext,
                completion: @escaping (Result<Void, Error>) -> Void) {
        context.performAndWait {
            do {
                guard let storageObject = try fetchManagedObject(ofType: Note.self, byID: note.id, in: context) else {
                    throw StorageError.objectNotFound("Note with id \(note.id) not found")
                }
                storageObject.id = note.id
                storageObject.title = note.title
                storageObject.body = note.body
                storageObject.createdAt = note.createdAt
                storageObject.updatedAt = note.updatedAt
                try context.save()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Deletes objects by their IDs using a closure-based completion handler.
    /// - Parameters:
    ///   - ids: An array of `NSManagedObjectID` to delete.
    ///   - context: The managed object context to delete from.
    ///   - completion: A completion handler called with the result of the operation.
    func delete(ids: [NSManagedObjectID],
                in context: ManagedObjectContext,
                completion: @escaping (Result<Void, Error>) -> Void) {
        context.performAndWait {
            do {
                let deleteRequest = NSBatchDeleteRequest(objectIDs: ids)
                _ = try context.execute(deleteRequest)
                try context.save()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

}

// MARK: - Combine Publisher Methods
extension DefaultCoreDataHelper: CombineCoreDataHelper {

    /// Returns a publisher to insert a note.
    /// - Parameters:
    ///   - note: The `NoteViewModel` representing the note to insert.
    ///   - context: The managed object context to insert into.
    /// - Returns: A publisher emitting success or error.
    func insertPublisher(note: NoteViewModel, in context: ManagedObjectContext) -> AnyPublisher<Void, any Error> {
        Future<Void, Error> { promise in
            insert(note: note, in: context, completion: { promise($0) })
        }.eraseToAnyPublisher()
    }

    /// Returns a publisher to update a note.
    /// - Parameters:
    ///   - note: The `NoteViewModel` representing the note to update.
    ///   - context: The managed object context to update in.
    /// - Returns: A publisher emitting success or error.
    func updatePublisher(note: NoteViewModel, in context: ManagedObjectContext) -> AnyPublisher<Void, any Error> {
        Future<Void, Error> { promise in
            update(note: note, in: context, completion: { promise($0) })
        }.eraseToAnyPublisher()
    }

    /// Returns a publisher to delete objects by their IDs.
    /// - Parameters:
    ///   - ids: An array of `NSManagedObjectID` to delete.
    ///   - context: The managed object context to delete from.
    /// - Returns: A publisher emitting success or error.
    func deletePublisher(ids: [NSManagedObjectID], in context: ManagedObjectContext) -> AnyPublisher<Void, any Error> {
        Future<Void, Error> { promise in
            delete(ids: ids, in: context, completion: { promise($0) })
        }.eraseToAnyPublisher()
    }

}
