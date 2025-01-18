//
//  MockCoreDataHelper.swift
//  NotesStorage
//
//  Created by James Wolfe on 16/01/2025.
//

@testable import NotesStorage
import CoreData
import Combine

final class MockCoreDataHelper: CoreDataHelper {

    var errorToThrowForInsert: Error?
    var errorToThrowForUpdate: Error?
    var errorToThrowForDelete: Error?
    var errorToThrowForFetchObjectIDs: Error?
    var errorToThrowForFetchObject: Error?
    var errorToThrowForFetchObjects: Error?

    var dataToReturnForFetchObjectIDs: [NSManagedObjectID]?
    var dataToReturnForFetchObject: NSManagedObject?
    var dataToReturnForFetchObjects: [NSManagedObject]?

    func insert(note: NoteViewModel, in context: ManagedObjectContext) async throws {
        if let errorToThrowForInsert { throw errorToThrowForInsert }
    }

    func update(note: NoteViewModel, in context: ManagedObjectContext) async throws {
        if let errorToThrowForUpdate { throw errorToThrowForUpdate }
    }

    func delete(ids: [NSManagedObjectID], in context: ManagedObjectContext) async throws {
        if let errorToThrowForDelete { throw errorToThrowForDelete }
    }

    func insert(note: NoteViewModel,
                in context: ManagedObjectContext,
                completion: @escaping (Result<Void, any Error>) -> Void) {
        if let errorToThrowForInsert {
            completion(.failure(errorToThrowForInsert))
            return
        }
        completion(.success(()))
    }

    func update(note: NoteViewModel,
                in context: ManagedObjectContext,
                completion: @escaping (Result<Void, any Error>) -> Void) {
        if let errorToThrowForUpdate {
            completion(.failure(errorToThrowForUpdate))
            return
        }
        completion(.success(()))
    }

    func delete(ids: [NSManagedObjectID],
                in context: ManagedObjectContext,
                completion: @escaping (Result<Void, any Error>) -> Void) {
        if let errorToThrowForDelete {
            completion(.failure(errorToThrowForDelete))
            return
        }
        completion(.success(()))
    }

    func insertPublisher(note: NotesStorage.NoteViewModel,
                         in context: ManagedObjectContext) -> AnyPublisher<Void, any Error> {
        if let errorToThrowForInsert {
            return Fail(error: errorToThrowForInsert).eraseToAnyPublisher()
        }
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func updatePublisher(note: NotesStorage.NoteViewModel,
                         in context: ManagedObjectContext) -> AnyPublisher<Void, any Error> {
        if let errorToThrowForUpdate {
            return Fail(error: errorToThrowForUpdate).eraseToAnyPublisher()
        }
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func deletePublisher(ids: [NSManagedObjectID],
                         in context: ManagedObjectContext) -> AnyPublisher<Void, any Error> {
        if let errorToThrowForDelete {
            return Fail(error: errorToThrowForDelete).eraseToAnyPublisher()
        }
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func fetchObjectIDs<T>(ofType type: T.Type,
                           for ids: [UUID],
                           in context: ManagedObjectContext) throws -> [NSManagedObjectID] where T: NSManagedObject {
        if let errorToThrowForFetchObjectIDs {
            throw errorToThrowForFetchObjectIDs
        }
        return dataToReturnForFetchObjectIDs ?? []
    }

    func fetchManagedObject<T>(ofType type: T.Type,
                               byID id: UUID,
                               in context: ManagedObjectContext) throws -> T? where T: NSManagedObject {
        if let errorToThrowForFetchObject {
            throw errorToThrowForFetchObject
        }
        return dataToReturnForFetchObject as? T
    }

    func fetchManagedObjects<T>(ofType type: T.Type,
                                byIDs ids: [UUID]?,
                                in context: ManagedObjectContext) throws -> [T] where T: NSManagedObject {
        if let errorToThrowForFetchObjects {
            throw errorToThrowForFetchObjects
        }
        return dataToReturnForFetchObjects as? [T] ?? []
    }

}
