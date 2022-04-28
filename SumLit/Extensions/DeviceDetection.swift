//
//  DeviceDetection.swift
//  SumLit
//
//  Created by Junior Etrata on 1/24/20.
//  Copyright © 2020 Sumlit. All rights reserved.
//

import UIKit

struct DeviceDetection {
    static let isPhone = (UIDevice.current.userInterfaceIdiom == .phone)
    static let isPad = (UIDevice.current.userInterfaceIdiom == .pad)
}
