// This file is part of Kpapp for iOS.

import SwiftUI

@MainActor
final class MultiSelectedZimFilesViewModel: ObservableObject {
    @Published private(set) var selectedZimFiles = Set<ZimFile>()
    
    func toggleMultiSelect(of zimFile: ZimFile) {
        guard FeatureFlags.hasLibrary else { return }
        if selectedZimFiles.contains(zimFile) {
            selectedZimFiles.remove(zimFile)
        } else {
            selectedZimFiles.insert(zimFile)
        }
    }
    
    func singleSelect(zimFile: ZimFile) {
        selectedZimFiles = Set([zimFile])
    }
    
    func reset() {
        selectedZimFiles.removeAll()
    }
    
    func isSelected(_ zimFile: ZimFile) -> Bool {
        guard FeatureFlags.hasLibrary else { return true }
        return selectedZimFiles.contains(zimFile)
    }
    
    func intersection(with zimFiles: Set<ZimFile>) {
        selectedZimFiles = selectedZimFiles.intersection(zimFiles)
    }
}

@MainActor
final class SelectedZimFileViewModel: ObservableObject {
    @Published var selectedZimFile: ZimFile?
    
    func reset() {
        selectedZimFile = nil
    }
    
    func isSelected(_ zimFile: ZimFile) -> Bool {
        selectedZimFile == zimFile
    }
}
