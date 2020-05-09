//: [Previous](@previous)

import SpriteKit
import Combine



var game = Game()
game.levels = [Int](1...10).map(String.init).map(Level.init)
game.runLevels()
//: [Next](@next)

//game = Game()


