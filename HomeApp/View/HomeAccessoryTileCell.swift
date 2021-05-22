//
//  HomeAccessoryTileCell.swift
//  HomeApp
//
//  Created by Jordan Osterberg on 5/14/21.
//

import UIKit
import HomeKit

class HomeAccessoryTileCell: UICollectionViewCell {
  private var blurEffect: UIBlurEffect {
    UIBlurEffect(style: traitCollection.userInterfaceStyle == .dark ? .dark : .light)
  }
  
  private lazy var containerView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.clipsToBounds = true
    view.layer.cornerRadius = 40
    view.layer.cornerCurve = .continuous
    return view
  }()
  
  private lazy var visualEffectView: UIVisualEffectView = {
    let view = UIVisualEffectView(effect: blurEffect)
    view.translatesAutoresizingMaskIntoConstraints = false
    view.clipsToBounds = true
    view.layer.cornerRadius = 40
    view.layer.cornerCurve = .continuous
    return view
  }()
  
  private lazy var iconView: UIImageView = {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    return imageView
  }()
  
  private lazy var nameLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = UIFont.systemFont(ofSize: 36, weight: .semibold)
    label.numberOfLines = 2
    label.textColor = .white
    return label
  }()
  
  private lazy var statusLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = UIFont.systemFont(ofSize: 36, weight: .semibold)
    label.numberOfLines = 1
    label.textColor = .white.withAlphaComponent(0.5)
    return label
  }()
  
  public static var reuseIdentifier: String {
    return String(describing: self)
  }
  
  public var service: HMService? {
    willSet {
      service?.accessory?.delegate = nil
    }
    
    didSet {
      service?.accessory?.delegate = self
      redraw()
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    contentView.addSubview(containerView)
    containerView.addSubview(visualEffectView)
    containerView.addSubview(iconView)
    containerView.addSubview(nameLabel)
    containerView.addSubview(statusLabel)
    
    layoutSubviews()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    NSLayoutConstraint.activate([
      containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
      containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
      
      visualEffectView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
      visualEffectView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
      visualEffectView.topAnchor.constraint(equalTo: containerView.topAnchor),
      visualEffectView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
      
      iconView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
      iconView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
      iconView.widthAnchor.constraint(equalToConstant: 80),
      iconView.heightAnchor.constraint(equalToConstant: 80),
      
      statusLabel.leadingAnchor.constraint(equalTo: iconView.leadingAnchor),
      statusLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
      statusLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20),
      
      nameLabel.bottomAnchor.constraint(equalTo: statusLabel.topAnchor, constant: 0),
      nameLabel.leadingAnchor.constraint(equalTo: statusLabel.leadingAnchor),
      nameLabel.trailingAnchor.constraint(equalTo: statusLabel.trailingAnchor)
    ])
  }
  
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
    if previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle {
      redraw()
    }
  }
  
  private func redraw() {
    guard let service = service else {
      return
    }
    
    if service.serviceType == HMServiceTypeLightbulb || service.associatedServiceType == HMServiceTypeLightbulb {
      iconView.image = UIImage(systemName: "lightbulb.fill")
      let powerStateCharacteristic = service.characteristics.first { characteristic in
        return characteristic.characteristicType == HMCharacteristicTypePowerState
      }
      
      let on = (powerStateCharacteristic?.value as? Bool) == true
      iconView.tintColor = on ? .systemYellow : .systemGray.withAlphaComponent(0.5)
      nameLabel.text = service.name
      statusLabel.text = on ? "On" : "Off"
      
      if on {
        containerView.backgroundColor = .white
        visualEffectView.effect = UIBlurEffect(style: .light)
      } else {
        visualEffectView.effect = blurEffect
        containerView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .black : .white.withAlphaComponent(0.8)
      }
      nameLabel.textColor = on ? .black : .gray
      statusLabel.textColor = on ? .gray : .gray.withAlphaComponent(0.5)
    }
  }
  
  public func updateAppearance() {
    redraw()
  }
  
  public func depress() {
    UIView.animate(
      withDuration: 0.2,
      delay: 0.0,
      usingSpringWithDamping: 0.5,
      initialSpringVelocity: 0.2,
      options: .curveEaseInOut
    ) {
      self.containerView.transform = CGAffineTransform(scaleX: 0.90, y: 0.90)
      
      UIView.animate(withDuration: 0.2, delay: 0.1) {
        self.containerView.transform = .identity
      }
    }
  }
}

extension HomeAccessoryTileCell: HMAccessoryDelegate {
  func accessory(_ accessory: HMAccessory, service: HMService, didUpdateValueFor characteristic: HMCharacteristic) {
    redraw()
  }
}
