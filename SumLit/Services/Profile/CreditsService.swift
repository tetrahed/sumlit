//
//  CreditsService.swift
//  SumLit
//
//  Created by Junior Etrata on 1/9/20.
//  Copyright © 2020 Sumlit. All rights reserved.
//

import FirebaseDatabase

struct CreditsService {
    func fetchKarma(useruuid: String, completion: @escaping ((Result<CreditsDataModel, Error>) -> Void)){
        Constants.FirebaseRefs.creditsRef.child(useruuid).observeSingleEvent(of: .value) { (snapshot) in
            if let karma = CreditsDataModel(snapshot: snapshot){
                completion(.success(karma))
            }else{
                completion(.failure(CustomErrors.GeneralErrors.unknownError))
            }
        }
    }
}
