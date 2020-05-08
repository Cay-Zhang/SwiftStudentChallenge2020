//: [Previous](@previous)

import Foundation
import SpriteKit
import PlaygroundSupport
import SwiftUI

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

show(birdAction: birdAction2)

//: [Next](@next)
