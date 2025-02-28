//
//  NotesStorage.swift
//  NotesStorage
//
//  Created by James Wolfe on 18/01/2025.
//

import Combine

public final class NotesStorage: Sendable {

    private let storageService: StorageService
    private let eventStream: StorageEventStream
    public static let shared = NotesStorage()

    internal init(eventStream: StorageEventStream) {
        storageService = StorageService()
        self.eventStream = eventStream
    }
    
    internal init() {
        storageService = StorageService()
        eventStream = DefaultStorageEventStream()
    }

    /// Creates a new note asynchronously.
    /// - Parameters:
    ///   - note: The `NoteViewModel` representing the note to create.
    /// - Throws: An error if the creation fails.
    public func create(_ note: NoteViewModel) async throws {
        try await storageService.create(note)
        await eventStream.sendNoteUpdate(note)
    }

    /// Reads all notes from storage.
    /// - Returns: An array of `NoteViewModel` instances.
    /// - Throws: An error if the read operation fails.
    public func read() throws -> [NoteViewModel] {
        try storageService.read()
    }

    /// Updates an existing note asynchronously.
    /// - Parameters:
    ///   - note: The `NoteViewModel` representing the note to update.
    /// - Throws: An error if the update fails.
    public func update(_ note: NoteViewModel) async throws {
        try await storageService.update(note)
        await eventStream.sendNoteUpdate(note)
    }

    /// Deletes notes asynchronously.
    /// - Parameters:
    ///   - notes: An array of `NoteViewModel` instances to delete.
    /// - Throws: An error if the deletion fails.
    public func delete(_ notes: [NoteViewModel]) async throws {
        try await storageService.delete(notes)
    }

    /// Creates a new note using a closure-based completion handler.
    /// - Parameters:
    ///   - note: The `NoteViewModel` representing the note to create.
    ///   - completion: A completion handler called with the result of the operation.
    public func create(_ note: NoteViewModel, completion: @escaping (Result<Void, any Error>) -> Void) {
        storageService.create(note, completion: completion)
    }

    /// Updates an existing note using a closure-based completion handler.
    /// - Parameters:
    ///   - note: The `NoteViewModel` representing the note to update.
    ///   - completion: A completion handler called with the result of the operation.
    public func update(_ note: NoteViewModel, completion: @escaping (Result<Void, any Error>) -> Void) {
        storageService.update(note, completion: completion)
    }

    /// Deletes notes using a closure-based completion handler.
    /// - Parameters:
    ///   - notes: An array of `NoteViewModel` instances to delete.
    ///   - completion: A completion handler called with the result of the operation.
   public func delete(_ notes: [NoteViewModel], completion: @escaping (Result<Void, any Error>) -> Void) {
        storageService.delete(notes, completion: completion)
    }

    /// Returns a publisher to create a new note.
    /// - Parameters:
    ///   - note: The `NoteViewModel` representing the note to create.
    /// - Returns: A publisher emitting success or error.
    public func createPublisher(_ note: NoteViewModel) -> AnyPublisher<Void, any Error> {
        return storageService.createPublisher(note)
    }

    /// Returns a publisher to update an existing note.
    /// - Parameters:
    ///   - note: The `NoteViewModel` representing the note to update.
    /// - Returns: A publisher emitting success or error.
    public func updatePublisher(_ note: NoteViewModel) -> AnyPublisher<Void, any Error> {
        return storageService.updatePublisher(note)
    }

    /// Returns a publisher to delete notes.
    /// - Parameters:
    ///   - notes: An array of `NoteViewModel` instances to delete.
    /// - Returns: A publisher emitting success or error.
    public func deletePublisher(_ notes: [NoteViewModel]) -> AnyPublisher<Void, any Error> {
        return storageService.deletePublisher(notes)
    }
    
    /// Calls closure whenever an event is triggered.
    /// - Parameter onEvent: Closure to call whenever an concurrency event occurs in storage
    public func subscribeToEvents(onEvent: @escaping @Sendable @MainActor (NoteViewModel) async -> Void) -> Task<Void, Never> {
        return Task {
            for await task in await eventStream.noteStream() {
                if Task.isCancelled { break }
                let note = await task.value
                await onEvent(note)
            }
        }
    }
    
}
