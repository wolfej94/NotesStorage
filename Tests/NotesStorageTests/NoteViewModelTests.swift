//
//  NoteViewModelTests.swift
//  NotesStorage
//
//  Created by James Wolfe on 17/01/2025.
//

@testable import NotesStorage
import CoreData
import Foundation
import Testing

@Suite("Note View Model Tests")
@MainActor
final class NoteViewModelTests {

    @Test("Test initializer throws when when uuid is missing")
    func initializerThrowsWhenUuidIsMissing() async throws {
        do {
            try _ = NoteViewModel(from: TestData.noteWithMissingID)
            Issue.record("Initializer should throw")
        } catch let error as StorageError {
            #expect(error.localizedDescription == StorageError.missingId.localizedDescription)
        }
    }

    @Test("Test initializer sets title value correctly", arguments: [
        ("Hello World", "Hello World"),
        ("", ""),
        (nil, "")
    ])
    func initializerSetsTitleValueCorrectly(title: String?, expectedTitle: String) async throws {
        let note = TestData.note(withTitle: title)
        let viewModel = try NoteViewModel(from: note)
        #expect(viewModel.title == expectedTitle)
    }

    @Test("Test initializer sets body value correctly", arguments: [
        ("Hello World", "Hello World"),
        ("", ""),
        (nil, "")
    ])
    func initializerSetsBodyValueCorrectly(body: String?, expectedBody: String) async throws {
        let note = TestData.note(withBody: body)
        let viewModel = try NoteViewModel(from: note)
        #expect(viewModel.body == expectedBody)
    }
}

extension NoteViewModelTests {
    @MainActor
    struct TestData {
        static let context = MockManagedObjectContext()
        static let noteWithMissingID: Note = {
            let note = context.createObject(ofType: Note.self)
            note.id = nil
            note.title = "Test"
            note.body = "Test"
            note.createdAt = Date()
            note.updatedAt = Date()
            return note
        }()

        static func note(withTitle title: String?) -> Note {
            let note = context.createObject(ofType: Note.self)
            note.id = UUID()
            note.title = title
            note.body = "Test"
            note.createdAt = Date()
            note.updatedAt = Date()
            return note
        }

        static func note(withBody body: String?) -> Note {
            let note = context.createObject(ofType: Note.self)
            note.id = UUID()
            note.title = "Test"
            note.body = body
            note.createdAt = Date()
            note.updatedAt = Date()
            return note
        }
    }
}
