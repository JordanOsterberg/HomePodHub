//
//  YouTubeAppViewController.swift
//  YouTubeApp
//
//  Created by Jordan Osterberg on 5/16/21.
//

import UIKit
import AVKit

public class YouTubeAppViewController: UIViewController {
  private lazy var containerView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = .clear
    return view
  }()
  
  private lazy var videoTitleLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = UIFont.systemFont(ofSize: 22, weight: .light)
    label.text = "Never Gonna Rick You Up"
    label.textColor = .white
    return label
  }()
  
  private lazy var controlsView = PlayerControlsView(
    player: player,
    changePlayingStateTapped: {
      if self.player.rate != 0 {
        self.player.pause()
      } else {
        self.player.play()
      }
    },
    closeTapped: {
      self.dismiss(animated: true, completion: nil)
    }
  )
  
  private var playerLayer: AVPlayerLayer
  private var player: AVQueuePlayer
  
  private var looper: AVPlayerLooper?
  
  public override var prefersHomeIndicatorAutoHidden: Bool {
    return true
  }
  
  public override var prefersStatusBarHidden: Bool {
    return true
  }
  
  public init() {
    let rickRollVideoURL = Bundle.main.url(forResource: "rick", withExtension: "mp4")!
    let item = AVPlayerItem(url: rickRollVideoURL)
    player = AVQueuePlayer(playerItem: item)
    looper = AVPlayerLooper(player: player, templateItem: item)
    
    playerLayer = AVPlayerLayer(player: player)
    playerLayer.videoGravity = .resizeAspectFill
    
    super.init(nibName: nil, bundle: nil)
    modalPresentationStyle = .fullScreen
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override public func viewDidLoad() {
    view.backgroundColor = .black
    
    containerView.alpha = 0
    view.addSubview(containerView)
    
    containerView.layer.addSublayer(playerLayer)
    containerView.addSubview(controlsView)
    containerView.addSubview(videoTitleLabel)
    
    controlsView.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      containerView.topAnchor.constraint(equalTo: view.topAnchor),
      containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      
      controlsView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 30),
      controlsView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -30),
      controlsView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -40),
      controlsView.heightAnchor.constraint(equalToConstant: 50),
      
      videoTitleLabel.leadingAnchor.constraint(equalTo: controlsView.leadingAnchor),
      videoTitleLabel.trailingAnchor.constraint(equalTo: controlsView.trailingAnchor),
      videoTitleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20)
    ])
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    view.backgroundColor = .black
    player.play()
    
    UIView.animate(withDuration: 0.2) {
      self.containerView.alpha = 1
    }
  }
  
  public override func viewWillDisappear(_ animated: Bool) {
    view.backgroundColor = .clear
    player.pause()
    
    UIView.animate(withDuration: 0.3) {
      self.containerView.alpha = 0
    }
  }
  
  override public func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    playerLayer.frame = view.bounds
  }
}
