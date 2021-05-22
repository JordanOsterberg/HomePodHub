//
//  SpringboardStatusCell.swift
//  HomePodHub
//
//  Created by Jordan Osterberg on 5/13/21.
//

import UIKit
import Combine

class SpringboardStatusCell: UICollectionViewCell {
  private lazy var contentStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.alignment = .center
    stackView.axis = .horizontal
    stackView.distribution = .fillEqually
    return stackView
  }()
  
  private lazy var dateTimeStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.alignment = .center
    stackView.axis = .vertical
    stackView.distribution = .equalCentering
    return stackView
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
    label.textAlignment = .center
    label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    
    label.layer.shadowColor = UIColor.black.cgColor
    label.layer.shadowOpacity = 0.5
    label.layer.shadowOffset = CGSize(width: 2, height: 2)
    label.layer.shadowRadius = 10
    return label
  }()
  
  private lazy var dateLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    
    let size: CGFloat = 48
    var font = UIFont.systemFont(ofSize: size, weight: .medium)
    let descriptor = font.fontDescriptor.withDesign(.rounded)!
    font = UIFont(descriptor: descriptor, size: size)
    
    label.font = font
    label.numberOfLines = 0
    label.textColor = .white
    label.textAlignment = .center
    
    label.layer.shadowColor = UIColor.black.cgColor
    label.layer.shadowOpacity = 0.5
    label.layer.shadowOffset = CGSize(width: 2, height: 2)
    label.layer.shadowRadius = 10
    return label
  }()
  
  private lazy var statusAreaStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.alignment = .center
    stackView.axis = .horizontal
    stackView.distribution = .fill
    stackView.spacing = 30
    return stackView
  }()
  
  private lazy var statusImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .scaleAspectFill
    imageView.layer.cornerRadius = 6
    imageView.clipsToBounds = true
    imageView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    
    imageView.layer.shadowColor = UIColor.black.cgColor
    imageView.layer.shadowOpacity = 0.5
    imageView.layer.shadowOffset = CGSize(width: 2, height: 2)
    imageView.layer.shadowRadius = 10
    return imageView
  }()
  
  private lazy var statusTextStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.alignment = .leading
    stackView.axis = .vertical
    stackView.distribution = .equalCentering
    return stackView
  }()
  
  private lazy var statusTitleLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    
    label.font = UIFont.systemFont(ofSize: 32, weight: .semibold)
    label.numberOfLines = 0
    label.textColor = .white
    label.textAlignment = .left
    
    label.layer.shadowColor = UIColor.black.cgColor
    label.layer.shadowOpacity = 0.5
    label.layer.shadowOffset = CGSize(width: 2, height: 2)
    label.layer.shadowRadius = 10
    return label
  }()
  
  private lazy var statusSubtitleLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    
    label.font = UIFont.systemFont(ofSize: 28, weight: .medium)
    label.numberOfLines = 0
    label.textColor = .white.withAlphaComponent(0.5)
    label.textAlignment = .left
    
    label.layer.shadowColor = UIColor.black.cgColor
    label.layer.shadowOpacity = 0.5
    label.layer.shadowOffset = CGSize(width: 2, height: 2)
    label.layer.shadowRadius = 10
    return label
  }()
  
  private lazy var timeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "h:mm a"
    return formatter
  }()
  
  private lazy var dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEEE, MMM d"
    return formatter
  }()
  
  public var date: Date? {
    didSet {
      if date == nil {
        date = Date()
        return
      }
      
      guard let date = date else { return }
      
      timeLabel.text = timeFormatter.string(from: date)
      dateLabel.text = dateFormatter.string(from: date)
    }
  }
  
  public var datePublisher: Published<Date?>.Publisher? {
    didSet {
      self.dateCancellable?.cancel()
      self.dateCancellable = datePublisher?.sink(receiveValue: { date in
        DispatchQueue.main.async {
          self.date = date
        }
      })
    }
  }
  private var dateCancellable: AnyCancellable?
  
  public var statusPublisher: Published<SpringboardStatus?>.Publisher? {
    didSet {
      self.statusCancellable?.cancel()
      self.statusCancellable = statusPublisher?.sink(receiveValue: { status in
        DispatchQueue.main.async {
          self.status = status
        }
      })
    }
  }
  private var statusCancellable: AnyCancellable?
  
  public var status: SpringboardStatus? {
    didSet {
      if status != nil {
        statusImageView.image = status?.image ?? UIImage(named: "Nothing Playing Icon")
        statusTitleLabel.text = status?.title ?? ""
        statusSubtitleLabel.text = status?.subtitle ?? ""
      }
      
      if statusAreaStackView.isHidden {
        UIView.animate(withDuration: 0.4) {
          self.statusAreaStackView.isHidden = false
        }
      }
      
      if status == nil {
        UIView.animate(withDuration: 0.4) {
          self.statusAreaStackView.isHidden = true
        }
      }
    }
  }
  
  public static var reuseIdentifier: String {
    return String(describing: self)
  }
  
  deinit {
    statusCancellable?.cancel()
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    contentView.addSubview(contentStackView)
    
    contentStackView.addArrangedSubview(dateTimeStackView)
    dateTimeStackView.addArrangedSubview(timeLabel)
    dateTimeStackView.addArrangedSubview(dateLabel)
    
    contentStackView.addArrangedSubview(statusAreaStackView)
    statusAreaStackView.addArrangedSubview(statusImageView)
    statusAreaStackView.addArrangedSubview(statusTextStackView)
    statusTextStackView.addArrangedSubview(statusTitleLabel)
    statusTextStackView.addArrangedSubview(statusSubtitleLabel)
    
    statusAreaStackView.isHidden = true

    layoutSubviews()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    NSLayoutConstraint.activate([
      contentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      contentStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30),
      contentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30),
      
      statusImageView.widthAnchor.constraint(equalToConstant: 200),
      statusImageView.heightAnchor.constraint(equalToConstant: 200)
    ])
  }
}
