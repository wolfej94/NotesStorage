//
//  CombineCoreDataHelper.swift
//  Storage
//
//  Created by James Wolfe on 03/12/2024.
//

import Combine
import CoreData

internal protocol CombineCoreDataHelper {

    /// Returns a publisher to insert a note.
    /// - Parameters:
    ///   - note: The `NoteViewModel` representing the note to insert.
    ///   - context: The managed object context to insert into.
    /// - Returns: A publisher emitting success or error.
    func insertPublisher(note: NoteViewModel,
                         in context: ManagedObjectContext) -> AnyPublisher<Void, Error>

    /// Returns a publisher to update a note.
    /// - Parameters:
    ///   - note: The `NoteViewModel` representing the note to update.
    ///   - context: The managed object context to update in.
    /// - Returns: A publisher emitting success or error.
    func updatePublisher(note: NoteViewModel,
                         in context: ManagedObjectContext) -> AnyPublisher<Void, Error>

    /// Returns a publisher to delete objects by their IDs.
    /// - Parameters:
    ///   - ids: An array of `NSManagedObjectID` to delete.
    ///   - context: The managed object context to delete from.
    /// - Returns: A publisher emitting success or error.
    func deletePublisher(ids: [NSManagedObjectID],
                         in context: ManagedObjectContext) -> AnyPublisher<Void, Error>

}
