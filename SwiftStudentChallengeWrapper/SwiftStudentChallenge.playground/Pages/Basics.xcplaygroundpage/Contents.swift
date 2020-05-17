//: [Previous](@previous)
//: # Basics
/*:
 **Floppy Bird** is a game where you control a bird to avoid obstacles and arrive at the destination.
 
 In fact, the game itself doesn't require much explanation. All you do is tapping/clicking the screen to make the bird flap.
 
 Sounds easy, right? Run the code to show a plain level and try it yourself.
 */
let sampleGame = Game {
    Level(name: "Plain and Boring") {
        Pipes(30, constantInterval: 1, constantPipeGap: 150)
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
 
 ## More about Difficulty
 There isn't a built-in difficulty scale available for you to tweak since this playground aims to offer more freedom in level design and encourage creativity and craziness. However, you can always design a difficulty adjustment system for yourself.
 */
//: [Next](@next)
