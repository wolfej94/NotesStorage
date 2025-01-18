//
//  SynchronousCoreDataHelper.swift
//  Storage
//
//  Created by James Wolfe on 03/12/2024.
//

import CoreData

internal protocol SynchronousCoreDataHelper {

    /// Fetches object IDs of managed objects by their UUIDs.
    /// - Parameters:
    ///   - type: The `NSManagedObject` subclass type.
    ///   - ids: An array of UUIDs to fetch object IDs for.
    ///   - context: The managed object context to fetch from.
    /// - Returns: An array of `NSManagedObjectID` corresponding to the given UUIDs.
    /// - Throws: An error if fetching fails.
    func fetchObjectIDs<T: NSManagedObject>(ofType type: T.Type,
                                            for ids: [UUID],
                                            in context: ManagedObjectContext) throws -> [NSManagedObjectID]

    /// Fetches a managed object of a specific type by its UUID.
    /// - Parameters:
    ///   - type: The `NSManagedObject` subclass type.
    ///   - id: The UUID of the object to fetch.
    ///   - context: The managed object context to fetch from.
    /// - Returns: The fetched object, or `nil` if not found.
    /// - Throws: An error if the fetch request fails.
    func fetchManagedObject<T: NSManagedObject>(ofType type: T.Type,
                                                byID id: UUID,
                                                in context: ManagedObjectContext) throws -> T?

    /// Fetches managed objects of a specific type by their UUIDs.
    /// - Parameters:
    ///   - type: The `NSManagedObject` subclass type.
    ///   - ids: An optional array of UUIDs to filter by. If nil, all objects of the type are fetched.
    ///   - context: The managed object context to fetch from.
    /// - Returns: An array of fetched objects.
    /// - Throws: An error if the fetch request fails.
    func fetchManagedObjects<T: NSManagedObject>(ofType type: T.Type,
                                                 byIDs ids: [UUID]?,
                                                 in context: ManagedObjectContext) throws -> [T]

}
