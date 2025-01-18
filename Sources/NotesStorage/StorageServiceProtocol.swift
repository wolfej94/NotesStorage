//
//  StorageServiceProtocol.swift
//  NotesStorage
//
//  Created by James Wolfe on 16/01/2025.
//

import Combine
import Foundation

/// A protocol defining storage operations for notes.
/// Provides support for asynchronous, synchronous, closure-based, and Combine-based operations.
public protocol StorageServiceProtocol: Sendable {

    /// Creates a new note asynchronously.
    /// - Parameters:
    ///   - note: The `NoteViewModel` representing the note to create.
    /// - Throws: An error if the creation fails.
    func create(_ note: NoteViewModel) async throws

    /// Reads all notes from storage.
    /// - Returns: An array of `NoteViewModel` instances.
    /// - Throws: An error if the read operation fails.
    func read() throws -> [NoteViewModel]

    /// Updates an existing note asynchronously.
    /// - Parameters:
    ///   - note: The `NoteViewModel` representing the note to update.
    /// - Throws: An error if the update fails.
    func update(_ note: NoteViewModel) async throws

    /// Deletes notes asynchronously.
    /// - Parameters:
    ///   - notes: An array of `NoteViewModel` instances to delete.
    /// - Throws: An error if the deletion fails.
    func delete(_ notes: [NoteViewModel]) async throws

    /// Creates a new note using a closure-based completion handler.
    /// - Parameters:
    ///   - note: The `NoteViewModel` representing the note to create.
    ///   - completion: A completion handler called with the result of the operation.
    func create(_ note: NoteViewModel, completion: @escaping (Result<Void, any Error>) -> Void)

    /// Updates an existing note using a closure-based completion handler.
    /// - Parameters:
    ///   - note: The `NoteViewModel` representing the note to update.
    ///   - completion: A completion handler called with the result of the operation.
    func update(_ note: NoteViewModel, completion: @escaping (Result<Void, any Error>) -> Void)

    /// Deletes notes using a closure-based completion handler.
    /// - Parameters:
    ///   - notes: An array of `NoteViewModel` instances to delete.
    ///   - completion: A completion handler called with the result of the operation.
    func delete(_ notes: [NoteViewModel], completion: @escaping (Result<Void, any Error>) -> Void)

    /// Returns a publisher to create a new note.
    /// - Parameters:
    ///   - note: The `NoteViewModel` representing the note to create.
    /// - Returns: A publisher emitting success or error.
    func createPublisher(_ note: NoteViewModel) -> AnyPublisher<Void, any Error>

    /// Returns a publisher to update an existing note.
    /// - Parameters:
    ///   - note: The `NoteViewModel` representing the note to update.
    /// - Returns: A publisher emitting success or error.
    func updatePublisher(_ note: NoteViewModel) -> AnyPublisher<Void, any Error>

    /// Returns a publisher to delete notes.
    /// - Parameters:
    ///   - notes: An array of `NoteViewModel` instances to delete.
    /// - Returns: A publisher emitting success or error.
    func deletePublisher(_ notes: [NoteViewModel]) -> AnyPublisher<Void, any Error>

}
