//: Playground - noun: a place where people can play

import UIKit

class IndexedArray<R: Hashable> {
    var arrayOfElements = [R]()
    var indexOfElements = [Int: Int]()
    var count: Int {
        return arrayOfElements.count
    }
    
    subscript(index: Int) -> R {
        return arrayOfElements[index]
    }
    
    func insert(element: R) {
        if let index = indexOfElements[element.hashValue] {
            arrayOfElements[index] = element
        } else {
            indexOfElements[element.hashValue] = count
            arrayOfElements.append(element)
        }
    }
    
    func elementAtIndex<H: Hashable>(index: H) -> R? {
        if let index = indexOfElements[index.hashValue] {
            return self[index]
        } else {
            return nil
        }
    }
}

func == (left: Player, right: Player) -> Bool {
    return left.UUID == right.UUID
}

class Player: Hashable {
    var name: String
    var number: Int
    var teamID: String
    var UUID: NSUUID
    
    init(name: String, number: Int, teamID: String) {
        self.name = name
        self.number = number
        self.teamID = teamID
        UUID = NSUUID()
    }
    
    var hashValue: Int {
        return UUID.hashValue
    }
}


var players = IndexedArray<Player>()
let stephenCurry = Player(name: "Stephen Curry",
                          number: 30,
                          teamID: "GSW")
players.insert(stephenCurry)
let thisPlayer = players[0]
print("Name: \(thisPlayer.name), UUID: \(thisPlayer.UUID.UUIDString)")

let thisPlayerAgain = players.elementAtIndex(stephenCurry.UUID)!
print("Name: \(thisPlayerAgain.name), UUID: \(thisPlayerAgain.UUID.UUIDString)")

