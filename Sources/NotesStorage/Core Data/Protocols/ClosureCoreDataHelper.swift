//
//  ClosureCoreDataHelper.swift
//  Storage
//
//  Created by James Wolfe on 03/12/2024.
//

import CoreData

internal protocol ClosureCoreDataHelper {

    /// Inserts a note using a closure-based completion handler.
    /// - Parameters:
    ///   - note: The `NoteViewModel` representing the note to insert.
    ///   - context: The managed object context to insert into.
    ///   - completion: A completion handler called with the result of the operation.
    func insert(note: NoteViewModel,
                in context: ManagedObjectContext,
                completion: @escaping (Result<Void, Error>) -> Void)

    /// Updates a note using a closure-based completion handler.
    /// - Parameters:
    ///   - note: The `NoteViewModel` representing the note to update.
    ///   - context: The managed object context to update in.
    ///   - completion: A completion handler called with the result of the operation.
    func update(note: NoteViewModel,
                in context: ManagedObjectContext,
                completion: @escaping (Result<Void, Error>) -> Void)

    /// Deletes objects by their IDs using a closure-based completion handler.
    /// - Parameters:
    ///   - ids: An array of `NSManagedObjectID` to delete.
    ///   - context: The managed object context to delete from.
    ///   - completion: A completion handler called with the result of the operation.
    func delete(ids: [NSManagedObjectID],
                in context: ManagedObjectContext,
                completion: @escaping (Result<Void, Error>) -> Void)

}
