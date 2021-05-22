//
//  AerialScreensaverViewController.swift
//  HomePodHub
//
//  Created by Jordan Osterberg on 5/13/21.
//

import UIKit
import AVKit

public class AerialScreensaverViewController: UIViewController {
  private lazy var containerView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = .clear
    return view
  }()
  
  private lazy var captionLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
    label.numberOfLines = 0
    label.textColor = .white
    return label
  }()
  
  private lazy var timeLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    
    let size: CGFloat = 90
    var font = UIFont.systemFont(ofSize: size, weight: .semibold)
    let descriptor = font.fontDescriptor.withDesign(.rounded)!
    font = UIFont(descriptor: descriptor, size: size)
    
    label.font = font
    label.numberOfLines = 0
    label.textColor = .white
    label.textAlignment = .right
    
    label.layer.shadowColor = UIColor.black.cgColor
    label.layer.shadowOpacity = 0.5
    label.layer.shadowOffset = CGSize(width: 2, height: 2)
    label.layer.shadowRadius = 10
    return label
  }()
  
  private lazy var changeVideoButton: UIButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.layer.cornerRadius = 60/2
    button.clipsToBounds = true
    button.setImage(UIImage(systemName: "forward.fill"), for: .normal)
    button.backgroundColor = .white.withAlphaComponent(0.5)
    button.tintColor = .black
    return button
  }()
  
  public override var prefersHomeIndicatorAutoHidden: Bool {
    return true
  }
  
  public override var prefersStatusBarHidden: Bool {
    return true
  }
  
  private var playerLayer: AVPlayerLayer?
  
  var player: AVQueuePlayer?
  var looper: AVPlayerLooper?
  
  let dayVideo: AerialVideo
  let nightVideo: AerialVideo
  
  var activeVideo: AerialVideo? {
    didSet {
      guard let video = activeVideo else {
        return
      }
      
      self.player?.replaceCurrentItem(with: AVPlayerItem(url: video.url))
    }
  }
  
  public init() {
    dayVideo = AerialVideo.load("SFDay")!
    nightVideo = AerialVideo.load("SFNight")!
    
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .black
    
    containerView.alpha = 0
    view.addSubview(containerView)
    
    NSLayoutConstraint.activate([
      containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      containerView.topAnchor.constraint(equalTo: view.topAnchor),
      containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
    
    self.activeVideo = [dayVideo, nightVideo].randomElement()
    
    let item = AVPlayerItem(
      url: activeVideo?.url ?? URL(string: "https://youtube.com")!
    )
    self.player = AVQueuePlayer(
      playerItem: item
    )
    
    self.looper = AVPlayerLooper(player: player!, templateItem: item)
    
    let layer = AVPlayerLayer(player: player)
    layer.videoGravity = .resizeAspectFill
    self.playerLayer = layer
    containerView.layer.addSublayer(layer)
    
    containerView.addSubview(timeLabel)
    containerView.addSubview(captionLabel)
    containerView.addSubview(changeVideoButton)
    
    NSLayoutConstraint.activate([
      timeLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
      timeLabel.topAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.topAnchor, constant: 20),
      
      captionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
      captionLabel.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor, constant: -20),
      captionLabel.widthAnchor.constraint(lessThanOrEqualTo: containerView.widthAnchor, multiplier: 1/3),
      
      changeVideoButton.heightAnchor.constraint(equalToConstant: 60),
      changeVideoButton.widthAnchor.constraint(equalToConstant: 60),
      changeVideoButton.trailingAnchor.constraint(equalTo: timeLabel.trailingAnchor),
      changeVideoButton.bottomAnchor.constraint(equalTo: captionLabel.bottomAnchor)
    ])
    
    changeVideoButton.addAction(UIAction(handler: { _ in
      self.switchVideo()
    }), for: .touchUpInside)
    
    var timeUpdateLocked = false
    player?.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1/30.0, preferredTimescale: Int32(NSEC_PER_SEC)), queue: nil, using: { time in
      let secondsLeft = Int(CMTimeGetSeconds(time))
      
      guard let currentCaption = (self.activeVideo?.timings ?? []).first(where: { timing in
        return timing.time == secondsLeft
      }) else {
        return
      }
      
      if self.captionLabel.text == currentCaption.caption { return } // no change
      if self.captionLabel.text == nil || secondsLeft == 0 {
        self.captionLabel.text = currentCaption.caption
        return
      }
      if timeUpdateLocked { return }
      
      DispatchQueue.main.async {
        timeUpdateLocked = true
        UIView.animate(withDuration: 0.8) {
          self.captionLabel.alpha = 0
        } completion: { _ in
          self.captionLabel.text = currentCaption.caption
          
          UIView.animate(withDuration: 0.8, delay: 0.2) {
            self.captionLabel.alpha = 1
          } completion: { _ in
            timeUpdateLocked = false
          }
        }
      }
    })
    
    updateTimeLabel()
    startMinuteTimer()
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    view.backgroundColor = .black
    player?.play()
    
    UIView.animate(withDuration: 0.2) {
      self.containerView.alpha = 1
    }
  }
  
  public override func viewWillDisappear(_ animated: Bool) {
    view.backgroundColor = .clear
    UIView.animate(withDuration: 0.3) {
      self.containerView.alpha = 0
    }
  }
  
  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    playerLayer?.frame = view.bounds
  }
  
  var timer: Timer?

  func startMinuteTimer() {
    let now = Date.timeIntervalSinceReferenceDate
    let delayFraction = trunc(now) - now
    
    // Caluclate a delay until the next even minute
    let delay = 60.0 - Double(Int(now) % 60) + delayFraction
    
    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
      self.updateTimeLabel()
      
      self.timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) {
        timer in
        self.updateTimeLabel()
      }
    }
  }
  
  func updateTimeLabel() {
    let formatter = DateFormatter()
    formatter.dateFormat = "h:mm a"
    timeLabel.text = formatter.string(from: Date())
  }
  
  func switchVideo() {
    let duration = 0.5
    
    UIView.animate(withDuration: duration) {
      self.containerView.alpha = 0
    } completion: { _ in
      if self.activeVideo == self.dayVideo {
        self.activeVideo = self.nightVideo
      } else {
        self.activeVideo = self.dayVideo
      }
      
      UIView.animate(withDuration: duration, delay: 0.2) {
        self.containerView.alpha = 1
      }
    }
  }
  
  private func fadeAnimation(from: Int, to: Int, duration: CFTimeInterval) -> CABasicAnimation {
    let animation = CABasicAnimation(keyPath: "opacity")
    animation.fromValue = from
    animation.toValue = to
    animation.duration = duration
    animation.isRemovedOnCompletion = true
    return animation
  }
  
  public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    dismiss(animated: true, completion: nil)
  }
}

