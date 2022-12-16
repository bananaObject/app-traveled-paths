//
//  AppDelegate.swift
//  googleMap
//
//  Created by Ke4a on 03.12.2022.
//

import GoogleMaps
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var appCoordinator: ApplicationCoordinator?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        GMSServices.setMetalRendererEnabled(true)
        GMSServices.provideAPIKey("AIzaSyBhgT3hAs_nddjnk8Fubv9ZyH2l0DfK5ng")
        window = UIWindow(frame: UIScreen.main.bounds)
        self.appCoordinator = ApplicationCoordinator(window: window)
        self.appCoordinator?.start()
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        requestPermission(center)
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        showPrivacyProtectionView()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        hidePrivacyProtectionView()
    }

    private var privacyProtectionView: UIView?

    /// Adds blur to the root screen.
    private func showPrivacyProtectionView() {
        guard let frame = window?.rootViewController?.view.frame else { return }
        let view = PrivacyView(frame: frame)
        window?.rootViewController?.view.addSubview(view)
        privacyProtectionView = view
    }

    /// Removes blur from the root screen.
    private func hidePrivacyProtectionView() {
        privacyProtectionView?.removeFromSuperview()
        privacyProtectionView = nil
    }

    private func requestPermission(_ center: UNUserNotificationCenter) {
        center.requestAuthorization( options: [.alert, .sound]) { [weak self] succes, error in
            guard let self = self, succes else {
                print("User has banned push notifications")
                return
            }
            let content = self.createContent()
            let trigger = self.createTrigger()

            self.sendNotificationRequest(content: content, trigger: trigger)
        }
    }

    func sendNotificationRequest(content: UNNotificationContent, trigger: UNNotificationTrigger) {
        let request = UNNotificationRequest(identifier: "timeNotification", content: content, trigger: trigger)

        let center = UNUserNotificationCenter.current()
        center.add(request) { error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }

    func createContent() -> UNNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "Time for a walk"
        content.body = "Start the application ?"

        return content
    }

    func createTrigger() -> UNNotificationTrigger {
        UNTimeIntervalNotificationTrigger(timeInterval: 600, repeats: false)
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        print(response)
    }
}
