//
//  StorageError.swift
//  NotesStorage
//
//  Created by James Wolfe on 16/01/2025.
//

/// An enumeration representing possible errors encountered in the storage layer.
public enum StorageError: Error {

    /// Error indicating that a specific object could not be found.
    /// - Parameter description: A string describing the missing object.
    case objectNotFound(String)

    /// Error indicating that an unexpected error occurred.
    /// - Parameter error: The underlying unexpected error.
    case unexpected(Error)

    /// Error indicating that an object's ID is missing.
    case missingId

    /// Error indicating that an object's type is incorrect
    case typeMismatch

}
