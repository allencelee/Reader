// This file is part of Kpapp for iOS.

import Foundation
import Combine

@MainActor
final class DownloadTasksPublisher {

    let publisher: CurrentValueSubject<[UUID: DownloadState], Never>
    private var states = [UUID: DownloadState]()

    init() {
        publisher = CurrentValueSubject(states)
        if let jsonData = UserDefaults.standard.object(forKey: "downloadStates") as? Data,
           let storedStates = try? JSONDecoder().decode([UUID: DownloadState].self, from: jsonData) {
            states = storedStates
            publisher.send(states)
        }
    }

    func updateFor(uuid: UUID, downloaded: Int64, total: Int64) {
        if let state = states[uuid] {
            states[uuid] = state.updatedWith(downloaded: downloaded, total: total)
        } else {
            states[uuid] = DownloadState(downloaded: downloaded, total: total, resumeData: nil)
        }
        publisher.send(states)
        saveState()
    }

    func resetFor(uuid: UUID) {
        states.removeValue(forKey: uuid)
        publisher.send(states)
        saveState()
    }

    func isEmpty() -> Bool {
        states.isEmpty
    }

    func resumeDataFor(uuid: UUID) -> Data? {
        states[uuid]?.resumeData
    }

    func updateFor(uuid: UUID, withResumeData resumeData: Data?) {
        if let state = states[uuid] {
            states[uuid] = state.updatedWith(resumeData: resumeData)
            publisher.send(states)
            saveState()
        } else {
            assertionFailure("there should be a download task for: \(uuid)")
        }
    }
    
    private func saveState() {
        if let jsonStates = try? JSONEncoder().encode(states) {
            UserDefaults.standard.setValue(jsonStates, forKey: "downloadStates")
        }
    }
}
