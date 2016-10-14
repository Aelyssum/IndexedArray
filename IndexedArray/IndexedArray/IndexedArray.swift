//
//  IndexedArray.swift
//  IndexedArray
//
//  Created by Allan Evans on 2/1/15.
//  Copyright © 2015 Aelyssum Corp. All rights reserved.
//

import Foundation

class IndexedArray<Element: Hashable>: NSObject, Sequence {
    
    fileprivate var arrayOfElements = [Element]()
    fileprivate var indexOfElements = [Int: Int]()
    
    var count: Int {
        return arrayOfElements.count
    }
    
    var isEmpty: Bool {
        return arrayOfElements.count == 0
    }
    
    required override init() {
        super.init()
    }
    
    // MARK: Accessor methods
    
    var first: Element? {
        return arrayOfElements.first
    }
    
    var last: Element? {
        return arrayOfElements.last
    }

    subscript(index: Int) -> Element {
        assert(!self.isEmpty,
               "Attempign to access subscript of empty array"
        )
        assert(index >= 0 && index < self.count,
               "Index \(index) out of range 0...\(self.count-1)"
        )
        return self.arrayOfElements[index]
    }
    
    func elementAtIndex<H: Hashable>(_ index: H) -> Element? {
        if let thisIndex = self.indexOfElements[index.hashValue] {
            return self.arrayOfElements[thisIndex]
        } else {
            return nil
        }
    }
    
    // MARK: SequenceType methods
    
    func makeIterator() -> AnyIterator<Element> {
        // keep the index of the next element in the iteration
        var nextIndex = 0
        
        return AnyIterator<Element> {
            var returnValue: Element?
            if (nextIndex < self.arrayOfElements.count) {
                returnValue = self.arrayOfElements[nextIndex]
                nextIndex += 1
            }
            return returnValue
        }
    }

    // MARK: Add, modify, and delete methods
    
    func insert(_ element: Element) {
        if let thisIndex = self.indexOfElements[element.hashValue] {
            self.arrayOfElements[thisIndex] = element
        } else {
            self.indexOfElements[element.hashValue] = self.count
            self.arrayOfElements.append(element)
        }
    }
    
    func remove(_ element: Element) {
        if let thisIndex = self.indexOfElements[element.hashValue] {
            self.arrayOfElements.remove(at: thisIndex)
            self.indexOfElements[element.hashValue] = nil
            self.buildDictionary()
        }
    }
    
    func removeAtIndex<H: Hashable>(_ index: H) {
        if let thisIndex = self.indexOfElements[index.hashValue] {
            self.arrayOfElements.remove(at: thisIndex)
            self.indexOfElements[index.hashValue] = nil
            self.buildDictionary()
        }
    }
    
    func removeAll() {
        self.arrayOfElements.removeAll()
        self.indexOfElements.removeAll()
    }
    
    fileprivate func buildDictionary() {
        // Build Dictionary can only be called within another task executing on queue
        if !self.arrayOfElements.isEmpty {
            for index in 0...self.arrayOfElements.count-1 {
                self.indexOfElements[self.arrayOfElements[index].hashValue]=index
            }
        }
    }
    

    
    // MARK:  Functional methods
    
    func sorted(by handler: (_ first: Element, _ second: Element) -> Bool) -> Self {
        let returnArray = type(of: self).init()
        returnArray.arrayOfElements = self.arrayOfElements.sorted(by: handler)
        returnArray.buildDictionary()
        return returnArray
    }
    
    func filter(_ handler: (_ element: Element) -> Bool) -> Self {
        let returnArray = type(of: self).init()
        returnArray.arrayOfElements = self.arrayOfElements.filter(handler)
        returnArray.buildDictionary()
        return returnArray
    }
    
    func map<T>(_ transform: (Element) throws -> T) rethrows -> [T] {
        return try self.arrayOfElements.map(transform)
    }
    
    func reduce<T>(_ initial: T?, combine: (T?, Element) -> T?) -> T? {
        var returnVal: T?
        returnVal = self.arrayOfElements.reduce(initial, combine)
        return returnVal
    }
    
    func reduce<T>(_ initial: T, combine: (T, Element) throws -> T) rethrows -> T {
        var returnVal: T!
        returnVal = try self.arrayOfElements.reduce(initial, combine)
        return returnVal
    }
    
    var asArray: Array<Element> {
        return arrayOfElements
    }
    
}

