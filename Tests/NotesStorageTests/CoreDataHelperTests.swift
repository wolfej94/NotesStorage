//
//  CoreDataHelperTests.swift
//  NotesStorage
//
//  Created by James Wolfe on 17/01/2025.
//

@testable import NotesStorage
import CoreData
import Combine
import Foundation
import Testing

extension Tag {
    enum CoreDataHelperTestTag {}
}

extension Tag.CoreDataHelperTestTag {
    @Tag static var sync: Tag
    @Tag static var async: Tag
    @Tag static var combine: Tag
    @Tag static var insert: Tag
    @Tag static var update: Tag
    @Tag static var fetch: Tag
    @Tag static var delete: Tag
}

@Suite("Core Data Helper Test")
final class CoreDataHelperTests {

    private let context: MockManagedObjectContext
    private let subject: DefaultCoreDataHelper
    private var cancellables = Set<AnyCancellable>()

    init() {
        self.context = MockManagedObjectContext()
        self.subject = DefaultCoreDataHelper()
    }

    @Test("Test fetch object returns correct result",
          .tags(Tag.CoreDataHelperTestTag.sync, Tag.CoreDataHelperTestTag.fetch))
    func fetchObjectReturnsCorrectResult() throws {
        let fetchedNote = TestData.note(in: context)
        context.fetchResult = .success([fetchedNote])
        let note = try subject.fetchManagedObject(ofType: Note.self, byID: UUID(), in: context)
        #expect(note == fetchedNote)
        #expect(context.fetchCalled)
    }

    @Test("Test fetch object throw when fetch request fails",
          .tags(Tag.CoreDataHelperTestTag.sync, Tag.CoreDataHelperTestTag.fetch))
    func fetchObjectThrowsWhenFetchRequestFails() throws {
        context.fetchResult = .failure(MockError.generic)
        do {
            _ = try subject.fetchManagedObject(ofType: Note.self, byID: UUID(), in: context)
            Issue.record("Fetch object should throw.")
        } catch let error as MockError {
            #expect(error == .generic)
        }
    }

    @Test("Test fetch objects succeeds when no issues occur",
          .tags(Tag.CoreDataHelperTestTag.sync, Tag.CoreDataHelperTestTag.fetch))
    func fetchObjectsSucceedsWhenNoIssuesOccur() throws {
        let note = TestData.note(in: context)
        context.fetchResult = .success([note])
        let notes = try subject.fetchManagedObjects(ofType: Note.self, byIDs: [UUID()], in: context)
        #expect(notes.first?.id == note.id)
    }

    @Test("Test fetch objects throws when result type is wrong",
          .tags(Tag.CoreDataHelperTestTag.sync, Tag.CoreDataHelperTestTag.fetch))
    func fetchObjectsThrowsWhenResultTypeIsWrong() throws {
        context.fetchResult = .success([NSManagedObject()])
        do {
            _ = try subject.fetchManagedObjects(ofType: Note.self, byIDs: [UUID()], in: context)
        } catch let error as StorageError {
            #expect(error.localizedDescription == StorageError.typeMismatch.localizedDescription)
        }
    }

    @Test("Test fetch objects throw when fetch request fails",
          .tags(Tag.CoreDataHelperTestTag.sync, Tag.CoreDataHelperTestTag.fetch))
    func fetchObjectsThrowsWhenRequestFails() throws {
        context.fetchResult = .failure(MockError.generic)
        do {
            _ = try subject.fetchManagedObjects(ofType: Note.self, byIDs: [UUID()], in: context)
            Issue.record("Fetch objects should throw.")
        } catch let error as MockError {
            #expect(error == .generic)
        }
    }

    @Test("Test fetch object IDs returns correct result",
          .tags(Tag.CoreDataHelperTestTag.sync, Tag.CoreDataHelperTestTag.fetch))
    func fetchObjectIDsReturnsCorrectResult() throws {
        let fetchedNote = TestData.note(in: context)
        context.fetchResult = .success([fetchedNote])
        let ids = try subject.fetchObjectIDs(ofType: Note.self, for: [UUID()], in: context)
        #expect(ids.first == fetchedNote.objectID && ids.count == 1)
        #expect(context.fetchCalled)
    }

    @Test("Test fetch object IDs throw when fetch request fails",
          .tags(Tag.CoreDataHelperTestTag.sync, Tag.CoreDataHelperTestTag.fetch))
    func fetchObjectIDsThrowsWhenRequestFails() throws {
        context.fetchResult = .failure(MockError.generic)
        do {
            _ = try subject.fetchObjectIDs(ofType: Note.self, for: [UUID()], in: context)
            Issue.record("Fetch object ids should throw.")
        } catch let error as MockError {
            #expect(error == .generic)
        }
    }
    
}

// MARK: - Async Methods
extension CoreDataHelperTests {

    @Test("Test insert succeeds when no issues occur",
          .tags(Tag.CoreDataHelperTestTag.async, Tag.CoreDataHelperTestTag.insert))
    func insertSucceedsWhenNoIssuesOccur() async throws {
        context.saveResult = .success(())
        try await subject.insert(note: TestData.noteViewModel, in: context)
        #expect(context.insertCalled)
        #expect(context.saveCalled)
        #expect(context.performAndWaitCalled)
        guard let insertedNote = context.insertedObject as? Note else {
            Issue.record("Object should be of type `Note`")
            return
        }
        #expect(insertedNote.id == TestData.noteViewModel.id)
    }

    @Test("Test insert throws when save fails",
          .tags(Tag.CoreDataHelperTestTag.async, Tag.CoreDataHelperTestTag.insert))
    func insertThrowsWhenSaveFails() async throws {
        context.saveResult = .failure(MockError.generic)
        do {
            try await subject.insert(note: TestData.noteViewModel, in: context)
            Issue.record("Insert should throw")
        } catch let error as MockError {
            #expect(error == .generic)
        }
    }

    @Test("Test update succeeds when no issues occur",
          .tags(Tag.CoreDataHelperTestTag.async, Tag.CoreDataHelperTestTag.update))
    func updateSucceedsWhenNoIssuesOccur() async throws {
        context.saveResult = .success(())
        context.fetchResult = .success([TestData.note(in: context)])
        try await subject.update(note: TestData.noteViewModel, in: context)
        #expect(context.saveCalled)
        #expect(context.fetchCalled)
        #expect(context.performAndWaitCalled)
    }

    @Test("Test update throws when save fails",
          .tags(Tag.CoreDataHelperTestTag.async, Tag.CoreDataHelperTestTag.update))
    func updateThrowsWhenSaveFails() async throws {
        context.fetchResult = .success([TestData.note(in: context)])
        let updatedNoteViewModel = TestData.noteViewModel
        context.saveResult = .failure(MockError.generic)
        do {
            try await subject.update(note: updatedNoteViewModel, in: context)
        } catch let error as MockError {
            #expect(error == .generic)
        }
    }

    @Test("Test update throws when fetch returns no results",
          .tags(Tag.CoreDataHelperTestTag.async, Tag.CoreDataHelperTestTag.update))
    func updateThrowsWhenFetchReturnsNoResults() async throws {
        context.fetchResult = .success([])
        let updatedNoteViewModel = TestData.noteViewModel
        context.saveResult = .success(())
        do {
            try await subject.update(note: updatedNoteViewModel, in: context)
        } catch let error as StorageError {
            let expectedError = StorageError
                .objectNotFound("Note with id \(updatedNoteViewModel.id) not found")
            #expect(error.localizedDescription == expectedError.localizedDescription)
        }
    }

    @Test("Test update throws when save fails",
          .tags(Tag.CoreDataHelperTestTag.async, Tag.CoreDataHelperTestTag.update))
    func updateThrowsWhenFetchFails() async throws {
        context.fetchResult = .failure(MockError.generic)
        let updatedNoteViewModel = TestData.noteViewModel
        context.saveResult = .success(())
        do {
            try await subject.update(note: updatedNoteViewModel, in: context)
        } catch let error as MockError {
            #expect(error == .generic)
        }
    }

    @Test("Test delete succeeds when no issues occur",
          .tags(Tag.CoreDataHelperTestTag.async, Tag.CoreDataHelperTestTag.delete))
    func deleteSucceedsWhenNoIssuesOccur() async throws {
        let note = TestData.note(in: context)
        context.saveResult = .success(())
        context.executeResult = .success(())
        try await subject.delete(ids: [note.objectID], in: context)
        #expect(context.saveCalled)
        #expect(context.executeCalled)
        #expect(context.performAndWaitCalled)
    }

    @Test("Test delete throws when delete request fails",
          .tags(Tag.CoreDataHelperTestTag.async, Tag.CoreDataHelperTestTag.delete))
    func deleteThrowsWhenDeleteFails() async throws {
        let note = TestData.note(in: context)
        context.saveResult = .success(())
        context.executeResult = .failure(MockError.generic)
        do {
            try await subject.delete(ids: [note.objectID], in: context)
        } catch let error as MockError {
            #expect(error == .generic)
        }
    }

    @Test("Test delete throws when save fails",
          .tags(Tag.CoreDataHelperTestTag.async, Tag.CoreDataHelperTestTag.delete))
    func deleteThrowsWhenSaveFails() async throws {
        let note = TestData.note(in: context)
        context.saveResult = .failure(MockError.generic)
        context.executeResult = .success(())
        do {
            try await subject.delete(ids: [note.objectID], in: context)
        } catch let error as MockError {
            #expect(error == .generic)
        }
    }

    @Test("Test delete throws when fetch returns no results",
          .tags(Tag.CoreDataHelperTestTag.async, Tag.CoreDataHelperTestTag.delete))
    func deleteThrowsWhenFetchReturnsNoResults() async throws {
        let note = TestData.note(in: context)
        context.saveResult = .success(())
        context.executeResult = .success(())
        context.fetchResult = .success([])
        do {
            try await subject.delete(ids: [note.objectID], in: context)
        } catch let error as StorageError {
            let expectedError = StorageError
                .objectNotFound("Note with id \(note.id?.uuidString ?? "") not found")
            #expect(error.localizedDescription == expectedError.localizedDescription)
        }
    }

}

// MARK: - Combine Methods
extension CoreDataHelperTests {

    @Test("Test insert publisher succeeds when no issues occur",
          .tags(Tag.CoreDataHelperTestTag.combine, Tag.CoreDataHelperTestTag.insert))
    func insertPublisherSucceedsWhenNoIssuesOccur() async throws {
        context.saveResult = .success(())
        try await withCheckedThrowingContinuation { continuation in
            subject.insertPublisher(note: TestData.noteViewModel, in: context)
                .sink(receiveCompletion: { result in
                    if case .failure(let error) = result {
                        continuation.resume(throwing: error)
                    }
                }, receiveValue: { _ in
                    continuation.resume()
                })
                .store(in: &cancellables)
        }
        #expect(context.insertCalled)
        #expect(context.saveCalled)
        #expect(context.performAndWaitCalled)
        guard let insertedNote = context.insertedObject as? Note else {
            Issue.record("Object should be of type `Note`")
            return
        }
        #expect(insertedNote.id == TestData.noteViewModel.id)
    }

    @Test("Test insert publisher throws when save fails",
          .tags(Tag.CoreDataHelperTestTag.combine, Tag.CoreDataHelperTestTag.insert))
    func insertPublisherThrowsWhenSaveFails() async throws {
        context.saveResult = .failure(MockError.generic)
        do {
            try await withCheckedThrowingContinuation { continuation in
                subject.insertPublisher(note: TestData.noteViewModel, in: context)
                    .sink(receiveCompletion: { result in
                        if case .failure(let error) = result {
                            continuation.resume(throwing: error)
                        }
                    }, receiveValue: { _ in
                        continuation.resume()
                    })
                    .store(in: &cancellables)
            }
            Issue.record("Insert should throw")
        } catch let error as MockError {
            #expect(error == .generic)
        }
    }

    @Test("Test update publisher succeeds when no issues occur",
          .tags(Tag.CoreDataHelperTestTag.combine, Tag.CoreDataHelperTestTag.update))
    func updatePublisherSucceedsWhenNoIssuesOccur() async throws {
        context.saveResult = .success(())
        context.fetchResult = .success([TestData.note(in: context)])
        try await withCheckedThrowingContinuation { continuation in
            subject.updatePublisher(note: TestData.noteViewModel, in: context)
                .sink(receiveCompletion: { result in
                    if case .failure(let error) = result {
                        continuation.resume(throwing: error)
                    }
                }, receiveValue: { _ in
                    continuation.resume()
                })
                .store(in: &cancellables)
        }
        #expect(context.saveCalled)
        #expect(context.fetchCalled)
        #expect(context.performAndWaitCalled)
    }

    @Test("Test update publisher throws when save fails",
          .tags(Tag.CoreDataHelperTestTag.combine, Tag.CoreDataHelperTestTag.update))
    func updatePublisherThrowsWhenSaveFails() async throws {
        context.fetchResult = .success([TestData.note(in: context)])
        let updatedNoteViewModel = TestData.noteViewModel
        context.saveResult = .failure(MockError.generic)
        do {
            try await withCheckedThrowingContinuation { continuation in
                subject.updatePublisher(note: updatedNoteViewModel, in: context)
                    .sink(receiveCompletion: { result in
                        if case .failure(let error) = result {
                            continuation.resume(throwing: error)
                        }
                    }, receiveValue: { _ in
                        continuation.resume()
                    })
                    .store(in: &cancellables)
            }
        } catch let error as MockError {
            #expect(error == .generic)
        }
    }

    @Test("Test update publisher throws when fetch returns no results",
          .tags(Tag.CoreDataHelperTestTag.combine, Tag.CoreDataHelperTestTag.update))
    func updatePublisherThrowsWhenFetchReturnsNoResults() async throws {
        context.fetchResult = .success([])
        let updatedNoteViewModel = TestData.noteViewModel
        context.saveResult = .success(())
        do {
            try await withCheckedThrowingContinuation { continuation in
                subject.updatePublisher(note: updatedNoteViewModel, in: context)
                    .sink(receiveCompletion: { result in
                        if case .failure(let error) = result {
                            continuation.resume(throwing: error)
                        }
                    }, receiveValue: { _ in
                        continuation.resume()
                    })
                    .store(in: &cancellables)
            }
        } catch let error as StorageError {
            let expectedError = StorageError
                .objectNotFound("Note with id \(updatedNoteViewModel.id) not found")
            #expect(error.localizedDescription == expectedError.localizedDescription)
        }
    }

    @Test("Test update publisher throws when save fails",
          .tags(Tag.CoreDataHelperTestTag.combine, Tag.CoreDataHelperTestTag.update))
    func updatePublisherThrowsWhenFetchFails() async throws {
        context.fetchResult = .failure(MockError.generic)
        let updatedNoteViewModel = TestData.noteViewModel
        context.saveResult = .success(())
        do {
            try await withCheckedThrowingContinuation { continuation in
                subject.updatePublisher(note: updatedNoteViewModel, in: context)
                    .sink(receiveCompletion: { result in
                        if case .failure(let error) = result {
                            continuation.resume(throwing: error)
                        }
                    }, receiveValue: { _ in
                        continuation.resume()
                    })
                    .store(in: &cancellables)
            }
        } catch let error as MockError {
            #expect(error == .generic)
        }
    }

    @Test("Test delete publisher succeeds when no issues occur",
          .tags(Tag.CoreDataHelperTestTag.combine, Tag.CoreDataHelperTestTag.delete))
    func deletePublisherSucceedsWhenNoIssuesOccur() async throws {
        let note = TestData.note(in: context)
        context.saveResult = .success(())
        context.executeResult = .success(())
        try await withCheckedThrowingContinuation { continuation in
            subject.deletePublisher(ids: [note.objectID], in: context)
                .sink(receiveCompletion: { result in
                    if case .failure(let error) = result {
                        continuation.resume(throwing: error)
                    }
                }, receiveValue: { _ in
                    continuation.resume()
                })
                .store(in: &cancellables)
        }
        #expect(context.saveCalled)
        #expect(context.executeCalled)
        #expect(context.performAndWaitCalled)
    }

    @Test("Test delete publisher throws when delete request fails",
          .tags(Tag.CoreDataHelperTestTag.combine, Tag.CoreDataHelperTestTag.delete))
    func deletePublisherThrowsWhenDeleteFails() async throws {
        let note = TestData.note(in: context)
        context.saveResult = .success(())
        context.executeResult = .failure(MockError.generic)
        do {
            try await withCheckedThrowingContinuation { continuation in
                subject.deletePublisher(ids: [note.objectID], in: context)
                    .sink(receiveCompletion: { result in
                        if case .failure(let error) = result {
                            continuation.resume(throwing: error)
                        }
                    }, receiveValue: { _ in
                        continuation.resume()
                    })
                    .store(in: &cancellables)
            }
        } catch let error as MockError {
            #expect(error == .generic)
        }
    }

    @Test("Test delete publisher throws when save fails",
          .tags(Tag.CoreDataHelperTestTag.combine, Tag.CoreDataHelperTestTag.delete))
    func deletePublisherThrowsWhenSaveFails() async throws {
        let note = TestData.note(in: context)
        context.saveResult = .failure(MockError.generic)
        context.executeResult = .success(())
        do {
            try await withCheckedThrowingContinuation { continuation in
                subject.deletePublisher(ids: [note.objectID], in: context)
                    .sink(receiveCompletion: { result in
                        if case .failure(let error) = result {
                            continuation.resume(throwing: error)
                        }
                    }, receiveValue: { _ in
                        continuation.resume()
                    })
                    .store(in: &cancellables)
            }
        } catch let error as MockError {
            #expect(error == .generic)
        }
    }

    @Test("Test delete publisher throws when fetch returns no results",
          .tags(Tag.CoreDataHelperTestTag.combine, Tag.CoreDataHelperTestTag.delete))
    func deletePublisherThrowsWhenFetchReturnsNoResults() async throws {
        let note = TestData.note(in: context)
        context.saveResult = .success(())
        context.executeResult = .success(())
        context.fetchResult = .success([])
        do {
            try await withCheckedThrowingContinuation { continuation in
                subject.deletePublisher(ids: [note.objectID], in: context)
                    .sink(receiveCompletion: { result in
                        if case .failure(let error) = result {
                            continuation.resume(throwing: error)
                        }
                    }, receiveValue: { _ in
                        continuation.resume()
                    })
                    .store(in: &cancellables)
            }
        } catch let error as StorageError {
            let expectedError = StorageError
                .objectNotFound("Note with id \(note.id?.uuidString ?? "") not found")
            #expect(error.localizedDescription == expectedError.localizedDescription)
        }
    }

}

extension CoreDataHelperTests {
    struct TestData {
        static func note(in context: MockManagedObjectContext) -> Note {
            let note = context.createObject(ofType: Note.self)
            note.id = UUID()
            note.title = "Test"
            note.body = "Test"
            note.createdAt = Date()
            note.updatedAt = Date()
            return note
        }
        static let noteViewModel = NoteViewModel(id: UUID(), title: "Test", body: "Test")
    }
}
