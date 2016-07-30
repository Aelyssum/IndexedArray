//: Playground - noun: a place where people can play

import UIKit

class RowClass {
    var UUID: String
    
    init(UUID: String) {
        self.UUID = UUID
    }
}

class IndexedArray<R: RowClass> {
    var arrayOfElements = [R]()
    var indexOfElements = [String: Int]()
    var count: Int {
        return arrayOfElements.count
    }
    
    subscript(index: Int) -> R {
        return arrayOfElements[index]
    }
    
    func insert(element: R) {
        if let index = indexOfElements[element.UUID] {
            arrayOfElements[index] = element
        } else {
            indexOfElements[element.UUID] = count
            arrayOfElements.append(element)
        }
    }
    
    func elementAtIndex(UUID: String) -> R? {
        if let index = indexOfElements[UUID] {
            return self[index]
        } else {
            return nil
        }
    }
}

class Player: RowClass {
    var name: String
    var number: Int
    var teamID: String
    
    init(name: String, number: Int, teamID: String, UUID: String) {
        self.name = name
        self.number = number
        self.teamID = teamID
        super.init(UUID: UUID)
    }
    
}


var players = IndexedArray<Player>()
let stephenCurry = Player(name: "Stephen Curry",
                          number: 30,
                          teamID: "GSW", UUID: "0001")
players.insert(stephenCurry)
let thisPlayer = players[0]
print("Name: \(thisPlayer.name), UUID: \(thisPlayer.UUID)")

let thisPlayerAgain = players.elementAtIndex("0001")!
print("Name: \(thisPlayerAgain.name), UUID: \(thisPlayerAgain.UUID)")

