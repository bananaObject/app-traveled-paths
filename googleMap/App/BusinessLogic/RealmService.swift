//
//  RealmService.swift
//  googleMap
//
//  Created by Ke4a on 09.12.2022.
//

import Foundation
import GoogleMaps
import RealmSwift

extension RealmService {
    enum RealmError: String, Error {
        case noObject
        case writeError
        case deleteError
        case updateError
    }
}

protocol RealmServiceProtocol {
    /// Getting the object by primary key
    /// - Parameters:
    ///   - model: Realm model.
    ///   - primaryKey: Key
    /// - Returns: Object.
    func get<T: Object>(_ model: T.Type, primaryKey: Any) throws -> T
    /// Getting objects from the database.
    /// - Parameter model: Realm model.
    /// - Returns: Objects.
    func get<T: Object>(_ model: T.Type) throws -> Results<T>
    /// Writing objects to the database.
    /// - Parameter objects: Realm models.
    func set<T: Object>(_ objects: [T])  throws
    /// Writing object to the database.
    /// - Parameter object: Realm model.
    func set<T: Object>(_ object: T)  throws
    /// Block updating the model information.
    /// - Parameter writeBlock: A compilation block in which the infomation is updated.
    func update(_ writeBlock: () -> Void) throws
    /// Deleting data from the database.
    /// - Parameter objects: Realm models.
    func delete<T: Object>(_ objects: [T]) throws
    /// Deleting data from the database
    /// - Parameter object: Realm model.
    func delete<T: Object>(_ object: T)  throws
}

final class RealmService: RealmServiceProtocol {
    // MARK: - Private Properties

    private let realm: Realm

    // MARK: - Initialization

    init() {
        do {
            var config: Realm.Configuration = Realm.Configuration()
            config.deleteRealmIfMigrationNeeded = true
            self.realm = try Realm(configuration: config)
        } catch {
            preconditionFailure(error.localizedDescription)
        }

        print("FILE: \(String(describing: realm.configuration.fileURL))")
    }

    // MARK: - Public Methods
    
    func get<T: Object>(_ model: T.Type, primaryKey: Any) throws -> T {
        guard let object = realm.object(ofType: T.self, forPrimaryKey: primaryKey) else { throw RealmError.noObject }
        return object
    }

    func get<T: Object>(_ model: T.Type) throws -> Results<T> {
        return realm.objects(T.self)
    }

    func set<T: Object>(_ objects: [T])  throws {
        realm.beginWrite()
        objects.forEach { value in
            realm.add(value, update: .modified)
        }
        do {
            try realm.commitWrite()
        } catch {
            throw RealmError.writeError
        }
    }

    func set<T: Object>(_ object: T)  throws {
        do {
            try realm.write {
                realm.add(object, update: .modified)
            }
        } catch {
            throw RealmError.writeError
        }
    }

    func update(_ writeBlock: () -> Void) throws {
        do {
            try realm.write {
                writeBlock()
            }
        } catch {
            throw RealmError.updateError
        }
    }

    func delete<T: Object>(_ objects: [T]) throws {
        realm.beginWrite()
        objects.forEach { object in
            realm.delete(object)
        }
        do {
            try realm.commitWrite()
        } catch {
            throw RealmError.writeError
        }
    }

    func delete<T: Object>(_ object: T)  throws {
        do {
            try realm.write {
                realm.delete(object)
            }
        } catch {
            throw RealmError.deleteError
        }
    }
}
