// This file is part of Kpapp for iOS.

protocol Parser {
    var zimFileIDs: Set<UUID> { get }
    @ZimActor
    func parse(data: Data, urlHost: String) throws
    func getMetaData(id: UUID) -> ZimFileMetaData?
}

extension OPDSParser: Parser {
    var zimFileIDs: Set<UUID> {
        __getZimFileIDs() as? Set<UUID> ?? Set<UUID>()
    }

    @ZimActor
    func parse(data: Data, urlHost: String) throws {
        if !self.__parseData(data, using: urlHost.removingSuffix("/")) {
            throw LibraryRefreshError.parse
        }
    }

    func getMetaData(id: UUID) -> ZimFileMetaData? {
        return __getZimFileMetaData(id)
    }
}

/// An empty Parser we can use to delete zim entries
/// Based on the assumption we insert new ones, delete the ones not on the list
/// Therefore an empty list will delete everything, using the same method
/// @see: LibraryViewModel.process(parser: Parser)
struct DeletingParser: Parser {
    let zimFileIDs: Set<UUID> = .init()

    func parse(data: Data, urlHost: String) throws {
    }

    func getMetaData(id: UUID) -> ZimFileMetaData? {
        nil
    }
}
