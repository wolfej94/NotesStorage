//
//  AsyncCoreDataHelper.swift
//  Storage
//
//  Created by James Wolfe on 03/12/2024.
//

import CoreData

internal protocol AsyncCoreDataHelper {

    /// Inserts a note asynchronously.
    /// - Parameters:
    ///   - note: The `NoteViewModel` representing the note to insert.
    ///   - context: The managed object context to insert into.
    /// - Throws: An error if insertion fails.
    func insert(note: NoteViewModel,
                in context: ManagedObjectContext) async throws

    /// Updates a note asynchronously.
    /// - Parameters:
    ///   - note: The `NoteViewModel` representing the note to update.
    ///   - context: The managed object context to update in.
    /// - Throws: An error if update fails.
    func update(note: NoteViewModel,
                in context: ManagedObjectContext) async throws

    /// Deletes objects asynchronously by their IDs.
    /// - Parameters:
    ///   - ids: An array of `NSManagedObjectID` to delete.
    ///   - context: The managed object context to delete from.
    /// - Throws: An error if deletion fails.
    func delete(ids: [NSManagedObjectID],
                in context: ManagedObjectContext) async throws

}
