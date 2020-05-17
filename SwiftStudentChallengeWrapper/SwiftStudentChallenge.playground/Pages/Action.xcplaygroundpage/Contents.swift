//: [Previous](@previous)
//: # The Action System
/*:
 Run all code on the page by clicking *Execute Playground* button on the debug area tool bar and see what happens. Describe what the bird is doing.
 
 Oh no! Invisible bird!
 
 Do we need to write a bunch of imperative code to hide/show the bird and create some timers to make it repeat forever?
 
 Well, the `Action` turns out to be just like a text description.
 */

let birdAction: Action = Actions(running: .sequentially) {
    Fade(.out, duration: 0.5)
    Wait(forRandomDurationIn: 0.5 ... 1.5)
    Fade(.in, duration: 0.5)
    Wait(forRandomDurationIn: 0.5 ... 1.5)
}.repeatForever()

/*:
 An `Action` can apply effects to its target. Here is a list of most of the actions supported:
 
 ### Grouping
 `Actions` is a special action that groups several actions together. You can specify the way its sub-actions are executed (sequentially or parallelly).
 
     Actions(running: .sequentially/.parallelly) {
        action1
        action2
     }
 
 ### Movement & Transform
 - `MoveBy(x:y:duration:)`
 - `Wiggle(amplitude:duration:)`
 - `Rotate(by:duration:)` (counterclockwise)
 - `Scale(to:duration:)`
 
 ### Opacity & Color
 - `Fade(.in/.out, duration:)`
 - `Colorize(_:duration:colorBlendFactor:)` (`colorBlendFactor` is a number from 0 to 1 indicating how much the color is blended in the texture of the target)
 - `Decolorize()`
 
 ### Time
 - `Wait(forDuration:)`
 - `Wait(forRandomDurationIn:)` (takes a closed range of `TimeInterval` as its parameter)
 
 ### Repetition
 If you want an action to repeat, attach the following to the end of the action you want to repeat:
 
 - `.repeat(_:)`
 - `.repeatForever()`
 
 */


let game = Game {
    Level(name: "Bird Action") {
        Pipes(30, constantInterval: 1, constantPipeGap: 150)
    }.birdAction(birdAction)
    // ↑ The defined bird action is attached to the level
}

game.runLevels()

/*:
 `birdAction` is then attached to the level using its `birdAction` property. The target for this action is the bird, meaning that only the bird will be affected by the instructions defined in your action.
 
 Now, you can try to implement some bird actions for yourself!
 
 For example, try moving the bird horizontally and observe the effect. You'll find a implementation of this on the last page.
 */

//: [Next](@next)
