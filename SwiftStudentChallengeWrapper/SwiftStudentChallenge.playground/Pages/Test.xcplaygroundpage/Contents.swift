//: [Previous](@previous)

import SpriteKit
import Combine



let game = Game {
    Level(name: "Normal") {
        Pipes(15)
            .progressivePipeGaps(from: 200, to: 100)
            .customPipeActions { pipeNumber in
                let randomDistance = CGFloat.random(in: -75 ... 75)
                return MoveBy(y: randomDistance, duration: 5)
//                return Rotate(by: .degrees(Double(randomDistance)), duration: 4)
            }
    }
}

game.runLevels()
//: [Next](@next)

