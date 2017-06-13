//
//  AppDelegate.swift
//  SinceLast
//
//  Created by James Kuang on 5/8/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
    lazy var window: UIWindow? = UIWindow(frame: UIScreen.main.bounds)
    lazy var coordinator: AppCoordinator = AppCoordinator()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        start3rdPartyApps()

        window?.rootViewController = coordinator.startLaunchViewController()
        window?.makeKeyAndVisible()

        if let shortcutItem = launchOptions?[UIApplicationLaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem {
            return coordinator.shortcutInteractor.performAction(for: shortcutItem, completion: nil)
        }

        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return coordinator.handleOAuthURL(url)
    }

    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        coordinator.shortcutInteractor.performAction(for: shortcutItem, completion: completionHandler)
    }

    func start3rdPartyApps() {
        Fabric.with([Crashlytics.self])
    }
}
