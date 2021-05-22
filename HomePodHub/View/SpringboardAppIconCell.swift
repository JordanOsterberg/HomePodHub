//
//  SpringboardAppIconCell.swift
//  HomePodHub
//
//  Created by Jordan Osterberg on 5/13/21.
//

import UIKit

class SpringboardAppIconCell: UICollectionViewCell {
  private lazy var iconView: UIImageView = {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .scaleAspectFill
    imageView.clipsToBounds = true
    imageView.layer.cornerRadius = 16
    imageView.layer.cornerCurve = .continuous
    return imageView
  }()
  
  public var app: SpringboardMimicViewController.App? {
    didSet {
      iconView.image = UIImage(named: app?.iconName ?? "")
    }
  }
  
  public static var reuseIdentifier: String {
    return String(describing: self)
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    contentView.addSubview(iconView)
    layoutSubviews()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    NSLayoutConstraint.activate([
      iconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
      iconView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
      iconView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
      iconView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
    ])
  }
  
  override var isSelected: Bool {
    didSet {
      if !isSelected { return }
      depress()
    }
  }
  
  func depress() {
    UIView.animate(withDuration: 0.2) {
      self.iconView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
      
      UIView.animate(withDuration: 0.2, delay: 0.1) {
        self.iconView.transform = .identity
      }
    }
  }
}
