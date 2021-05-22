//
//  PlayerControlsView.swift
//  YouTubeApp
//
//  Created by Jordan Osterberg on 5/16/21.
//

import UIKit
import AVKit

class PlayerControlsView: UIView {
  private weak var player: AVPlayer?
  
  private let symbolConfig = UIImage.SymbolConfiguration(pointSize: 32)
  
  private lazy var changePlayingStateButton: UIButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setImage(UIImage(systemName: "pause", withConfiguration: symbolConfig), for: .normal)
    button.tintColor = .white
    return button
  }()
  
  private lazy var progressView: UIProgressView = {
    let progressView = UIProgressView()
    progressView.translatesAutoresizingMaskIntoConstraints = false
    progressView.progressTintColor = UIColor(red: 254/255, green: 0, blue: 0, alpha: 1)
    progressView.trackTintColor = UIColor(red: 171/255, green: 176/255, blue: 169/255, alpha: 1)
    return progressView
  }()
  
  private lazy var exitButton: UIButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setImage(UIImage(systemName: "arrow.down.right.and.arrow.up.left", withConfiguration: symbolConfig), for: .normal)
    button.tintColor = .white
    return button
  }()
  
  private var progressTimer: Timer?
  private var changePlayingStateTapped: (() -> Void)
  private var closeTapped: (() -> Void)
  
  init(player: AVPlayer?, changePlayingStateTapped: @escaping (() -> Void), closeTapped: @escaping (() -> Void)) {
    self.player = player
    self.changePlayingStateTapped = changePlayingStateTapped
    self.closeTapped = closeTapped
    
    super.init(frame: .zero)
    
    changePlayingStateButton.addAction(UIAction(handler: { [weak self] _ in
      let newSymbolName: String
      if player?.rate == 0 {
        newSymbolName = "pause"
      } else {
        newSymbolName = "play.fill"
      }
      
      self?.changePlayingStateButton.setImage(UIImage(systemName: newSymbolName, withConfiguration: self?.symbolConfig), for: .normal)
      
      self?.updateProgress()
      self?.changePlayingStateTapped()
    }), for: .touchUpInside)
    
    exitButton.addAction(UIAction(handler: { [weak self] _ in
      self?.closeTapped()
    }), for: .touchUpInside)
    
    setupViewLayout()
    
    let progressTimer = Timer(
      timeInterval: 0.5,
      repeats: true
    ) { [weak self] _ in
      self?.updateProgress()
    }
    self.progressTimer = progressTimer
    
    RunLoop.main.add(progressTimer, forMode: .default)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  deinit {
    self.progressTimer?.invalidate()
    self.progressTimer = nil
  }
  
  private func updateProgress() {
    guard let player = player, let item = player.currentItem else {
      return
    }
    
    let progress = CMTimeGetSeconds(player.currentTime()) / CMTimeGetSeconds(item.duration)
    
    self.progressView.progress = Float(progress)
  }
  
  private func setupViewLayout() {
    addSubview(changePlayingStateButton)
    addSubview(progressView)
    addSubview(exitButton)
    
    NSLayoutConstraint.activate([
      changePlayingStateButton.leadingAnchor.constraint(equalTo: leadingAnchor),
      changePlayingStateButton.centerYAnchor.constraint(equalTo: progressView.centerYAnchor),
      changePlayingStateButton.heightAnchor.constraint(equalToConstant: 50),
      changePlayingStateButton.widthAnchor.constraint(equalToConstant: 50),
      
      progressView.heightAnchor.constraint(equalToConstant: 4),
      progressView.leadingAnchor.constraint(equalTo: changePlayingStateButton.trailingAnchor, constant: 15),
      progressView.trailingAnchor.constraint(equalTo: exitButton.leadingAnchor, constant: -15),
      progressView.bottomAnchor.constraint(equalTo: bottomAnchor),
      
      exitButton.trailingAnchor.constraint(equalTo: trailingAnchor),
      exitButton.centerYAnchor.constraint(equalTo: progressView.centerYAnchor),
      exitButton.heightAnchor.constraint(equalToConstant: 50),
      exitButton.widthAnchor.constraint(equalToConstant: 50),
    ])
  }
}


