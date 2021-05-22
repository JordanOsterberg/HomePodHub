//
//  SectionHeaderReusableView.swift
//  HomeApp
//
//  Created by Jordan Osterberg on 5/14/21.
//

import UIKit

class SectionHeaderReusableView: UICollectionReusableView {
  public static var reuseIdentifier: String {
    return String(describing: SectionHeaderReusableView.self)
  }
  
  private lazy var roomChangeButton: UIButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setImage(UIImage(systemName: "house", withConfiguration: UIImage.SymbolConfiguration(pointSize: 65)), for: .normal)
    button.tintColor = .white
    return button
  }()
  
  public lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = UIFont.systemFont(
      ofSize: 72,
      weight: .bold)
    label.adjustsFontForContentSizeCategory = true
    label.textColor = .white
    label.textAlignment = .left
    label.numberOfLines = 1
    label.setContentCompressionResistancePriority(
      .defaultHigh, for: .horizontal)
    return label
  }()
  
  private lazy var infoButton: UIButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.layer.cornerRadius = 100/2
    button.clipsToBounds = true
    button.setImage(UIImage(systemName: "questionmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 50)), for: .normal)
    button.backgroundColor = .white.withAlphaComponent(0.5)
    button.tintColor = .black
    return button
  }()
  
  private lazy var exitButton: UIButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.layer.cornerRadius = 100/2
    button.clipsToBounds = true
    button.setImage(UIImage(systemName: "xmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 50)), for: .normal)
    button.backgroundColor = .white.withAlphaComponent(0.5)
    button.tintColor = .black
    return button
  }()
  
  public var onRoomChangeButtonTapped: (() -> Void)?
  public var onInfoButtonTapped: (() -> Void)?
  public var onExitButtonTapped: (() -> Void)?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = .clear
    
    addSubview(roomChangeButton)
    addSubview(titleLabel)
    addSubview(infoButton)
    addSubview(exitButton)
    
    roomChangeButton.addAction(UIAction(handler: { _ in
      self.onRoomChangeButtonTapped?()
    }), for: .touchUpInside)
    
    infoButton.addAction(UIAction(handler: { _ in
      self.onInfoButtonTapped?()
    }), for: .touchUpInside)
    
    exitButton.addAction(UIAction(handler: { _ in
      self.onExitButtonTapped?()
    }), for: .touchUpInside)
    
    NSLayoutConstraint.activate([
      roomChangeButton.heightAnchor.constraint(equalToConstant: 100),
      roomChangeButton.widthAnchor.constraint(equalToConstant: 100),
      roomChangeButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
      roomChangeButton.leadingAnchor.constraint(lessThanOrEqualTo: leadingAnchor, constant: 5),
      
      titleLabel.leadingAnchor.constraint(
        equalTo: roomChangeButton.trailingAnchor,
        constant: 20),
      titleLabel.trailingAnchor.constraint(
        lessThanOrEqualTo: infoButton.leadingAnchor,
        constant: -5),
      titleLabel.topAnchor.constraint(
        equalTo: topAnchor,
        constant: 20),
      titleLabel.bottomAnchor.constraint(
        equalTo: bottomAnchor,
        constant: -20),
      
      infoButton.heightAnchor.constraint(equalToConstant: 100),
      infoButton.widthAnchor.constraint(equalToConstant: 100),
      infoButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
      infoButton.trailingAnchor.constraint(lessThanOrEqualTo: exitButton.leadingAnchor, constant: -15),
      
      exitButton.heightAnchor.constraint(equalToConstant: 100),
      exitButton.widthAnchor.constraint(equalToConstant: 100),
      exitButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
      exitButton.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -5)
    ])
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

