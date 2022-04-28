//
//  CreditsDataModel.swift
//  SumLit
//
//  Created by Junior Etrata on 1/9/20.
//  Copyright © 2020 Sumlit. All rights reserved.
//

import Firebase

struct CreditsDataModel {
    let creditsCount : Int
}

extension CreditsDataModel{
    init?(snapshot: DataSnapshot) {
        if let dict = snapshot.value as? [String:Any],
            let karmaCount = dict["creditsCount"] as? Int{
            self.creditsCount = karmaCount
        }else{
            return nil
        }
    }
}
