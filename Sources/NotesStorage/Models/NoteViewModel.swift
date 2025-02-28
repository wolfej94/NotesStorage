//
//  Note.swift
//  NotesStorage
//
//  Created by James Wolfe on 16/01/2025.
//

import Foundation
import CoreData

/// A view model representing a Note entity in the application.
public struct NoteViewModel: Sendable, Identifiable, Hashable {

    /// The unique identifier for the note.
    public let id: UUID
    /// The title of the note.
    public var title: String
    /// The body content of the note.
    public var body: String
    /// The creation date of the note.
    public let createdAt: Date?
    /// The last updated date of the note.
    public let updatedAt: Date?

    /// Initializes a `NoteViewModel` from a `Note` managed object.
    /// - Parameter note: The `Note` object to initialize from.
    /// - Throws: `StorageError.missingId` if the `id` of the `Note` is missing.
    internal init(from note: Note) throws {
        guard let id = note.id else { throw StorageError.missingId }
        self.id = id
        self.title = note.title ?? ""
        self.body = note.body ?? ""
        self.createdAt = note.createdAt
        self.updatedAt = note.updatedAt
    }

    /// Initializes a new `NoteViewModel` with the given parameters.
    /// - Parameters:
    ///   - id: The unique identifier for the note.
    ///   - title: The title of the note.
    ///   - body: The body content of the note.
    public init(id: UUID, title: String, body: String) {
        self.id = id
        self.title = title
        self.body = body
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: NoteViewModel, rhs: NoteViewModel) -> Bool {
        lhs.id == rhs.id
    }
    
}
