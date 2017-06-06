//
//  AppDelegate.swift
//  SinceLast
//
//  Created by James Kuang on 5/8/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import UIKit

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
    lazy var window: UIWindow? = UIWindow(frame: UIScreen.main.bounds)
    lazy var coordinator: AppCoordinator = AppCoordinator()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window?.rootViewController = coordinator.startLaunchViewController()
        window?.makeKeyAndVisible()

        if let shortcutAction = launchOptions?[UIApplicationLaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem {
            return performAction(for: shortcutAction, completion: nil)
        }

        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return coordinator.handleOAuthURL(url)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        updateShortcuts()
    }

    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {

    }

    func performAction(for shortcutItem: UIApplicationShortcutItem, completion: ((Bool) -> Void)?) -> Bool {
        var success = false

        switch shortcutItem.type {
        case "SinceLastFavoriteRepositoryShortcutType":
            if let uuid = shortcutItem.userInfo?["uuid"] as? String {
                // TODO: do the stuff
                success = true
            }
        default:
            break
        }

        completion?(success)
        return false    // Always return false to application:didFinishLaunchingWithOptions:
    }

    func updateShortcuts() {
        let storage = PersistentStorage<FavoriteRepository>()
        let favorites = storage.load() ?? []
        let actionables = favorites[0..<min(4, favorites.count)]

        let icon = UIApplicationShortcutIcon(type: .favorite)
        let type = "SinceLastFavoriteRepositoryShortcutType"

        let shortcutItems = actionables.enumerated().map { (index, favorite) -> UIApplicationShortcutItem in
            let userInfo = ["uuid": favorite.uuid]
            return UIApplicationShortcutItem(type: type, localizedTitle: favorite.name, localizedSubtitle: favorite.ownerName, icon: icon, userInfo: userInfo)
        }

        UIApplication.shared.shortcutItems = shortcutItems.reversed()
    }
}
