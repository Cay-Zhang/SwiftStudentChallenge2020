//: [Previous](@previous)

import SpriteKit
import Combine



let game = Game {
    Level(name: "Easy") {
        Pipes(5)
    }
}

game.runLevels()
//: [Next](@next)

//game = Game()
