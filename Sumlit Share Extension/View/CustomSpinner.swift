//
//  CustomSpinner.swift
//  Sumlit Share Extension
//
//  Created by Junior Etrata on 11/23/19.
//  Copyright © 2019 Sumlit. All rights reserved.
//

import UIKit

final class QuickSetupSpinner {
   
   fileprivate static var activityIndicator: UIActivityIndicatorView?
   fileprivate static var style: UIActivityIndicatorView.Style = .whiteLarge
   fileprivate static var baseBackColor = UIColor(white: 0, alpha: 0.6)
   fileprivate static var baseColor = UIColor.white
   
   public static func start(from view: UIView,
                            style: UIActivityIndicatorView.Style = QuickSetupSpinner.style,
                            backgroundColor: UIColor = QuickSetupSpinner.baseBackColor,
                            baseColor: UIColor = QuickSetupSpinner.baseColor) {
      
      guard QuickSetupSpinner.activityIndicator == nil else { return }
      
      let spinner = UIActivityIndicatorView(style: style)
      spinner.backgroundColor = backgroundColor
      spinner.color = baseColor
      spinner.translatesAutoresizingMaskIntoConstraints = false
      spinner.layer.cornerRadius = view.layer.cornerRadius
      view.addSubview(spinner)
      
      // Auto-layout constraints
      addConstraints(to: view, with: spinner)
      
      QuickSetupSpinner.activityIndicator = spinner
      QuickSetupSpinner.activityIndicator?.startAnimating()
   }
   
   public static func start(from view: UIView,
                            style: UIActivityIndicatorView.Style = QuickSetupSpinner.style,
                            backgroundColor: UIColor = QuickSetupSpinner.baseBackColor,
                            baseColor: UIColor = QuickSetupSpinner.baseColor,
                            cornerRadius: CGFloat) {
      
      guard QuickSetupSpinner.activityIndicator == nil else { return }
      
      let spinner = UIActivityIndicatorView(style: style)
      spinner.backgroundColor = backgroundColor
      spinner.color = baseColor
      spinner.translatesAutoresizingMaskIntoConstraints = false
      spinner.layer.cornerRadius = cornerRadius
      view.addSubview(spinner)
      
      // Auto-layout constraints
      addConstraints(to: view, with: spinner)
      
      QuickSetupSpinner.activityIndicator = spinner
      QuickSetupSpinner.activityIndicator?.startAnimating()
   }
   
   public static func stop() {
      QuickSetupSpinner.activityIndicator?.stopAnimating()
      QuickSetupSpinner.activityIndicator?.removeFromSuperview()
      QuickSetupSpinner.activityIndicator = nil
   }
   
   fileprivate static func addConstraints(to view: UIView, with spinner: UIActivityIndicatorView) {
      spinner.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
      spinner.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
      spinner.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
      spinner.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
   }
}

final class Spinner {
   
   fileprivate var activityIndicator: UIActivityIndicatorView?
   fileprivate var style: UIActivityIndicatorView.Style = .whiteLarge
   fileprivate var baseBackColor = UIColor(white: 0, alpha: 0.6)
   fileprivate var baseColor = UIColor.white
   
   public func start(from view: UIView,
                     style: UIActivityIndicatorView.Style =  .whiteLarge,
                     backgroundColor: UIColor = UIColor(white: 0, alpha: 0.6),
                     baseColor: UIColor = UIColor.white) {
      
      guard activityIndicator == nil else { return }
      
      let spinner = UIActivityIndicatorView(style: style)
      spinner.backgroundColor = backgroundColor
      spinner.color = baseColor
      spinner.translatesAutoresizingMaskIntoConstraints = false
      spinner.layer.cornerRadius = view.layer.cornerRadius
      spinner.clipsToBounds = true
      view.addSubview(spinner)
      
      // Auto-layout constraints
      addConstraints(to: view, with: spinner)
      
      activityIndicator = spinner
      activityIndicator?.startAnimating()
   }
   
   public func start(from view: UIView,
                     style: UIActivityIndicatorView.Style = QuickSetupSpinner.style,
                     backgroundColor: UIColor = QuickSetupSpinner.baseBackColor,
                     baseColor: UIColor = QuickSetupSpinner.baseColor,
                     cornerRadius: CGFloat) {
      
      guard activityIndicator == nil else { return }
      
      let spinner = UIActivityIndicatorView(style: style)
      spinner.backgroundColor = backgroundColor
      spinner.color = baseColor
      spinner.translatesAutoresizingMaskIntoConstraints = false
      spinner.layer.cornerRadius = cornerRadius
      spinner.clipsToBounds = true
      view.addSubview(spinner)
      
      // Auto-layout constraints
      addConstraints(to: view, with: spinner)
      
      activityIndicator = spinner
      activityIndicator?.startAnimating()
   }
   
   public func stop() {
      activityIndicator?.stopAnimating()
      activityIndicator?.removeFromSuperview()
      activityIndicator = nil
   }
   
   fileprivate func addConstraints(to view: UIView, with spinner: UIActivityIndicatorView) {
      spinner.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
      spinner.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
      spinner.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
      spinner.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
   }
}
