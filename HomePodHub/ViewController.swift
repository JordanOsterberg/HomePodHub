//
//  ViewController.swift
//  HomePodHub
//
//  Created by Jordan Osterberg on 5/12/21.
//

import UIKit
import AVKit

class ViewController: UIViewController {
  private var playerLayer: AVPlayerLayer?
  
  var player: AVPlayer
  
  init() {
    self.player = AVPlayer(
      playerItem: AVPlayerItem(
        url: Bundle.main.url(forResource: "Siri", withExtension: "mov")!
      )
    )
    
    super.init(nibName: nil, bundle: nil)
  }
  
  override var prefersHomeIndicatorAutoHidden: Bool {
    return true
  }
  
  override var prefersStatusBarHidden: Bool {
    return true
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .systemPurple
    
    let layer = AVPlayerLayer(player: player)
    layer.pixelBufferAttributes = [
      kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
    ]
    self.playerLayer = layer
    view.layer.addSublayer(layer)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    player.play()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    playerLayer?.frame = view.bounds
  }
}
