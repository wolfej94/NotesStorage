//
//  DefaultStorageService.swift
//  NotesStorage
//
//  Created by James Wolfe on 16/01/2025.
//

import CoreData
import Combine

/// A service responsible for managing Core Data operations for notes.
/// Provides support for synchronous, async/await, closure-based, and Combine-based methods.
internal final class StorageService: StorageServiceProtocol, @unchecked Sendable {

    // MARK: - Properties

    internal let container: NSPersistentContainer
    private let backgroundContext: NSManagedObjectContext
    internal var coreData: CoreDataHelper
    private var cancellables = Set<AnyCancellable>()

    /// Initializer for use in the application.
    /// Configures the container with the persistent store.
    init() {
        coreData = DefaultCoreDataHelper()
        guard let modelURL = Bundle.module.url(forResource: "Model", withExtension: "momd"),
              let model = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Model not found")
        }

        container = NSPersistentContainer(name: "Model", managedObjectModel: model)
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Unresolved error \(error)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        backgroundContext = container.newBackgroundContext()
        backgroundContext.automaticallyMergesChangesFromParent = true
    }

    /// Reads all notes from the persistent store.
    /// - Returns: An array of `NoteViewModel` instances.
    /// - Throws: An error if the fetch operation fails.
    func read() throws -> [NoteViewModel] {
        return try coreData.fetchManagedObjects(
            ofType: Note.self,
            byIDs: nil,
            in: container.viewContext
        )
        .map { try NoteViewModel(from: $0) }
    }

}

// MARK: - Async/Await Methods
extension StorageService {

    /// Creates a new note asynchronously.
    /// - Parameters:
    ///   - note: The `NoteViewModel` representing the note to create.
    /// - Throws: An error if the creation fails.
    func create(_ note: NoteViewModel) async throws {
        try await coreData.insert(note: note, in: backgroundContext)
    }

    /// Updates an existing note asynchronously.
    /// - Parameters:
    ///   - note: The `NoteViewModel` representing the note to update.
    /// - Throws: An error if the update fails.
    func update(_ note: NoteViewModel) async throws {
        try await coreData.update(note: note, in: backgroundContext)
    }

    /// Deletes notes asynchronously.
    /// - Parameters:
    ///   - notes: An array of `NoteViewModel` instances to delete.
    /// - Throws: An error if the deletion fails.
    func delete(_ notes: [NoteViewModel]) async throws {
        let ids = try coreData.fetchObjectIDs(ofType: Note.self, for: notes.map { $0.id }, in: backgroundContext)
        try await coreData.delete(ids: ids, in: backgroundContext)
    }

}

// MARK: - Closure Methods
extension StorageService {

    /// Creates a new note using a closure-based completion handler.
    /// - Parameters:
    ///   - note: The `NoteViewModel` representing the note to create.
    ///   - completion: A completion handler called with the result of the operation.
    func create(_ note: NoteViewModel, completion: @escaping (Result<Void, any Error>) -> Void) {
        coreData.insert(note: note, in: backgroundContext, completion: completion)
    }

    /// Updates an existing note using a closure-based completion handler.
    /// - Parameters:
    ///   - note: The `NoteViewModel` representing the note to update.
    ///   - completion: A completion handler called with the result of the operation.
    func update(_ note: NoteViewModel, completion: @escaping (Result<Void, any Error>) -> Void) {
        coreData.update(note: note, in: backgroundContext, completion: completion)
    }

    /// Deletes notes using a closure-based completion handler.
    /// - Parameters:
    ///   - notes: An array of `NoteViewModel` instances to delete.
    ///   - completion: A completion handler called with the result of the operation.
    func delete(_ notes: [NoteViewModel], completion: @escaping (Result<Void, any Error>) -> Void) {
        do {
            let ids = try coreData.fetchObjectIDs(ofType: Note.self, for: notes.map { $0.id }, in: backgroundContext)
            coreData.delete(ids: ids, in: backgroundContext, completion: completion)
        } catch {
            completion(.failure(error))
        }
    }

}

// MARK: - Combine Publisher Methods
extension StorageService {

    /// Returns a publisher to create a new note.
    /// - Parameters:
    ///   - note: The `NoteViewModel` representing the note to create.
    /// - Returns: A publisher emitting success or error.
    func createPublisher(_ note: NoteViewModel) -> AnyPublisher<Void, any Error> {
        coreData.insertPublisher(note: note, in: backgroundContext)
    }

    /// Returns a publisher to update an existing note.
    /// - Parameters:
    ///   - note: The `NoteViewModel` representing the note to update.
    /// - Returns: A publisher emitting success or error.
    func updatePublisher(_ note: NoteViewModel) -> AnyPublisher<Void, any Error> {
        coreData.updatePublisher(note: note, in: backgroundContext)
    }

    /// Returns a publisher to delete notes.
    /// - Parameters:
    ///   - notes: An array of `NoteViewModel` instances to delete.
    /// - Returns: A publisher emitting success or error.
    func deletePublisher(_ notes: [NoteViewModel]) -> AnyPublisher<Void, any Error> {
        do {
            let ids = try coreData.fetchObjectIDs(ofType: Note.self, for: notes.map { $0.id }, in: backgroundContext)
            return coreData.deletePublisher(ids: ids, in: backgroundContext)
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
    }

}
