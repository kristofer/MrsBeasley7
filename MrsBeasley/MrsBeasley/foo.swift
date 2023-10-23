//
//  foo.swift
//  MrsBeasley
//
//  Created by Kristofer Younger on 10/23/23.
//

import Foundation
//
//override func viewDidLoad() {
//    super.viewDidLoad()
//    // self.extensionContext can be used to retrieve images, videos and urls from share extension input
//    let extensionAttachments = (self.extensionContext!.inputItems.first as! NSExtensionItem).attachments
//    for provider in extensionAttachments! {
//        
//        let variousKinds = provider.registeredTypeIdentifiers
//        
//        for kind in variousKinds {
//            print("***Current Kind is \(kind)")
//            
//            if provider.hasItemConformingToTypeIdentifier("public.plain-text") {
//                print("found a \(kind)")
//                provider.loadItem(forTypeIdentifier: "public.plain-text"){ data, _ in
//                    print("Text? \(data!)")
//                }
//                break
//            }
//            if provider.hasItemConformingToTypeIdentifier("com.adobe.pdf") { // was kind
//                provider.loadItem(forTypeIdentifier: "com.adobe.pdf", // public.item
//                                  options: nil) { data, error in
//                }
//            }
//            else if provider.hasItemConformingToTypeIdentifier("public.url") { // was kind
//                
//                provider.loadItem(forTypeIdentifier: "public.url",
//                                  options: nil) { data, error in
//                }
//            }
//            else if provider.hasItemConformingToTypeIdentifier("public.content") { // was kind
//                print("found a \(kind)")
//                provider.loadItem(forTypeIdentifier: "public.content", // public.item
//                                  options: nil) { data, error in
//                }
//            }
//            // loadItem can be used to extract different types of data from NSProvider object in attachements
////                provider.loadItem(forTypeIdentifier: "public.image"){ data, _ in
////                    // Load Image data from image URL
////                    if let url = data as? URL {
////                        if let imageData = try? Data(contentsOf: url) {
////                            // Load Image as UIImage from image data
////                            let uiimg = UIImage(data: imageData)!
////                            // Convert to SwiftUI Image
////                            let image = Image(uiImage: uiimg)
////                            // .. Do something with the Image
////                        }
////                    }
////                }
//        }
//    }
//    DispatchQueue.main.async {
//        let u = UIHostingController(
//            rootView: VStack { Text("Foo Bar")
//                Button("Save") {
//                    print("saved.")
//                }
//            }
//        )
//        u.view.frame = (self.view.bounds)
//        self.view.addSubview(u.view)
//        self.addChild(u)
//    }
//
//}
