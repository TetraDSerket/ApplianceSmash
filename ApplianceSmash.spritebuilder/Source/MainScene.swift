import Foundation

class MainScene: CCNode
{
    func startButtonPressed()
    {
        let gameplayScene = CCBReader.loadAsScene("Gameplay")
        let transition = CCTransition(fadeWithDuration: 0.8)
        CCDirector.sharedDirector().presentScene(gameplayScene, withTransition: transition)
    }
}
