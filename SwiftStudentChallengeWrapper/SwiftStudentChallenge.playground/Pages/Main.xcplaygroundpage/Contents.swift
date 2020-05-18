//#-editable-code

let isCheatModeOn = true

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

let game = Game {
    Level(name: "Wiggle") {
        Pipes(5, constantInterval: 1)
        Pipes(10, constantInterval: 0.8)
            .customPipeGaps { _ in 150 }
            .customPipeActions { _ in
                Actions(running: .sequentially) {
                    Wiggle(y: 5, duration: 3)
                    Wait(forRandomDurationIn: 0.3 ... 1.0)
                    Wiggle(y: 10, duration: 3)
                }
            }
        }.skyTint(#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)).cheat(isCheatModeOn)
    
    Level(name: "Hazy") {
        GravityField(width: 1200, strength: 6)
            .applyingParticleEffects(fileNamed: "GravityField")
        Wait(forDuration: 1)
        Pipes(5, constantInterval: 1)
        Wait(forDuration: 1)
        NoiseField(width: 1200, strength: 0.07)
            .applyingParticleEffects(fileNamed: "NoiseField")
        Wait(forDuration: 1)
        Missiles(6)
        Pipes(15, pipeHeightScale: 2.0)
            .progressiveIntervals(from: 1.5, to: 0.5)
            .customPipeActions { _ in
                Actions(running: .sequentially) {
                    MoveBy(y: 100, duration: 2)
                    Wait(forRandomDurationIn: 0.3 ... 1.0)
                    MoveBy(y: -100, duration: 2)
                }
            }
        }.skyTint(#colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)).cheat(isCheatModeOn)

    Level(name: "Wind") {
        Pipes(30, constantInterval: 1)
    }.birdAction(birdAction2)
        .skyTint(#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)).cheat(isCheatModeOn)
}.showDebugStatistics()

game.runLevels()

let game2 = Game {
    Level(name: "Test") {
        Pipes(15)
    }
}
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
