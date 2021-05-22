//
//  SceneDelegate.swift
//  HomePodHub
//
//  Created by Jordan Osterberg on 5/12/21.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?
  
  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = scene as? UIWindowScene else {
      return
    }
    
    window = UIWindow(windowScene: windowScene)
    window?.rootViewController = SpringboardMimicViewController()
    window?.makeKeyAndVisible()
    
    #if targetEnvironment(macCatalyst)
    if let titlebar = window?.windowScene?.titlebar {
      titlebar.titleVisibility = .hidden
      titlebar.toolbar = nil
    }
    #endif
  }
}

