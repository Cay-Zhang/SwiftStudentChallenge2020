//: [Previous](@previous)
//: # Basics
/*:
 **Floppy Bird** is a game where you control a bird to avoid obstacles and arrive at the destination.
 
 In fact, the game itself doesn't require much explanation. All you do is tapping/clicking the screen to make the bird flap.
 
 Sounds easy, right? Run the code to show a plain game and try it yourself.
 
 If you see a black screen, just run it again.
 */
let sampleGame = Game {
    // ↓ Levels
    Level(name: "Plain and Boring") {
        // ↓ Map Components
        Pipes(10, constantInterval: 1, constantPipeGap: 150)
    }
    Level(name: "Plain and Boring, but Harder") {
        // ↓ Map Components
        Pipes(5, constantInterval: 1, constantPipeGap: 150)
        Pipes(10, constantInterval: 0.7, constantPipeGap: 125)
    }
}

sampleGame.runLevels()

/*:
 Observe the code above.
 
 Again, pretty self-explanatory stuff, just like you are describing a level to your friends.
 
 Try tweaking some values in the code and see if the result makes sense to you. If you find the level too hard for you, decrease `constantInterval` and increase `constantPipeGap`.
 
 ## Intro to a Time-based Map
 Maybe the only thing that you are worrying about is the `constantInterval` parameter in `Pipes`. Why do we define an time interval for `Pipes` instead of more intuitively, the distance between the pipes?
 
 Well, don't let your eyes fool you.
 The moving content on your screen tricks you to believe that the bird is moving horizontally through the immobile map, but the fact is the other way around.
 The pipes are spawned initially to the right of the scene and are moved to the left of it while the bird doesn't move horizontally at all!
 That's why it says "interval". You are directly controlling the **spawn interval** of the pipes instead of the **distance** among them.
 
 As you can see, you can arrange more than one `MapComponent` in a level. Where are they placed? Or "time-basedly", when are they spawned?
 
 A **MapComponent** can define its own "time span" (duration) and its time span starts immediately after the previous one.
 
 `Pipes` is the main map component in this game. It defines its duration as the sum of all the intervals for the pipes (for a constant interval, its duration would be `count` * `constantInterval`).
 
 Before learning about more map components, in the next page, you will familiarize yourself with the **Action system** which is used throughout the customization of this game.
 
 ## More about Difficulty
 There isn't a built-in difficulty scale available for you to tweak since this playground aims to offer more freedom in level design and encourage creativity and craziness. However, you can always design a difficulty adjustment system for yourself.
 */
//: [Next](@next)
