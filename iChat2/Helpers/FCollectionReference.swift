//
//  FCollectionReference.swift
//  iChat2
//
//  Created by Taisei Sakamoto on 2020/04/21.
//  Copyright © 2020 Taisei Sakamoto. All rights reserved.
//

import Foundation
import FirebaseFirestore

enum FCollectionReference: String {
    
    case User
    case Typing
    case Recent
    case Message
    case Group
}


func reference(_ collectionReference: FCollectionReference) -> CollectionReference {
    
    return Firestore.firestore().collection(collectionReference.rawValue)
}
