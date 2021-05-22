//
//  BookmarksAppViewController.swift
//  BookmarksApp
//
//  Created by Jordan Osterberg on 5/16/21.
//

import UIKit
import WebKit

public class BookmarksAppViewController: UIViewController {
  private lazy var containerView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  private lazy var scrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    scrollView.alwaysBounceVertical = true
    scrollView.alwaysBounceHorizontal = false
    return scrollView
  }()
  
  private lazy var contentView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  private lazy var closeButton: UIButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.layer.cornerRadius = 60/2
    button.clipsToBounds = true
    button.setImage(UIImage(systemName: "xmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25)), for: .normal)
    button.backgroundColor = .white.withAlphaComponent(0.5)
    button.tintColor = .black
    return button
  }()
  
  private var page: BookmarkPage? {
    didSet {
      page?.build(on: contentView)
    }
  }
  
  public override var prefersStatusBarHidden: Bool {
    return true
  }
  
  public override var prefersHomeIndicatorAutoHidden: Bool {
    return true
  }
  
  public override func viewDidLoad() {
    containerView.alpha = 0
    
    view.backgroundColor = .clear
    view.addSubview(containerView)
    containerView.addSubview(closeButton)
    containerView.addSubview(scrollView)
    scrollView.addSubview(contentView)
    
    setupConstraints()
    
    page = BookmarkPage(
      elements: [
        TitleElement(text: "Classic Cheesecake Recipe"),
        LabelElement(text: "Posted on May 2, 2018 / posted in Cheesecake / 1006 comments"),
        SpacerElement(height: 20),
        LabelElement(text: "Look no further for a creamy and ultra smooth classic cheesecake recipe! Paired with a buttery graham cracker crust, no one can deny its simple decadence. For the best results, bake in a water bath."),
        SpacerElement(height: 20),
        ImageElement(named: "Cheesecake", bottomPadding: 20),
        TitleElement(text: "How To Make Classic Cheesecake"),
        LabelElement(text: "You only need a few basic staple ingredients for this cheesecake recipe."),
        LabelElement(text: "1. Block cream cheese: Four 8-ounce blocks of full-fat cream cheese are the base of this cheesecake. That’s 2 pounds. Make sure you’re buying the blocks of cream cheese and not cream cheese spread. There’s no diets allowed in cheesecake, so don’t pick up the reduced fat variety!", bottomPadding: 15),
        LabelElement(text: "2. Sugar: 1 cup. Not that much considering how many mouths you can feed with this dessert. Over-sweetened cheesecake is hardly cheesecake anymore. Using only 1 cup of sugar gives this cheesecake the opportunity to balance tangy and sweet, just as classic cheesecake should taste.", bottomPadding: 15),
        LabelElement(text: "3. Sour cream: 1 cup. I recently tested a cheesecake recipe with 1 cup of heavy cream instead, but ended up sticking with my original. I was curious about the heavy cream addition and figured it would yield a softer cheesecake bite. The cheesecake was soft, but lacked the stability and richness I wanted. It was almost too creamy. Sour cream is most definitely the right choice.", bottomPadding: 15),
        LabelElement(text: "4. A little flavor: 1 teaspoon of pure vanilla extract and 2 of lemon juice. The lemon juice brightens up the cheesecake’s overall flavor and vanilla is always a good idea.", bottomPadding: 15),
        LabelElement(text: "5. Eggs: 3 eggs are the final ingredient. You’ll beat the eggs in last, one at a time, until they are *just* incorporated. Do not overmix the batter once the eggs are added. This will whip air into the cheesecake batter, resulting in cheesecake cracking and deflating.", bottomPadding: 15)
      ]
    )
    
    closeButton.addAction(UIAction(handler: { _ in
      self.dismiss(animated: true, completion: nil)
    }), for: .touchUpInside)
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    containerView.backgroundColor = .black
    
    UIView.animate(withDuration: 0.2) {
      self.containerView.alpha = 1
    } completion: { _ in
      self.view.backgroundColor = .black
    }

  }
  
  public override func viewWillDisappear(_ animated: Bool) {
    view.backgroundColor = .clear
    UIView.animate(withDuration: 0.3) {
      self.containerView.alpha = 0
    }
  }
  
  private func setupConstraints() {
    NSLayoutConstraint.activate([
      containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      containerView.topAnchor.constraint(equalTo: view.topAnchor),
      containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      
      scrollView.leadingAnchor.constraint(equalTo: containerView.readableContentGuide.leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: containerView.readableContentGuide.trailingAnchor),
      scrollView.topAnchor.constraint(equalTo: containerView.topAnchor),
      scrollView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
      
      contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
      contentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
      contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
      contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
      
      closeButton.heightAnchor.constraint(equalToConstant: 60),
      closeButton.widthAnchor.constraint(equalToConstant: 60),
      closeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
      closeButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20)
    ])
    
    let bottom = contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
    let centerY = contentView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor)
    
    bottom.priority = .defaultHigh
    centerY.priority = .defaultHigh
    
    bottom.isActive = true
    centerY.isActive = true
  }
}
