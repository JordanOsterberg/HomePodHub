//
//  NoPermissionView.swift
//  PhotoSlideshow
//
//  Created by Jordan Osterberg on 5/14/21.
//

import UIKit

class NoPermissionView: UIView {
  private lazy var stackView: UIStackView = {
    let stackView = UIStackView()
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.axis = .vertical
    stackView.alignment = .center
    stackView.distribution = .fill
    return stackView
  }()
  
  private lazy var iconView: UIImageView = {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.image = UIImage(systemName: "eye.slash.fill")
    imageView.contentMode = .scaleAspectFit
    imageView.tintColor = .white
    return imageView
  }()
  
  private lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    
    label.font = UIFont.systemFont(ofSize: 48, weight: .medium)
    label.numberOfLines = 0
    label.textColor = .white
    label.textAlignment = .center
    
    label.layer.shadowColor = UIColor.black.cgColor
    label.layer.shadowOpacity = 0.5
    label.layer.shadowOffset = CGSize(width: 2, height: 2)
    label.layer.shadowRadius = 10
    return label
  }()
  
  private lazy var subtitleLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    
    label.font = UIFont.systemFont(ofSize: 32, weight: .medium)
    label.numberOfLines = 0
    label.textColor = .white
    label.textAlignment = .center
    
    label.layer.shadowColor = UIColor.black.cgColor
    label.layer.shadowOpacity = 0.5
    label.layer.shadowOffset = CGSize(width: 2, height: 2)
    label.layer.shadowRadius = 10
    return label
  }()
  
  init() {
    super.init(frame: CGRect.zero)
    
    backgroundColor = .black
    
    titleLabel.text = "No Permission"
    subtitleLabel.text = "Please give the HomePodHub app permission before using this feature."
    
    addSubview(stackView)
    stackView.addArrangedSubview(iconView)
    stackView.addArrangedSubview(titleLabel)
    stackView.addArrangedSubview(subtitleLabel)
    
    NSLayoutConstraint.activate([
      stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
      stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
      stackView.topAnchor.constraint(equalTo: topAnchor),
//      stackView.centerYAnchor.constraint(equalTo: centery)
//      stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
      stackView.heightAnchor.constraint(lessThanOrEqualTo: heightAnchor, multiplier: 1/2),
      
      iconView.heightAnchor.constraint(equalToConstant: 250),
      iconView.widthAnchor.constraint(equalToConstant: 250)
    ])
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
