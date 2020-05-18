/*:
 # Features Showcase
 Here are some levels that I designed to show the capability and convenience of the tools I developed.
 
 Run all the code by clicking the **Execute Playground** button on the tool bar of the debug area. If you encounter a black screen, just rerun.
 
 If you feel it's too hard, set `isCheatModeOn` to `true`, rerun, and you are invincible!
 
 Rearrange/Comment out the levels the way you want to focus on specific levels. Observe the code and see how much you can understand without any documentation.
 */

let isCheatModeOn = false

let game = Game {
    Level(name: "Progressive Value Change") {
        Pipes(10)
            .progressivePipeGaps(from: 150, to: 100)
            .progressiveIntervals(from: 1.5, to: 0.75)
    }.cheat(isCheatModeOn)
    
    Level(name: "Pipe Actions") {
        Pipes(3, constantInterval: 1)
        Pipes(5, constantInterval: 0.8, constantPipeGap: 150)
            .customPipeActions { _ in
                Actions(running: .sequentially) {
                    Wiggle(y: 5, duration: 3)
                    Wait(forRandomDurationIn: 0.3 ... 1.0)
                    Wiggle(y: 10, duration: 3)
                }
            }
        Pipes(5)
            .customPipeActions { _ in
                MoveBy(y: .random(in: -75 ... 75), duration: 4)
            }
        Pipes(5)
            .customPipeActions { _ in
                Actions(running: .sequentially) {
                    Rotate(by: .degrees(.random(in: -40 ... 40)), duration: 2)
                    Rotate(by: .degrees(.random(in: -40 ... 40)), duration: 2)
                }
            }
    }.skyTint(#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)).cheat(isCheatModeOn)
    
    Level(name: "Bird Action: Wind") {
        Pipes(15)
            .progressivePipeGaps(from: 150, to: 100)
            .progressiveIntervals(from: 1.5, to: 0.75)
    }.birdAction {
        Actions(running: .sequentially) {
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
    }.skyTint(#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)).cheat(isCheatModeOn)
    
    Level(name: "Bird & Pipe Actions: Hazy") {
        Pipes(15)
            .progressivePipeGaps(from: 150, to: 100)
            .progressiveIntervals(from: 1.5, to: 0.75)
            .customPipeActions { _ in
                Actions(running: .sequentially) {
                    Fade(.out, duration: 0.5)
                    Wait(forRandomDurationIn: 0.5 ... 1.5)
                    Fade(.in, duration: 0.5)
                    Wait(forRandomDurationIn: 0.5 ... 1.5)
                }.repeatForever()
            }
    }.birdAction {
        Actions(running: .sequentially) {
            Fade(.out, duration: 0.5)
            Wait(forRandomDurationIn: 0.5 ... 1.5)
            Fade(.in, duration: 0.5)
            Wait(forRandomDurationIn: 0.5 ... 1.5)
        }.repeatForever()
    }.cheat(isCheatModeOn)
    
    Level(name: "Fields & Missiles") {
        GravityField(width: 1200, strength: 6)
        Wait(forDuration: 1)
        Pipes(8)
        NoiseField(width: 1200)
        Wait(forDuration: 1)
        Missiles(4)
        Pipes(8)
    }.cheat(isCheatModeOn)
    
    Level(name: "All of them!") {
        Pipes(8)
            .progressivePipeGaps(from: 150, to: 100)
            .progressiveIntervals(from: 1.5, to: 0.75)
        GravityField(width: 1200, strength: 6)
        Wait(forDuration: 1)
        Pipes(5, constantInterval: 1, constantPipeGap: 200)
            .customPipeActions { _ in
                Actions(running: .parallelly) {
                    Rotate(by: .degrees(.random(in: -60 ... 60)), duration: 4)
                    MoveBy(y: .random(in: -60 ... 60), duration: 4)
                }
            }
        Wait(forDuration: 1)
        NoiseField(width: 1200, strength: 0.07)
        Pipes(5, constantInterval: 1)
            .customPipeActions { pipeNumber in
                Actions(running: .sequentially) {
                    Fade(.out, duration: .random(in: 0.0 ... 0.2*pipeNumber))
                    Wait(forRandomDurationIn: 0.5 ... 1.5)
                    Fade(.in, duration: 0.2)
                    Wait(forRandomDurationIn: 0.5 ... 1.5)
                }.repeatForever()
            }
        Wait(forDuration: 1)
        Missiles(6)
        Pipes(15, pipeHeightScale: 2.0)
            .customIntervals { _ in
                .random(in: 0.5 ... 1.0)
            }
            .customPipeActions { _ in
                Actions(running: .sequentially) {
                    MoveBy(x: .random(in: -50 ... 50), duration: 2)
                    Wait(forRandomDurationIn: 0.3 ... 1.0)
                    MoveBy(y: .random(in: -50 ... 50), duration: 2)
                }
            }
    }.birdAction {
        Actions(running: .sequentially) {
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
    }.skyTint(#colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)).cheat(isCheatModeOn)
}

game.runLevels()

/*:
 * Tips:
 You have to rerun the page to restart all the levels after you've finished all of them.
*/
