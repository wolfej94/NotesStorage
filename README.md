### NotesStorage

This package provides a streamlined way to manage Core Data interactions for a notes application. Designed as part of a Swift showcase project, it encapsulates Core Data operations in a clean, modern API, supporting various interaction styles including asynchronous, closure-based, and Combine-based approaches.

---

## Features

- **Asynchronous Operations**: Leverage Swift's `async/await` syntax for modern, clean, and scalable code.
- **Combine Support**: Use Combine publishers to reactively manage Core Data operations.
- **Completion Handlers**: Optionally use closure-based APIs for compatibility with older codebases.
- **Type Safety**: Ensure consistent and type-safe interaction with your data layer.

---

## Installation

This package is distributed as a Swift Package Manager (SPM) package. To include it in your project:

1. In Xcode, go to **File > Add Packages...**.
2. Enter the repository URL of this package.
3. Choose the version or branch you want to use.
4. Add the package to your target.

---

## Usage

### Importing the Package

```swift
import NotesStorage
```

### StorageService

The `StorageService` class conforms to the `StorageServiceProtocol` protocol and provides the following public methods:

#### Asynchronous Methods

```swift
func create(_ note: NoteViewModel) async throws
func read() throws -> [NoteViewModel]
func update(_ note: NoteViewModel) async throws
func delete(_ notes: [NoteViewModel]) async throws
```

Example:

```swift
let storageService: StorageServiceProtocol = StorageService()

let newNote = NoteViewModel(id: UUID(), title: "New Note", body: "This is a test note.", createdAt: Date(), updatedAt: Date())

do {
    try await storageService.create(newNote)
    let notes = try storageService.read()
    print("Notes: \(notes)")
} catch {
    print("An error occurred: \(error)")
}
```

---

#### Closure-Based Methods

```swift
func create(_ note: NoteViewModel, completion: @escaping (Result<Void, any Error>) -> Void)
func update(_ note: NoteViewModel, completion: @escaping (Result<Void, any Error>) -> Void)
func delete(_ notes: [NoteViewModel], completion: @escaping (Result<Void, any Error>) -> Void)
```

Example:

```swift
storageService.create(newNote) { result in
    switch result {
    case .success:
        print("Note created successfully.")
    case .failure(let error):
        print("Failed to create note: \(error)")
    }
}
```

---

#### Combine-Based Methods

```swift
func createPublisher(_ note: NoteViewModel) -> AnyPublisher<Void, any Error>
func updatePublisher(_ note: NoteViewModel) -> AnyPublisher<Void, any Error>
func deletePublisher(_ notes: [NoteViewModel]) -> AnyPublisher<Void, any Error>
```

Example:

```swift
let cancellable = storageService.createPublisher(newNote)
    .sink(receiveCompletion: { completion in
        switch completion {
        case .finished:
            print("Note created successfully.")
        case .failure(let error):
            print("Failed to create note: \(error)")
        }
    }, receiveValue: {
        print("Create operation completed.")
    })
```

---

## License

This package is open source and available under the [MIT License](LICENSE).

---

For any questions or contributions, feel free to open an issue or submit a pull request.


