//
//  Images+CoreDataProperties.swift
//  Journal
//
//  Created by Alex Arovas on 12/21/15.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Images {

    @NSManaged var index: NSNumber?
    @NSManaged var image: NSData?

}
