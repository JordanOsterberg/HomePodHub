//
//  SpringboardMimicViewController.swift
//  HomePodHub
//
//  Created by Jordan Osterberg on 5/13/21.
//

import UIKit
import MediaPlayer
import Combine

import AerialApp
import PhotoSlideshow
import HomeApp
import YouTubeApp
import BookmarksApp

class SpringboardMimicViewController: UIViewController {
  private lazy var backgroundImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .scaleAspectFill
    imageView.image = UIImage(named: "SpringboardBG")
    return imageView
  }()
  
  private lazy var visualEffectView: UIVisualEffectView = {
    let view = UIVisualEffectView(effect: blurEffect)
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  private lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewLayout())
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    collectionView.backgroundColor = .clear
    return collectionView
  }()
  
  private var blurEffect: UIBlurEffect {
    UIBlurEffect(style: traitCollection.userInterfaceStyle == .dark ? .dark : .light)
  }
  
  struct App: Hashable {
    var name: String
    var iconName: String
    var onTap: (UICollectionViewCell) -> Void
    
    func hash(into hasher: inout Hasher) {
      hasher.combine(name)
    }
    
    static func ==(rhs: App, lhs: App) -> Bool {
      return rhs.name == lhs.name
    }
  }
  
  enum Item: Hashable {
    case time
    case app(App)
  }
  
  enum Section: Hashable {
    case time
    case widgets
    case apps
  }
  
  typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
  typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
  
  lazy var dataSource = makeDataSource()
  
  @Published private var status: SpringboardStatus?
  @Published private var currentDateTime: Date? = Date()
  
  let transition = SpringboardAppLaunchAnimator()
  
  override var prefersStatusBarHidden: Bool {
    return true
  }
  
  override var prefersHomeIndicatorAutoHidden: Bool {
    return true
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .white
    
    view.addSubview(backgroundImageView)
    view.addSubview(visualEffectView)
    view.addSubview(collectionView)
    
    NSLayoutConstraint.activate([
      backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
      backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      backgroundImageView.heightAnchor.constraint(equalTo: view.heightAnchor),
      backgroundImageView.widthAnchor.constraint(equalTo: view.widthAnchor),
      
      visualEffectView.topAnchor.constraint(equalTo: view.topAnchor),
      visualEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      visualEffectView.heightAnchor.constraint(equalTo: view.heightAnchor),
      visualEffectView.widthAnchor.constraint(equalTo: view.widthAnchor),
      
      collectionView.topAnchor.constraint(equalTo: view.topAnchor),
      collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      collectionView.heightAnchor.constraint(equalTo: view.heightAnchor),
      collectionView.widthAnchor.constraint(equalTo: view.widthAnchor)
    ])
    
    collectionView.delegate = self
    
    configureWidgetLayout()
    applySnapshot(animateDifferences: false)
    
    MPMusicPlayerController.systemMusicPlayer.beginGeneratingPlaybackNotifications()
    NotificationCenter.default.addObserver(self, selector: #selector(nowPlayingDidChange), name: NSNotification.Name.MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(nowPlayingDidChange), name: NSNotification.Name.MPMusicPlayerControllerPlaybackStateDidChange, object: nil)
    
    startMinuteTimer()
    nowPlayingDidChange()
    
    Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: { _ in
      self.nowPlayingDidChange() // force update every 10 seconds, for some reason notifications don't come in when expected
    })
  }
  
  override func viewWillAppear(_ animated: Bool) {
    MPMediaLibrary.requestAuthorization { _ in
      DispatchQueue.main.async {
        self.nukeSnapshot()
      }
    }
  }
  
  var timer: Timer?

  func startMinuteTimer() {
    let now = Date.timeIntervalSinceReferenceDate
    let delayFraction = trunc(now) - now
    
    // Caluclate a delay until the next even minute
    let delay = 60.0 - Double(Int(now) % 60) + delayFraction
    
    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
      self.currentDateTime = Date()
      self.nowPlayingDidChange()
      
      self.timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) {
        timer in
        self.currentDateTime = Date()
        self.nowPlayingDidChange()
      }
    }
  }
  
  @objc public func nowPlayingDidChange() {
    let systemPlayer = MPMusicPlayerController.systemMusicPlayer
    
    guard let currentItem = systemPlayer.nowPlayingItem else {
      status = nil
      return
    }
    
    if systemPlayer.playbackState == .paused {
      status = nil
      return
    }
    
    let albumArt = currentItem.artwork?.image(at: CGSize(width: 200, height: 200))
    
    status = SpringboardStatus(
      image: albumArt,
      title: currentItem.title,
      subtitle: currentItem.artist
    )
  }
  
  func presentController(_ controller: UIViewController, from cell: UICollectionViewCell) {
    guard let superView = cell.superview else {
      return
    }
    
    self.transition.originFrame = superView.convert(cell.frame, to: nil)
    self.transition.originFrame = CGRect(
      x: self.transition.originFrame.origin.x + 20,
      y: self.transition.originFrame.origin.y + 20,
      width: self.transition.originFrame.size.width - 40,
      height: self.transition.originFrame.size.height - 40
    )

    self.transition.presenting = true
    
    controller.transitioningDelegate = self
    controller.modalPresentationStyle = .fullScreen
    controller.modalTransitionStyle = .crossDissolve
    self.present(controller, animated: true, completion: nil)
  }
  
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    if previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle {
      visualEffectView.effect = blurEffect
    }
  }
}

extension SpringboardMimicViewController {
  private func makeDataSource() -> DataSource {
    collectionView.register(SpringboardAppIconCell.self, forCellWithReuseIdentifier: SpringboardAppIconCell.reuseIdentifier)
    collectionView.register(SpringboardStatusCell.self, forCellWithReuseIdentifier: SpringboardStatusCell.reuseIdentifier)
    
    return DataSource(collectionView: collectionView) { collectionView, indexPath, item in
      switch item {
      case let .app(app):
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SpringboardAppIconCell.reuseIdentifier, for: indexPath) as? SpringboardAppIconCell
        cell?.app = app
        return cell
      case .time:
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SpringboardStatusCell.reuseIdentifier, for: indexPath) as? SpringboardStatusCell
        cell?.date = self.currentDateTime
        cell?.datePublisher = self.$currentDateTime
        
        cell?.status = self.status
        cell?.statusPublisher = self.$status
        return cell
      }
    }
  }
  
  private func applySnapshot(animateDifferences: Bool = true) {
    var snapshot = Snapshot()
    snapshot.appendSections([.time, .apps])
    
    snapshot.appendItems([.time], toSection: .time)
    
    let apps = [
      App(name: "Aerial", iconName: "Aerial", onTap: { cell in
        self.presentController(AerialScreensaverViewController(), from: cell)
      }),
      App(name: "Photos", iconName: "Photos", onTap: { cell in
        self.presentController(PhotoSlideshowViewController(), from: cell)
      }),
      App(name: "Home", iconName: "Home", onTap: { cell in
        self.presentController(HomeAppViewController(), from: cell)
      }),
      App(name: "Weather", iconName: "Weather", onTap: { cell in
        
      }),
      App(name: "Bookmarks", iconName: "Bookmarks", onTap: { cell in
        self.presentController(BookmarksAppViewController(), from: cell)
      }),
      App(name: "Music", iconName: "Music", onTap: { cell in
        let alert = UIAlertController(title: "Unavailable", message: "Use some imagination- This would display the lyric view, along with Cover Flow from back in the day :]", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
      }),
      App(name: "FaceTime", iconName: "FaceTime", onTap: { cell in
        let alert = UIAlertController(title: "Unavailable", message: "Use some movie magic or your imagination :]", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
      }),
      App(name: "YouTube", iconName: "YouTube", onTap: { cell in
        self.presentController(YouTubeAppViewController(), from: cell)
      }),
      App(name: "Recipes", iconName: "Recipes", onTap: { cell in
        
      }),
      App(name: "Countdown", iconName: "Countdown", onTap: { cell in
        
      }),
      App(name: "Deliveries", iconName: "Deliveries", onTap: { cell in
        
      }),
      App(name: "Settings", iconName: "Settings", onTap: { cell in
        
      })
    ]
    snapshot.appendItems(apps.map({ app in
      return Item.app(app)
    }), toSection: .apps)
    
    dataSource.apply(snapshot, animatingDifferences: animateDifferences)
  }
  
  private func nukeSnapshot() {
    var snapshot = dataSource.snapshot()
    snapshot.deleteAllItems()
    dataSource.apply(snapshot, animatingDifferences: false)
    applySnapshot(animateDifferences: false)
  }
}

extension SpringboardMimicViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let item = dataSource.itemIdentifier(for: indexPath) else {
      return
    }
    
    guard let cell = collectionView.cellForItem(at: indexPath) else {
      return
    }
    
    switch item {
    case let .app(app):
      DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
        app.onTap(cell)
      }
    default:
      break
    }
  }
}

extension SpringboardMimicViewController {
  private func configureLayout() {
    collectionView.collectionViewLayout = UICollectionViewCompositionalLayout(sectionProvider: { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
      let rawSection = self.dataSource.snapshot().sectionIdentifiers[sectionIndex]
      
      let size = NSCollectionLayoutSize(
        widthDimension: NSCollectionLayoutDimension.fractionalWidth(1),
        heightDimension: NSCollectionLayoutDimension.absolute(rawSection == .apps ? 180 : 300)
      )
      
      let itemCount = rawSection == .apps ? 4 : 1
      
      let item = NSCollectionLayoutItem(layoutSize: size)
      let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitem: item, count: itemCount)
      let section = NSCollectionLayoutSection(group: group)
      section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
      return section
    })
  }
  
  private func configureWidgetLayout() {
    collectionView.collectionViewLayout = UICollectionViewCompositionalLayout(sectionProvider: { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
      let rawSection = self.dataSource.snapshot().sectionIdentifiers[sectionIndex]
      
      let size = NSCollectionLayoutSize(
        widthDimension: NSCollectionLayoutDimension.fractionalWidth(1),
        heightDimension: NSCollectionLayoutDimension.absolute(rawSection == .apps ? 180 : 300)
      )
      
      let itemCount = rawSection == .apps ? 4 : 1
      
      let group: NSCollectionLayoutGroup
      if rawSection == .apps {
        let widgetItem = NSCollectionLayoutItem(
          layoutSize: NSCollectionLayoutSize(
            widthDimension: NSCollectionLayoutDimension.absolute(180),
            heightDimension: NSCollectionLayoutDimension.absolute(180)
          )
        )
        
        group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitem: widgetItem, count: itemCount)
      } else {
        let item = NSCollectionLayoutItem(layoutSize: size)
        group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitem: item, count: itemCount)
      }
      
      let section = NSCollectionLayoutSection(group: group)
      section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
      return section
    })
  }
  
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    coordinator.animate(alongsideTransition: { context in
      self.collectionView.collectionViewLayout.invalidateLayout()
    }, completion: nil)
  }
}

extension SpringboardMimicViewController: UIViewControllerTransitioningDelegate {
  func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return transition
  }
  
  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    transition.presenting = false
    return transition
  }
}
