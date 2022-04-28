//
//  LoginProtocol.swift
//  SumLit
//
//  Created by Junior Etrata on 9/3/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import UIKit

protocol LoginProtocol {
   func navigateToFeed()
   func performLogin(email: String?, password: String?)
   func resendVerification()
}
