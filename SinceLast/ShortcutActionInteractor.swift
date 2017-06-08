//
//  ShortcutActionInteractor.swift
//  SinceLast
//
//  Created by James Kuang on 6/6/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import UIKit

final class ShortcutActionInteractor {
    enum ShortcutType {
        static let favoriteRepository = "favoriteRepositoryShortcutType"
    }

    weak var coordinator: AppCoordinator?

    init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
    }

    func setupShortcutsCreation() {
        NotificationCenter.default.addObserver(forName: .persistentStorageContentDidChange, object: nil, queue: OperationQueue(), using: { notification in
            let storage = PersistentStorage<FavoriteRepository>()
            let favorites = storage.load() ?? []
            let actionables = favorites[0..<min(4, favorites.count)]

            let icon = UIApplicationShortcutIcon(type: .favorite)
            let type = ShortcutType.favoriteRepository

            let shortcutItems = actionables.map { actionable -> UIApplicationShortcutItem in
                let userInfo = ["uuid": actionable.uuid]
                return UIApplicationShortcutItem(type: type, localizedTitle: actionable.name, localizedSubtitle: actionable.ownerName, icon: icon, userInfo: userInfo)
            }

            UIApplication.shared.shortcutItems = shortcutItems
        })
    }

    @discardableResult
    func performAction(for shortcutItem: UIApplicationShortcutItem, completion: ((Bool) -> Void)?) -> Bool {
        let returnValue = false // Always return false to application:didFinishLaunchingWithOptions:
        guard shortcutItem.type == ShortcutType.favoriteRepository,
            let uuid = shortcutItem.userInfo?["uuid"] as? String else {
                completion?(false)
                return returnValue
        }

        let storage = PersistentStorage<FavoriteRepository>()
        let favorites = storage.load() ?? []
        guard let favorite = favorites.first(where: { $0.uuid == uuid }) else {
            completion?(false)
            return returnValue
        }

        coordinator?.startLaunchViewController()
        coordinator?.router.routeToCommits(in: favorite)

        completion?(true)
        return returnValue
    }
}
