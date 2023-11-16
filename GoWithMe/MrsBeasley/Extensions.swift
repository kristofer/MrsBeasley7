//
//  Extensions.swift
//  MrsBeasley
//
//  Created by Kristofer Younger on 10/23/23.
//

import Foundation
import SwiftUI
import CoreData

extension Binding {
    func toUnwrapped<T>(defaultValue: T) -> Binding<T> where Value == Optional<T>  {
        Binding<T>(get: { self.wrappedValue ?? defaultValue }, set: { self.wrappedValue = $0 })
    }
}

extension NSManagedObjectContext {
    func flushChanges() {
        if self.hasChanges {
            try! self.save()

            //do {
//                DispatchQueue.main.async {   // <====
//                }
//            } catch {
//                let nserror = error as NSError
//                print("Unresolved error \(nserror), \(nserror.userInfo)")
//            }
        }
        
    }
}

