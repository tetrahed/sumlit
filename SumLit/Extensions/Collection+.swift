//
//  Collection+.swift
//  SumLit
//
//  Created by Junior Etrata on 10/26/19.
//  Copyright © 2019 Sumlit. All rights reserved.
//

import Foundation

extension Collection where Indices.Iterator.Element == Index {
   subscript (exist index: Index) -> Iterator.Element? {
      return indices.contains(index) ? self[index] : nil
   }
}
