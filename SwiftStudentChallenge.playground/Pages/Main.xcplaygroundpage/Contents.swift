//#-editable-code
let birdAction = Actions(running: .sequentially) {
    Fade(.out, duration: 0.1)
    Wait(forDuration: 0.1)
    Fade(.in, duration: 0.1)
//    Wait(forDuration: 0.5)
    Wait(forRandomDurationIn: 0.0 ... 0.1)
}.repeatForever()

let birdAction2 = Actions(running: .sequentially) {
    Wait(forRandomDurationIn: 1 ... 2)
    Colorize(#colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1), duration: 0.2, colorBlendFactor: 0.7)
    Decolorize(duration: 0.2)
    Colorize(#colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1), duration: 0.2, colorBlendFactor: 0.4)
    MoveBy(x: 200, duration: 5.0)
    Decolorize(duration: 0.2)
    Wait(forRandomDurationIn: 1 ... 2)
    Colorize(#colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1), duration: 0.2, colorBlendFactor: 0.7)
    Decolorize(duration: 0.2)
    Colorize(#colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1), duration: 0.2, colorBlendFactor: 0.4)
    MoveBy(x: -200, duration: 5.0)
    Decolorize(duration: 0.2)
}.repeatForever()

let game = Game()
    .showDebugStatistics()
    .appendingLevel {
        Level(name: "Hazy")
            .pipesCount(50)
            .birdAction(birdAction)
    }
    .appendingLevel {
        Level(name: "Wind")
            .birdAction(birdAction2)
            .pipesCount(20)
            .skyColor(#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1))
    }
    
    
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
