//
//  UserModel.swift
//  googleMap
//
//  Created by Ke4a on 13.12.2022.
//

import RealmSwift

final class UserModel: Object {
    @Persisted(primaryKey: true) private(set) var id: ObjectId
    @Persisted private var routes: List<RouteModel> = List()

    convenience init(id: ObjectId = .generate()) {
        self.init()
        self.id = id
    }
    
    func addRoute(_ route: RouteModel) {
        routes.append(route)
    }
}
