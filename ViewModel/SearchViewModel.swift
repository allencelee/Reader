// This file is part of Kpapp for iOS.

import Combine
import CoreData


final class SearchViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
    @Published var searchText: String = ""  // text in the search field
    @Published private(set) var zimFiles: [UUID: ZimFile]  // ID of zim files that are included in search
    @Published private(set) var inProgress = false
    @Published private(set) var results = [SearchResult]()
    
    static let shared = SearchViewModel()

    private let fetchedResultsController: NSFetchedResultsController<ZimFile>
    private var searchSubscriber: AnyCancellable?
    @ZimActor
    private let queue = OperationQueue()

    override private init() {
        // initialize fetched results controller
        let predicate = NSPredicate(
            format: "includedInSearch == true AND fileURLBookmark != nil"
        )
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: ZimFile.fetchRequest(predicate: predicate),
            managedObjectContext: Database.shared.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )

        // initialize zim file IDs
        try? fetchedResultsController.performFetch()
        zimFiles = fetchedResultsController.fetchedObjects?.reduce(into: [:]) { result, zimFile in
            result?[zimFile.fileID] = zimFile
        } ?? [:]

        super.init()

        // additional configurations
        queue.maxConcurrentOperationCount = 1
        fetchedResultsController.delegate = self

        // subscribers
        searchSubscriber = Publishers.CombineLatest(
            $searchText.removeDuplicates { prev, current in
                // consider search text to be the same ignoring spaces
                prev.trimmingCharacters(in: .whitespaces) == current.trimmingCharacters(in: .whitespaces)
            }, $zimFiles.removeDuplicates { prev, current in
                // don't re-trigger for the same set of zim files
                Set(prev.keys) == Set(current.keys)
            })
            .map { [unowned self] searchText, zimFiles in
                if !searchText.isEmpty, !zimFiles.isEmpty {
                    self.updateProgress(true)
                }
                return (searchText, zimFiles)
            }
            .debounce(for: 0.2, scheduler: DispatchQueue.main)
            .sink { [unowned self] searchText, zimFiles in
                Task { @ZimActor [weak self] in
                    self?.updateSearchResults(searchText, Set(zimFiles.keys))
                }
            }
    }
    
    deinit {
        queue.cancelAllOperations()
        searchSubscriber?.cancel()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        zimFiles = fetchedResultsController.fetchedObjects?.reduce(into: [:]) { result, zimFile in
            result?[zimFile.fileID] = zimFile
        } ?? [:]
    }
    
    private func updateProgress(_ value: Bool) {
        // don't publish duplicate values
        if value != inProgress {
            inProgress = value
        }
    }

    @ZimActor
    private func updateSearchResults(_ searchText: String, _ zimFileIDs: Set<UUID>) {
        queue.cancelAllOperations()
        // This is run at app start, and opens the archive of all searchable ZIM files
        for zimFileID in zimFileIDs {
            _ = ZimFileService.shared.openArchive(zimFileID: zimFileID)
        }
        let operation = SearchOperation(searchText: searchText, zimFileIDs: zimFileIDs)
        operation.extractMatchingSnippet = Defaults[.searchResultSnippetMode] == .matches
        operation.completionBlock = { [weak self] in
            guard !operation.isCancelled else { return }
            Task { @MainActor [weak self] in
                self?.results = operation.results
                self?.updateProgress(false)
            }
        }
        queue.addOperation(operation)
    }
}
