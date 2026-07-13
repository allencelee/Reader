// This file is part of Kpapp for iOS.

import Foundation

protocol UserDefaulting {
    func bool(forKey defaultName: String) -> Bool
    func setValue(_ value: Any?, forKey key: String)
}
extension UserDefaults: UserDefaulting {}

struct Migration {
    let userDefaultsKey: String
    let migration: () -> Bool

    func migrate(_ userDefaults: UserDefaulting) -> Bool {
        guard userDefaults.bool(forKey: userDefaultsKey) != true else {
            // migration was done earlier
            return true
        }
        let result: Bool = migration()
        userDefaults.setValue(result, forKey: userDefaultsKey)
        return result
    }
}

struct MigrationService {
    let migrations: [Migration]

    init(migrations: [Migration] = Migrations.all) {
        self.migrations = migrations
    }

    func migrateAll(using userDefaults: UserDefaulting = UserDefaults.standard) -> Bool {
        var allSucceeded = true
        for migration in migrations where migration.migrate(userDefaults) == false {
            allSucceeded = false
        }
        return allSucceeded
    }
}
