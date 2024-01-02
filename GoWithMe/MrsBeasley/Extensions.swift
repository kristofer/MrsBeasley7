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
        //DispatchQueue.main.async {   // <====
        if self.hasChanges {
                do {
                    print("Actually FLUSHING Changes.")
                    try self.save()
                } catch {
                    let nserror = error as NSError
                    print("Unresolved error in flushChanges \(nserror), \(nserror.userInfo)")
                }
            }
        //}
        
    }
}

extension Note {
    func loadBlobToData() -> URL? {
        if self.uuid == nil {
            self.uuid = UUID()
        }
        if let pdfData = self.blob, let fname = self.title!.convertedToSlug() {
            let pathURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("\(fname).pdf")
            do {
                try pdfData.write(to: pathURL, options: .atomic)
            } catch {
                print("Error while writing blob to local file for display")
            }
            return pathURL
        }
        return nil
    }
    
}


// to slugify the doc title to a string
extension String {
    private static let slugSafeCharacters = CharacterSet(charactersIn: "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-")
    
    public func convertedToSlug() -> String? {
        if let latin = self.applyingTransform(StringTransform("Any-Latin; Latin-ASCII; Lower;"), reverse: false) {
            let urlComponents = latin.components(separatedBy: String.slugSafeCharacters.inverted)
            let result = urlComponents.filter { $0 != "" }.joined(separator: "-")
            
            if result.count > 0 {
                return result
            }
        }
        
        return nil
    }
}
