//
//  PhotoSlideshowViewController.swift
//  PhotoSlideshow
//
//  Created by Jordan Osterberg on 5/14/21.
//

import UIKit
import Photos

public class PhotoSlideshowViewController: UIViewController {
  private lazy var containerView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = .clear
    return view
  }()
  
  private lazy var imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()
  
  private lazy var noPermissionView: NoPermissionView = {
    let view = NoPermissionView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.alpha = 0
    return view
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
  
  private var index = 0 {
    didSet {
      updateImage()
    }
  }
  private var assetFetchResult: PHFetchResult<PHAsset>?
  
  public override var prefersStatusBarHidden: Bool {
    return true
  }
  
  public override var prefersHomeIndicatorAutoHidden: Bool {
    return true
  }
  
  public init() {
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override public func viewDidLoad() {
    view.backgroundColor = .clear
    
    containerView.alpha = 0
    view.addSubview(containerView)
    
    NSLayoutConstraint.activate([
      containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      containerView.topAnchor.constraint(equalTo: view.topAnchor),
      containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
    
    containerView.addSubview(imageView)
    containerView.addSubview(noPermissionView)
    containerView.addSubview(timeLabel)
    
    NSLayoutConstraint.activate([
      imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
      imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
      imageView.topAnchor.constraint(equalTo: containerView.topAnchor),
      imageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
      
      noPermissionView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
      noPermissionView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
      noPermissionView.topAnchor.constraint(equalTo: containerView.topAnchor),
      noPermissionView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
      
      timeLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
      timeLabel.topAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.topAnchor, constant: 20),
    ])
    
    if PHPhotoLibrary.authorizationStatus() == .notDetermined {
      PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
        self.handle(authorizationStatus: status)
      }
    } else {
      self.handle(authorizationStatus: PHPhotoLibrary.authorizationStatus())
    }
    
    startMinuteTimer()
    updateTimeLabel()
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
  
  private func handle(authorizationStatus: PHAuthorizationStatus) {
    DispatchQueue.main.async {
      if authorizationStatus == .authorized {
        self.loadSlideshow()
        if self.noPermissionView.alpha == 0 { return }
        
        UIView.animate(withDuration: 0.4) {
          self.noPermissionView.alpha = 0
        }
        
        return
      }
      
      if self.noPermissionView.alpha == 1 { return }
      UIView.animate(withDuration: 0.4) {
        self.noPermissionView.alpha = 1
      }
    }
  }
  
  private func loadSlideshow() {
    let result = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: PHFetchOptions())
    result.enumerateObjects { album, index, _ in
      if album.localizedTitle == "HomePod Hub" {
        self.assetFetchResult = PHAsset.fetchAssets(in: album, options: nil)
        self.index = 0
      }
    }
    
    if assetFetchResult != nil { return }
    
    if result.firstObject == nil {
      print("Failed to load an album for the slideshow")
      return
    }
    
    assetFetchResult = PHAsset.fetchAssets(in: result.firstObject!, options: nil)
    index = 0
  }
  
  private func updateImage() {
    if assetFetchResult == nil { return }
    
    if index >= assetFetchResult?.count ?? 0 {
      index = 0
      return
    }
    
    guard let asset = assetFetchResult?.object(at: index) else {
      return
    }
    
    let manager = PHImageManager.default()
    let options = PHImageRequestOptions()
    options.version = .current
    options.isSynchronous = false
    options.isNetworkAccessAllowed = true
    
    manager.requestImage(for: asset, targetSize: CGSize(width: view.frame.width, height: view.frame.height), contentMode: .aspectFill, options: options) { image, info in
      let isDegraded = info?[PHImageResultIsDegradedKey] as? Bool
      if isDegraded ?? false { return }
      
      DispatchQueue.main.async {
        UIView.transition(with: self.imageView, duration: 0.4, options: .transitionCrossDissolve) {
          self.imageView.image = image
        }
        
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false, block: { _ in
          self.index += 1
        })
      }
    }
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    containerView.backgroundColor = .black
    
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
  
  override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    dismiss(animated: true, completion: nil)
  }
}
