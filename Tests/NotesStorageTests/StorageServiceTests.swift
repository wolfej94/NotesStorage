import Testing
import Foundation
import Combine
import CoreData
@testable import NotesStorage

extension Tag {
    enum StorageServiceTestTag {}
}

extension Tag.StorageServiceTestTag {
    @Tag static var sync: Tag
    @Tag static var async: Tag
    @Tag static var combine: Tag
    @Tag static var closure: Tag
    @Tag static var create: Tag
    @Tag static var read: Tag
    @Tag static var update: Tag
    @Tag static var delete: Tag
    @Tag static var edgeCases: Tag
}

@Suite("Storage Service Tests")
final class StorageServiceTests {

    let mockCoreData: MockCoreDataHelper
    let subject: StorageService
    let context: NSManagedObjectContext
    var cancellables = Set<AnyCancellable>()

    init() {
        self.mockCoreData = MockCoreDataHelper()
        self.subject = StorageService()
        self.context = subject.container.viewContext
        self.subject.coreData = mockCoreData
    }

}

// MARK: - Edge Cases
extension StorageServiceTests {

    @Test("Test handling of empty note list",
          .tags(Tag.StorageServiceTestTag.edgeCases, Tag.StorageServiceTestTag.read)
    )
    func handlesEmptyNoteList() throws {
        mockCoreData.dataToReturnForFetchObjects = []
        let notes = try subject.read()
        #expect(notes.isEmpty, "Notes list should be empty")
    }

    @Test("Test handling of invalid UUID",
          .tags(Tag.StorageServiceTestTag.edgeCases, Tag.StorageServiceTestTag.read)
    )
    func handlesInvalidUUID() throws {
        mockCoreData.errorToThrowForFetchObjects = MockError.generic
        do {
            _ = try subject.read()
            Issue.record("Fetch should throw for invalid UUID")
        } catch let error as MockError {
            #expect(error == .generic, "Expected generic error")
        }
    }
}

// MARK: - Synchronous Methods
extension StorageServiceTests {
    @Test("Test error throws when fetch notes fails",
          .tags(Tag.StorageServiceTestTag.sync, Tag.StorageServiceTestTag.read)
    )
    func errorThrowsWhenFetchNotesFails() throws {
        mockCoreData.errorToThrowForFetchObjects = MockError.generic
        do {
            _ = try subject.read()
            Issue.record("Fetch should throw")
        } catch let error as MockError {
            #expect(error == .generic)
        }
    }

    @Test("Test data returned when fetch notes succeeds",
          .tags(Tag.StorageServiceTestTag.sync, Tag.StorageServiceTestTag.read)
    )
    func dataReturnedThrowWhenFetchNotesSucceeds() throws {
        mockCoreData.dataToReturnForFetchObjects = [TestData.noteStorageObject(withContext: context)]
        let notes = try subject.read()
        #expect(notes.first?.id == TestData.noteViewModel.id)
    }
}

// MARK: - Async/Await Methods
extension StorageServiceTests {

    @Test("Test async create throws when insert fails",
          .tags(Tag.StorageServiceTestTag.async, Tag.StorageServiceTestTag.create)
    )
    func asyncCreateThrowsWhenInsertFails() async throws {
        mockCoreData.errorToThrowForInsert = MockError.generic
        do {
            _ = try await subject.create(TestData.noteViewModel)
            Issue.record("Create should throw")
        } catch let error as MockError {
            #expect(error == .generic)
        }
    }

    @Test("Test async create does not throw when create notes succeeds",
          .tags(Tag.StorageServiceTestTag.async, Tag.StorageServiceTestTag.create)
    )
    func asyncCreateDoesNotThrowWhenCreateNotesSucceeds() async throws {
        do {
            _ = try await subject.create(TestData.noteViewModel)
        } catch {
            Issue.record("Create should not throw")
        }
    }

    @Test("Test async update throws when insert fails",
          .tags(Tag.StorageServiceTestTag.async, Tag.StorageServiceTestTag.update)
    )
    func asyncUpdateThrowsWhenInsertFails() async throws {
        mockCoreData.errorToThrowForUpdate = MockError.generic
        do {
            _ = try await subject.update(TestData.noteViewModel)
            Issue.record("Update should throw")
        } catch let error as MockError {
            #expect(error == .generic)
        }
    }

    @Test("Test async update does not throw when create notes succeeds",
          .tags(Tag.StorageServiceTestTag.async, Tag.StorageServiceTestTag.update)
    )
    func asyncUpdateDoesNotThrowWhenUpdateNotesSucceeds() async throws {
        do {
            _ = try await subject.update(TestData.noteViewModel)
        } catch {
            Issue.record("Update should not throw")
        }
    }

    @Test("Test async delete throws when delete notes fails",
          .tags(Tag.StorageServiceTestTag.async, Tag.StorageServiceTestTag.delete)
    )
    func asyncDeleteThrowsWhenDeleteNotesFails() async throws {
        mockCoreData.errorToThrowForDelete = MockError.generic
        do {
            try await subject.delete([TestData.noteViewModel])
            Issue.record("Delete should throw")
        } catch let error as MockError {
            #expect(error == .generic)
        }
    }

    @Test("Test async delete throws when fetch episode IDs fails",
          .tags(Tag.StorageServiceTestTag.async, Tag.StorageServiceTestTag.delete)
    )
    func asyncDeleteThrowsWhenFetchEpisodeIDsFails() async throws {
        mockCoreData.errorToThrowForFetchObjectIDs = MockError.generic
        do {
            try await subject.delete([TestData.noteViewModel])
            Issue.record("Delete should throw")
        } catch let error as MockError {
            #expect(error == .generic)
        }
    }

    @Test("Test async delete does not throw when delete notes succeeds",
          .tags(Tag.StorageServiceTestTag.async, Tag.StorageServiceTestTag.delete)
    )
    func asyncDeleteDoesNotThrowWhenDeleteSucceeds() async throws {
        do {
            try await subject.delete([TestData.noteViewModel])
        } catch {
            Issue.record("Delete should not throw")
        }
    }

}

// MARK: - Closure Methods
extension StorageServiceTests {

    @Test("Test closure create throws when insert fails",
          .tags(Tag.StorageServiceTestTag.closure, Tag.StorageServiceTestTag.create)
    )
    func closureCreateThrowsWhenInsertFails() async throws {
        mockCoreData.errorToThrowForInsert = MockError.generic
        do {
            try await withCheckedThrowingContinuation { continuation in
                subject.create(TestData.noteViewModel) { continuation.resume(with: $0) }
            }
            Issue.record("Create should throw")
        } catch let error as MockError {
            #expect(error == .generic)
        }
    }

    @Test("Test closure create does not throw when create notes succeeds",
          .tags(Tag.StorageServiceTestTag.closure, Tag.StorageServiceTestTag.create)
    )
    func closureCreateDoesNotThrowWhenCreateNotesSucceeds() async throws {
        mockCoreData.dataToReturnForFetchObject = TestData.noteStorageObject(withContext: context)
        do {
            try await withCheckedThrowingContinuation { continuation in
                subject.create(TestData.noteViewModel) { continuation.resume(with: $0) }
            }
        } catch {
            Issue.record("Create should not throw")
        }
    }

    @Test("Test closure update throws when insert fails",
          .tags(Tag.StorageServiceTestTag.closure, Tag.StorageServiceTestTag.update)
    )
    func closureUpdateThrowsWhenInsertFails() async throws {
        mockCoreData.errorToThrowForUpdate = MockError.generic
        do {
            try await withCheckedThrowingContinuation { continuation in
                subject.update(TestData.noteViewModel) { continuation.resume(with: $0) }
            }
            Issue.record("Update should throw")
        } catch let error as MockError {
            #expect(error == .generic)
        }
    }

    @Test("Test closure update does not throw when update notes succeeds",
          .tags(Tag.StorageServiceTestTag.closure, Tag.StorageServiceTestTag.update)
    )
    func closureUpdateDoesNotThrowWhenUpdateNotesSucceeds() async throws {
        mockCoreData.dataToReturnForFetchObject = TestData.noteStorageObject(withContext: context)
        do {
            try await withCheckedThrowingContinuation { continuation in
                subject.update(TestData.noteViewModel) { continuation.resume(with: $0) }
            }
        } catch {
            Issue.record("Update should not throw")
        }
    }

    @Test("Test closure delete throws when delete notes fails",
          .tags(Tag.StorageServiceTestTag.closure, Tag.StorageServiceTestTag.delete)
    )
    func closureDeleteThrowsWhenDeleteNotesFails() async throws {
        mockCoreData.errorToThrowForDelete = MockError.generic
        do {
            try await withCheckedThrowingContinuation { continuation in
                subject.delete([TestData.noteViewModel]) { continuation.resume(with: $0) }
            }
            Issue.record("Delete should throw")
        } catch let error as MockError {
            #expect(error == .generic)
        }
    }

    @Test("Test closure delete throws when fetch notes fails",
          .tags(Tag.StorageServiceTestTag.closure, Tag.StorageServiceTestTag.delete)
    )
    func closureDeleteThrowsWhenFetchNotesFails() async throws {
        mockCoreData.errorToThrowForFetchObjectIDs = MockError.generic
        do {
            try await withCheckedThrowingContinuation { continuation in
                subject.delete([TestData.noteViewModel]) { continuation.resume(with: $0) }
            }
            Issue.record("Delete should not throw")
        } catch let error as MockError {
            #expect(error == .generic)
        }
    }

    @Test("Test closure delete does not throw when delete notes succeeds",
          .tags(Tag.StorageServiceTestTag.closure, Tag.StorageServiceTestTag.delete)
    )
    func closureDeleteDoesNotThrowWhenDeleteSucceeds() async throws {
        do {
            try await withCheckedThrowingContinuation { continuation in
                subject.delete([TestData.noteViewModel]) { continuation.resume(with: $0) }
            }
        } catch {
            Issue.record("Delete should not throw")
        }
    }

}

// MARK: - Combine Publisher Methods
extension StorageServiceTests {

    @Test("Test combine create throws when insert fails",
          .tags(Tag.StorageServiceTestTag.combine, Tag.StorageServiceTestTag.create)
    )
    func combineCreateThrowsWhenInsertFails() async throws {
        mockCoreData.dataToReturnForFetchObject = TestData.noteStorageObject(withContext: context)
        mockCoreData.errorToThrowForInsert = MockError.generic
        do {
            try await withCheckedThrowingContinuation { continuation in
                subject.createPublisher(TestData.noteViewModel)
                    .sink(receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            continuation.resume(throwing: error)
                        }
                    }, receiveValue: { value in
                        continuation.resume(returning: value)
                    })
                    .store(in: &cancellables)
            }
            Issue.record("Create should throw")
        } catch let error as MockError {
            #expect(error == .generic)
        }
    }

    @Test("Test combine create does not throw when create notes succeeds",
          .tags(Tag.StorageServiceTestTag.combine, Tag.StorageServiceTestTag.create)
    )
    func combineCreateDoesNotThrowWhenCreateNotesSucceeds() async throws {
        mockCoreData.dataToReturnForFetchObject = TestData.noteStorageObject(withContext: context)
        mockCoreData.dataToReturnForFetchObjects = [TestData.noteStorageObject(withContext: context)]
        do {
            try await withCheckedThrowingContinuation { continuation in
                subject.createPublisher(TestData.noteViewModel)
                    .sink(receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            continuation.resume(throwing: error)
                        }
                    }, receiveValue: { value in
                        continuation.resume(returning: value)
                    })
                    .store(in: &cancellables)
            }
        } catch {
            Issue.record("Create should not throw")
        }
    }

    @Test("Test combine update throws when update fails",
          .tags(Tag.StorageServiceTestTag.combine, Tag.StorageServiceTestTag.update)
    )
    func combineUpdateThrowsWhenUpdateFails() async throws {
        mockCoreData.dataToReturnForFetchObject = TestData.noteStorageObject(withContext: context)
        mockCoreData.errorToThrowForUpdate = MockError.generic
        do {
            try await withCheckedThrowingContinuation { continuation in
                subject.updatePublisher(TestData.noteViewModel)
                    .sink(receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            continuation.resume(throwing: error)
                        }
                    }, receiveValue: { value in
                        continuation.resume(returning: value)
                    })
                    .store(in: &cancellables)
            }
            Issue.record("Update should throw")
        } catch let error as MockError {
            #expect(error == .generic)
        }
    }

    @Test("Test combine update does not throw when update notes succeeds",
          .tags(Tag.StorageServiceTestTag.combine, Tag.StorageServiceTestTag.update)
    )
    func combineUpdateDoesNotThrowWhenUpdateNotesSucceeds() async throws {
        mockCoreData.dataToReturnForFetchObject = TestData.noteStorageObject(withContext: context)
        mockCoreData.dataToReturnForFetchObjects = [TestData.noteStorageObject(withContext: context)]
        do {
            try await withCheckedThrowingContinuation { continuation in
                subject.updatePublisher(TestData.noteViewModel)
                    .sink(receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            continuation.resume(throwing: error)
                        }
                    }, receiveValue: { value in
                        continuation.resume(returning: value)
                    })
                    .store(in: &cancellables)
            }
        } catch {
            Issue.record("Update should not throw")
        }
    }

    @Test("Test combine delete throws when delete notes fails",
          .tags(Tag.StorageServiceTestTag.combine, Tag.StorageServiceTestTag.delete)
    )
    func combineDeleteThrowsWhenDeleteNotesFails() async throws {
        mockCoreData.errorToThrowForDelete = MockError.generic
        do {
            try await withCheckedThrowingContinuation { continuation in
                subject.deletePublisher([TestData.noteViewModel])
                    .sink(receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            continuation.resume(throwing: error)
                        }
                    }, receiveValue: { value in
                        continuation.resume(returning: value)
                    })
                    .store(in: &cancellables)
            }
            Issue.record("Delete should throw")
        } catch let error as MockError {
            #expect(error == .generic)
        }
    }

    @Test("Test combine delete throws when fetch notes fails",
          .tags(Tag.StorageServiceTestTag.combine, Tag.StorageServiceTestTag.delete)
    )
    func combineDeleteThrowsWhenFetchNotesFails() async throws {
        mockCoreData.errorToThrowForFetchObjectIDs = MockError.generic
        do {
            try await withCheckedThrowingContinuation { continuation in
                subject.deletePublisher([TestData.noteViewModel])
                    .sink(receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            continuation.resume(throwing: error)
                        }
                    }, receiveValue: { value in
                        continuation.resume(returning: value)
                    })
                    .store(in: &cancellables)
            }
            Issue.record("Delete should not throw")
        } catch let error as MockError {
            #expect(error == .generic)
        }
    }

    @Test("Test combine delete does not throw when delete notes succeeds",
          .tags(Tag.StorageServiceTestTag.combine, Tag.StorageServiceTestTag.delete)
    )
    func combineDeleteDoesNotThrowWhenDeleteSucceeds() async throws {
        do {
            try await withCheckedThrowingContinuation { continuation in
                subject.deletePublisher([TestData.noteViewModel])
                    .sink(receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            continuation.resume(throwing: error)
                        }
                    }, receiveValue: { value in
                        continuation.resume(returning: value)
                    })
                    .store(in: &cancellables)
            }
        } catch {
            Issue.record("Delete should not throw")
        }
    }

}

extension StorageServiceTests {
    struct TestData {
        // MARK: - Shared Data
        static func noteStorageObject(withContext context: NSManagedObjectContext) -> Note {
            let note = Note(context: context)
            note.id = noteViewModel.id
            note.title = noteViewModel.title
            note.body = noteViewModel.body
            note.createdAt = noteViewModel.createdAt
            note.updatedAt = noteViewModel.updatedAt
            return note
        }

        static let noteViewModel = NoteViewModel(id: UUID(), title: "Test Title", body: "Test Body")
    }
}
