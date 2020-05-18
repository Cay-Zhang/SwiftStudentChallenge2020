//: [Previous](@previous)
/*:
 # Map Components
 ## Wait
 Given the time-based nature of both maps in this game and the Action system, it is no wonder that `Wait` can be also be a `MapComponent`.
 It is used to insert an idle time span/delay.
 If you insert a `Wait` between two `Pipes`, it'll create external distance between them.
 ## Pipes
 `Pipes` are the major elements of a map and thus are highly customizable.
 
 `init(_ count: Int, constantInterval = 1.0, constantPipeGap = 150.0, topPipe = defaultTopPipeImage, bottomPipe = defaultBottomPipeImage)`
 
 ### Customized Intervals
 You can customize the intervals after each pipe pair using a closure or a helper method.
 For example, if you want the distance after each pipe pair to get gradually smaller.
 */
let count = 10
let (fromInterval, toInterval) = (1.5, 0.5)
let step = (toInterval - fromInterval) / Double(count - 1)
let pipesWithCustomIntervals = Pipes(count)
    .customIntervals { pipeNumber in  // pipeNumber: 1st, 2nd, 3rd pipe -> 1, 2, 3
        fromInterval + step * Double(pipeNumber - 1)
    }
/*:
 Actually, since it is very common to require a progressive change in the value, this function is built-in.
 The code above is the same as calling:
 */
Pipes(count).progressiveIntervals(from: fromInterval, to: toInterval)
//: The duration of `Pipes` is the sum of all the intervals:
(1...count).lazy.map(pipesWithCustomIntervals.intervals).reduce(0, +)
/*:
 ### Customized Pipe Gaps
 You can also customize the height of the pipe gap for each pipe pair.
 Use the code below to generate pipes with random pipe gaps.
 */
let pipesWithCustomPipeGaps = pipesWithCustomIntervals
    .customPipeGaps { _ in .random(in: 100 ... 150) }
//: Progressive change is also supported:
Pipes(10).progressivePipeGaps(from: 150, to: 100)
/*:
 ### Customized Pipe Actions
 You can define a unique action for each pipe pair.
 The following code moves each pipe pair vertically by a random distance.
 */
Pipes(15)
    .customPipeActions { _ in
        MoveBy(y: .random(in: -75 ... 75), duration: 5)
    }
/*:
 * Experiment: This is an important customization point to express your creativity. You can find some inspiration from the last page.
 ## Field
 A `Field` is a map component with a duration of 0 (instant) that spawns a physics field with a specific width and strength. The field only affects the movement of the bird. You can also customize the particle effects of the fields.
 
 Currently, two kinds of `Field`s are supported:
 */
GravityField(width: 800, strength: 6)  // applies a downward gravity force to the bird
NoiseField(width: 800, strength: 0.07)  // applies a randomized acceleration to the bird
    .applyingParticleEffects(fileNamed: "NoiseField")  // custom particle effect

/*:
 ## Missiles
 A `Missiles` is a map component with a duration of 0 (instant) that launches a specific number of missiles randomly above the ground moving horizontally.
 */
Missiles(5)
/*:
 Now that you know most of the customization points of this game, you can start to create your own crazy level!
 
 But before that, let's run the example code below and see what those customizations will look like in the actual game.
 */

let game = Game {
    Level(name: "Intervals & Pipe Gaps") {
        pipesWithCustomPipeGaps
    }
    Level(name: "Customized Pipe Actions") {
        Pipes(15)
            .customPipeActions { _ in
                Rotate(by: .degrees(.random(in: -60 ... 60)), duration: 4)
            }
    }
    Level(name: "Fields and Missiles") {
        GravityField(width: 1200, strength: 6)
        Wait(forDuration: 1)
        Pipes(5)
        Wait(forDuration: 1)
        NoiseField(width: 1200, strength: 0.07)
        Wait(forDuration: 1)
        Missiles(5)
        Pipes(10)
    }
}

game.runLevels()
//: [Next](@next)
