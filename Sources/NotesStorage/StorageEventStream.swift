//
//  StorageEventStream.swift
//  NotesStorage
//
//  Created by James Wolfe on 28/02/2025.
//

import Foundation

internal protocol StorageEventStream: Sendable {
    func sendNoteUpdate(_ note: NoteViewModel) async
    func noteStream() async -> AsyncStream<Task<NoteViewModel, Never>>
}

internal actor DefaultStorageEventStream: StorageEventStream {
    
    private var continuation: AsyncStream<Task<NoteViewModel, Never>>.Continuation?
    lazy var _noteStream: AsyncStream<Task<NoteViewModel, Never>> = {
        return AsyncStream { continuation in
            self.continuation = continuation
        }
    }()
    
    func noteStream() -> AsyncStream<Task<NoteViewModel, Never>> {
        return _noteStream
    }
    
    func sendNoteUpdate(_ note: NoteViewModel) {
        let task = Task {
            return note
        }
        continuation?.yield(task)
    }
}
