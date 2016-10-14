//
//  IndexedArray.swift
//  IndexedArray
//
//  Created by Allan Evans on 2/1/15.
//  Copyright © 2015 Aelyssum Corp. All rights reserved.
//

import Foundation

class IndexedArray<Element: Hashable>: NSObject, SequenceType {
    
    private var arrayOfElements = [Element]()
    private var indexOfElements = [Int: Int]()
    
    var count: Int {
        return arrayOfElements.count
    }
    
    var isEmpty: Bool {
        return arrayOfElements.count == 0
    }
    
    // MARK: Thread safety
    
    var queue: dispatch_queue_t
    
    required override init() {
        super.init()
        queue = dispatch_queue_create(label: "com.Aelyssum.IndexedArray.\(NSDate())", DISPATCH_QUEUE_CONCURRENT)
    }
    
    // MARK: Accessor methods
    
    var first: Element? {
        return queue.dispatch_sync() {
            return arrayOfElements.first
        }
    }
    
    var last: Element? {
        return queue.dispatch_sync() {
            return arrayOfElements.last
        }
    }

    subscript(index: Int) -> Element {
        assert(!self.isEmpty,
               "Attempign to access subscript of empty array"
        )
        assert(index >= 0 && index < self.count,
               "Index \(index) out of range 0...\(self.count-1)"
        )
        return queue.dispatch_sync() {
            return self.arrayOfElements[index]
        }
    }
    
    func elementAtIndex<H: Hashable>(index: H) -> Element? {
        return queue.dispatch_sync() {
            if let thisIndex = self.indexOfElements[index.hashValue] {
                return self.arrayOfElements[thisIndex]
            } else {
                return nil
            }
        }
    }
    
    // MARK: SequenceType methods
    
    func generate() -> AnyGenerator<Element> {
        // keep the index of the next element in the iteration
        var nextIndex = 0
        
        return queue.dispatch_sync() {
            return AnyGenerator<Element> {
                var returnValue: Element?
                if (nextIndex < self.arrayOfElements.count) {
                    returnValue = self.arrayOfElements[nextIndex]
                    nextIndex += 1
                }
                return returnValue
            }
        }
    }

    // MARK: Add, modify, and delete methods
    
    func insert(element: Element) {
        queue.dispatch_asyncbarrier() {
            if let thisIndex = self.indexOfElements[element.hashValue] {
                self.arrayOfElements[thisIndex] = element
            } else {
                self.indexOfElements[element.hashValue] = self.count
                self.arrayOfElements.append(element)
            }
        }
    }
    
    func remove(element: Element) {
        queue.dispatch_asyncbarrier() {
            if let thisIndex = self.indexOfElements[element.hashValue] {
                self.arrayOfElements.removeAtIndex(thisIndex)
                self.indexOfElements[element.hashValue] = nil
                self.buildDictionary()
            }
        }
    }
    
    func removeAtIndex<H: Hashable>(index: H) {
        queue.dispatch_asyncbarrier() {
            if let thisIndex = self.indexOfElements[index.hashValue] {
                self.arrayOfElements.removeAtIndex(thisIndex)
                self.indexOfElements[index.hashValue] = nil
                self.buildDictionary()
            }
        }
    }
    
    func removeAll() {
        queue.dispatch_asyncbarrier() {
            self.arrayOfElements.removeAll()
            self.indexOfElements.removeAll()
        }
    }
    
    private func buildDictionary() {
        // Build Dictionary can only be called within another task executing on queue
        if !self.arrayOfElements.isEmpty {
            for index in 0...self.arrayOfElements.count-1 {
                self.indexOfElements[self.arrayOfElements[index].hashValue]=index
            }
        }
    }
    

    
    // MARK:  Functional methods
    
    func sort(handler: (first: Element, second: Element) -> Bool) -> Self {
        let returnArray = self.dynamicType.init()
        dispatch_sync(queue) {
            returnArray.arrayOfElements = self.arrayOfElements.sort(handler)
        }
        returnArray.buildDictionary()
        return returnArray
    }
    
    func filter(handler: (element: Element) -> Bool) -> Self {
        let returnArray = self.dynamicType.init()
        dispatch_sync(queue) {
            returnArray.arrayOfElements = self.arrayOfElements.filter(handler)
        }
        returnArray.buildDictionary()
        return returnArray
    }
    
    func map<T>(transform: Element throws -> T) rethrows -> [T] {
        return dispatch_sync(queue) {
            try self.arrayOfElements.map(transform)
        }
    }
    
    func reduce<T>(initial: T?, combine: (T?, Element) -> T?) -> T? {
        return dispatch_sync(queue) {
            return self.arrayOfElements.reduce(initial, combine: combine)
        }
    }
    
    func reduce<T>(initial: T, combine: (T, Element) throws -> T) rethrows -> T {
        return dispatch_sync(queue) {
            return try self.arrayOfElements.reduce(initial, combine: combine)
        }
    }
    
    var asArray: Array<Element> {
        return dispatch_sync(queue) {
            return arrayOfElements
        }
    }
    
}

