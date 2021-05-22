//
//  BookmarkPage.swift
//  BookmarksApp
//
//  Created by Jordan Osterberg on 5/16/21.
//

import UIKit

struct BookmarkPage {
  let elements: [BookmarkElement]
  
  public func build(on contentView: UIView) {
    contentView.subviews.forEach {
      $0.removeFromSuperview()
    }
    
    var previousElement: BookmarkElement?
    var previousElementView: UIView?
    
    for element in elements {
      let view = element.makeView()
      
      contentView.addSubview(view)
      
      if let previousElementView = previousElementView {
        view.topAnchor.constraint(equalTo: previousElementView.bottomAnchor, constant: previousElement?.bottomPadding ?? 10)
          .isActive = true
      } else {
        view.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10)
          .isActive = true
      }
      
      NSLayoutConstraint.activate([
        view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
        view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
      ])
      
      element.applyAdditionalConstraints(within: contentView, to: view)
      
      previousElement = element
      previousElementView = view
    }
    
    if let previous = previousElementView {
      NSLayoutConstraint.activate([
        previous.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
      ])
    }
  }
}

protocol BookmarkElement {
  var bottomPadding: CGFloat { get }
  
  func makeView() -> UIView
  func applyAdditionalConstraints(within contentView: UIView, to view: UIView)
}

class LabelElement: BookmarkElement {
  private let text: String
  internal var bottomPadding: CGFloat
  internal var fontSize: CGFloat = 24
  internal var fontWeight: UIFont.Weight = . regular
  
  init(text: String, bottomPadding: CGFloat = 5) {
    self.text = text
    self.bottomPadding = bottomPadding
  }
  
  func makeView() -> UIView {
    let titleLabel = UILabel()
    titleLabel.font = UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
    titleLabel.text = text
    titleLabel.textColor = .white
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.numberOfLines = 0
    return titleLabel
  }
  
  func applyAdditionalConstraints(within scrollView: UIView, to view: UIView) {
    
  }
}

class TitleElement: LabelElement {
  override func makeView() -> UIView {
    fontSize = 36
    fontWeight = .medium
    
    return super.makeView()
  }
}

class ImageElement: BookmarkElement {
  internal var bottomPadding: CGFloat
  let imageName: String
  
  init(named imageName: String, bottomPadding: CGFloat = 10) {
    self.imageName = imageName
    self.bottomPadding = bottomPadding
  }
  
  func makeView() -> UIView {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .scaleAspectFill
    imageView.image = UIImage(named: imageName)
    imageView.clipsToBounds = true
    return imageView
  }
  
  func applyAdditionalConstraints(within scrollView: UIView, to view: UIView) {
    NSLayoutConstraint.activate([
      view.heightAnchor.constraint(equalToConstant: 300)
    ])
  }
}

class SpacerElement: BookmarkElement {
  var bottomPadding: CGFloat {
    return 5
  }
  
  let height: CGFloat
  init(height: CGFloat) {
    self.height = height
  }
  
  func makeView() -> UIView {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }
  
  func applyAdditionalConstraints(within contentView: UIView, to view: UIView) {
    view.heightAnchor.constraint(equalToConstant: height).isActive = true
  }
}
