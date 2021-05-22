//
//  HomeAppViewController.swift
//  HomeApp
//
//  Created by Jordan Osterberg on 5/14/21.
//

import UIKit
import HomeKit

// This app doesn't really support groups of accessories (multiple Phillips bulbs grouped together in my Home show as independent accessories.
// You can modify this fairly easily- I just didn't for this concept because I was short on time.
// It also doesn't display accessories that aren't lightbulbs

public class HomeAppViewController: UIViewController {
  private lazy var containerView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = .clear
    return view
  }()
  
  private lazy var backgroundImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .scaleAspectFill
    imageView.image = UIImage(named: "HomeBG")
    return imageView
  }()
  
  private lazy var visualEffectView: UIVisualEffectView = {
    let view = UIVisualEffectView(effect: blurEffect)
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  private var blurEffect: UIBlurEffect {
    UIBlurEffect(style: traitCollection.userInterfaceStyle == .dark ? .dark : .light)
  }

  private lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewLayout())
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    collectionView.backgroundColor = .clear
    return collectionView
  }()
  
  public override var prefersStatusBarHidden: Bool {
    return true
  }
  
  public override var prefersHomeIndicatorAutoHidden: Bool {
    return true
  }
  
  let homeManager = HMHomeManager()
  
  var currentRoom: HMRoom? {
    didSet {
      applySnapshot()
    }
  }
  
  var rooms: [HMRoom] = []
  var services: [HMRoom : [HMService]] = [:]
  
  var primaryHome: HMHome? {
    didSet {
      services.removeAll()
      rooms.removeAll()
      
      guard let home = primaryHome else {
        currentRoom = nil
        return
      }
      
      for room in home.rooms {
        rooms.append(room)
        var services: [HMService] = []
        for accessory in room.accessories {
          services.append(contentsOf: accessory.services.filter({ service in
            if !service.isPrimaryService { return false }
            if service.serviceType != HMServiceTypeLightbulb && service.associatedServiceType != HMServiceTypeLightbulb { return false }
            return true
          }))
        }
        self.services[room] = services
      }
      
      if rooms.count > 0 {
        currentRoom = rooms[0]
      } else {
        print("No rooms found")
      }
    }
  }
  
  enum Section {
    case accessories
  }
  
  typealias DataSource = UICollectionViewDiffableDataSource<Section, HMService>
  typealias Snapshot = NSDiffableDataSourceSnapshot<Section, HMService>
  
  lazy var dataSource = makeDataSource()
  
  override public func viewDidLoad() {
    view.backgroundColor = .black
    
    homeManager.delegate = self
    
    view.addSubview(containerView)
    containerView.addSubview(backgroundImageView)
    containerView.addSubview(visualEffectView)
    containerView.addSubview(collectionView)
    
    NSLayoutConstraint.activate([
      containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      containerView.topAnchor.constraint(equalTo: view.topAnchor),
      containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      
      backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
      backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      backgroundImageView.heightAnchor.constraint(equalTo: view.heightAnchor),
      backgroundImageView.widthAnchor.constraint(equalTo: view.widthAnchor),
      
      visualEffectView.topAnchor.constraint(equalTo: view.topAnchor),
      visualEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      visualEffectView.heightAnchor.constraint(equalTo: view.heightAnchor),
      visualEffectView.widthAnchor.constraint(equalTo: view.widthAnchor),
      
      collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      collectionView.topAnchor.constraint(equalTo: view.topAnchor),
      collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
    
    collectionView.delegate = self
    
    configureLayout()
    loadHomes()
  }
  
  func loadHomes() {
    primaryHome = homeManager.primaryHome
  }
  
  public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
    if traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
      visualEffectView.effect = blurEffect
    }
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    view.backgroundColor = .black
    
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
}

extension HomeAppViewController: HMHomeManagerDelegate {
  public func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
    loadHomes()
  }
}

extension HomeAppViewController: UICollectionViewDelegate {
  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let item = dataSource.itemIdentifier(for: indexPath) else {
      return
    }
    
    guard let cell = collectionView.cellForItem(at: indexPath) as? HomeAccessoryTileCell else {
      return
    }
    
    let powerState = item.characteristics.first { characteristic in
      return characteristic.characteristicType == HMCharacteristicTypePowerState
    }
    
    cell.depress()
    
    powerState?.writeValue(!(powerState?.value as? Bool ?? true), completionHandler: { _ in
      cell.updateAppearance()
    })
  }
}

extension HomeAppViewController {
  private func makeDataSource() -> DataSource {
    collectionView.register(HomeAccessoryTileCell.self, forCellWithReuseIdentifier: HomeAccessoryTileCell.reuseIdentifier)
    
    collectionView.register(
      SectionHeaderReusableView.self,
      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
      withReuseIdentifier: SectionHeaderReusableView.reuseIdentifier
    )
    
    let dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, service in
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeAccessoryTileCell.reuseIdentifier, for: indexPath) as? HomeAccessoryTileCell
      cell?.service = service
      return cell
    }
    dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
      guard kind == UICollectionView.elementKindSectionHeader else {
        return nil
      }
      let view = collectionView.dequeueReusableSupplementaryView(
        ofKind: kind,
        withReuseIdentifier: SectionHeaderReusableView.reuseIdentifier,
        for: indexPath) as? SectionHeaderReusableView
      view?.titleLabel.text = self.currentRoom?.name ?? "Unknown Room"
      view?.onExitButtonTapped = {
        self.dismiss(animated: true, completion: nil)
      }
      view?.onInfoButtonTapped = {
        let alert = UIAlertController(title: "Info", message: "This app is configured to only display lightbulbs in specific rooms. If you don't have lights, you'll need to modify the source code to display other accessories.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
      }
      view?.onRoomChangeButtonTapped = {
        let alert = UIAlertController(title: "Rooms", message: "", preferredStyle: .alert)
        for room in self.rooms {
          alert.addAction(UIAlertAction(title: room.name, style: .default, handler: { _ in
            self.currentRoom = room
          }))
        }
        alert.addAction(UIAlertAction(title: "Nevermind", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
      }
      return view
    }
    return dataSource
  }

  private func applySnapshot(animatingDifferences: Bool = true) {
    var snapshot = Snapshot()
    snapshot.appendSections([.accessories])
    if let currentRoom = currentRoom, let services = services[currentRoom] {
      snapshot.appendItems(services, toSection: .accessories)
    }
    if dataSource.snapshot().sectionIdentifiers.contains(.accessories) {
      snapshot.reloadSections([.accessories])
    }
    dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
  }
}

extension HomeAppViewController {
  private func configureLayout() {
    collectionView.collectionViewLayout = UICollectionViewCompositionalLayout(sectionProvider: { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
      
      let size = NSCollectionLayoutSize(
        widthDimension: NSCollectionLayoutDimension.fractionalWidth(1),
        heightDimension: NSCollectionLayoutDimension.absolute(310)
      )
      
      let itemCount = 4
      
      let item = NSCollectionLayoutItem(layoutSize: size)
      item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
      
      let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitem: item, count: itemCount)
      group.interItemSpacing = NSCollectionLayoutSpacing.fixed(20)
      
      let section = NSCollectionLayoutSection(group: group)
      section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 30, bottom: 10, trailing: 30)
      
      let headerFooterSize = NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .estimated(40)
      )
      let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
        layoutSize: headerFooterSize,
        elementKind: UICollectionView.elementKindSectionHeader,
        alignment: .top
      )
      section.boundarySupplementaryItems = [sectionHeader]
      
      return section
    })
  }
  
  public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    coordinator.animate(alongsideTransition: { context in
      self.collectionView.collectionViewLayout.invalidateLayout()
    }, completion: nil)
  }
}
