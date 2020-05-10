//: [Previous](@previous)

//#-editable-code
let birdAction = Actions(running: .sequentially) {
    Fade(.out, duration: 0.1)
    Wait(forDuration: 0.1)
    Fade(.in, duration: 0.1)
//    Wait(forDuration: 0.5)
    Wait(forRandomDurationIn: 0.0 ... 0.1)
}.repeatForever()

let birdAction2 = Actions(running: .sequentially) {
    MoveBy(x: 200, duration: 1.0)
    Wait(forDuration: 2)
    MoveBy(x: -100, duration: 1.0)
    Wait(forDuration: 2)
}.repeatForever()

let game = Game()
    .showDebugStatistics()
    .appendingLevel(Level(name: "Hazy", birdAction: birdAction))
    .appendingLevel(
        Level(name: "Wind", birdAction: birdAction2)
            .skyColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
    )
game.runLevels()
//#-end-editable-code

//#-hidden-code
import Foundation
import SpriteKit
import PlaygroundSupport
import SwiftUI
//#-end-hidden-code

/*:
    Roses are `UIColor.red`,
    Violets are 🔵,
    Swift Playgrounds are rad,
    and so are you!
 */

//: [Next](@next)
