/**
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import SpriteKit
import GameplayKit

class GameScene: SKScene {
  
  // constants
  let waterMaxSpeed: CGFloat = 200
  let landMaxSpeed: CGFloat = 4000

  // if within threshold range of the target, car begins slowing
  let targetThreshold:CGFloat = 200

  var maxSpeed: CGFloat = 0
  var acceleration: CGFloat = 0
  
  // touch location
  var targetLocation: CGPoint = .zero
  
  // Scene Nodes
  var car:SKSpriteNode!

  override func didMove(to view: SKView) {
    loadSceneNodes()
    physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
    maxSpeed = landMaxSpeed
  }
  
  func loadSceneNodes() {
    guard let car = childNode(withName: "car") as? SKSpriteNode else {
      fatalError("Sprite Nodes not loaded")
    }
    self.car = car
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else { return }
    targetLocation = touch.location(in: self)
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else { return }
    targetLocation = touch.location(in: self)
  }
  
  
  override func update(_ currentTime: TimeInterval) {
  }
  
  override func didSimulatePhysics() {
    
    let offset = CGPoint(x: targetLocation.x - car.position.x,
                         y: targetLocation.y - car.position.y)
    let distance = sqrt(offset.x * offset.x + offset.y * offset.y)
    let carDirection = CGPoint(x:offset.x / distance,
                               y:offset.y / distance)
    let carVelocity = CGPoint(x: carDirection.x * acceleration,
                              y: carDirection.y * acceleration)
    
    car.physicsBody?.velocity = CGVector(dx: carVelocity.x, dy: carVelocity.y)
    
    if acceleration > 5 {
      car.zRotation = atan2(carVelocity.y, carVelocity.x)
    } 
    
    // update acceleration
    // car speeds up to maximum
    // if within threshold range of the target, car begins slowing
    // if maxSpeed has reduced due to different tiles,
    // may need to decelerate slowly to the new maxSpeed
    
    if distance < targetThreshold {
      let delta = targetThreshold - distance
      acceleration = acceleration * ((targetThreshold - delta)/targetThreshold)
      if acceleration < 2 {
        acceleration = 0
      }
    } else {
      if acceleration > maxSpeed {
        acceleration -= min(acceleration - maxSpeed, 80)
      }
      if acceleration < maxSpeed {
        acceleration += min(maxSpeed - acceleration, 40)
      }
    }

  }
}
