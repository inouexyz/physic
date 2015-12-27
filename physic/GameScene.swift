//
//  GameScene.swift
//  physic
//
//  Created by ginga on 2015/11/23.
//  Copyright (c) 2015年 ginga. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation

class GameScene: SKScene {
    
    let randomSource = GKARC4RandomSource()
    var mistakeNo = 0
    
    let msgLabel = SKLabelNode(fontNamed: "HirakakuProN-W6")
    var msg:String = "仲間はずれをタップしよう"
    let msgLabel2 = SKLabelNode(fontNamed: "HirakakuProN-W6")
    var msg2:String = ""
    
    let ballMax = 15
    var ballList:[SKShapeNode] = []
    
    let correct = ["間", "水", "刀", "猫", "巳", "祝", "休", "塊", "人", "光", "上", "狼", "怒"]
    let mistake = ["闇", "氷", "刃", "描", "己", "呪", "体", "魂", "入", "米", "止", "娘", "努"]
    var questionNo = 0
    var cnt = 0
    
    var player:[AVAudioPlayer] = [] // 複数の音を使うので配列にする
    
    override func didMoveToView(view: SKView) {
        
        // 物理シミュレーション
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame) // 空間は画面サイズ
        // 反発力
        self.physicsBody?.restitution = 1.1
        // 摩擦力
//        self.physicsBody?.friction = 0.5
        
        // 背景とラベルの設定
        self.backgroundColor = UIColor(red: 0.1, green: 0.4, blue: 0.9, alpha: 1.0)
        msgLabel.text = msg
        msgLabel.fontSize = 42
        msgLabel.fontColor = UIColor(red: 0.1, green: 0.8, blue: 0.9, alpha: 1.0)
        msgLabel.position = CGPoint(x: 375, y: 1250)
        self.addChild(msgLabel)
        msgLabel2.text = msg2
        msgLabel2.fontSize = 42
        msgLabel2.fontColor = UIColor(red: 0.9, green: 0.9, blue: 0.1, alpha: 1.0)
        msgLabel2.position = CGPoint(x: 375, y: 1200)
        self.addChild(msgLabel2)
        
        newQuestion()
        
        // プレイヤー生成
        player.append(makeAudioPlayer("coin05.mp3")!)
        player.append(makeAudioPlayer("blip01.mp3")!)
    }
    
    func newQuestion() {
        
        // 問題番号を決める
        questionNo = randomSource.nextIntWithUpperBound(correct.count)
        // 間違い番号を決める
        mistakeNo = randomSource.nextIntWithUpperBound(ballMax)
        
        // ボールの配列
        ballList = []
        
        // ballMax個のボールを作る
        for loopID in 0..<ballMax {
            
            // ボールの生成
            let ball = SKShapeNode(circleOfRadius: 50)
            ball.fillColor = UIColor.whiteColor()
 //           ball.position = CGPoint(x:loopID * 100 + 125, y: 1100)
            
            // シーンに表示
            self.addChild(ball)
            // ボールの配列に追加
            ballList.append(ball)
            
            // ボールの中のラベル
            let kanji = SKLabelNode(fontNamed: "HirakakuProN-W6")
            
            // 間違い番号でなければ
            if loopID != mistakeNo {
                // ラベルに正解の漢字を表示
                kanji.text = correct[questionNo]
            // 間違い番号だったら
            } else {
                // ラベルに間違いの漢字を表示
                kanji.text = mistake[questionNo]
            }
            
            // 漢字の設定
            kanji.fontSize = 70
            kanji.fontColor = UIColor.blueColor()
            kanji.position = CGPoint(x: 0, y: -25)
            ball.addChild(kanji)
            
            // アクションの設定（物理なし）
/*
            let action1 = SKAction.moveToY(1450, duration: 0)
            let wait1 = SKAction.waitForDuration(1.0, withRange: 2.0)
            
            let randomSec = Double(randomSource.nextIntWithUpperBound(30)) / 10.0 + 3.0
            let action2 = SKAction.moveToY(-100, duration: randomSec)
            
            let actionS = SKAction.sequence([action1, wait1, action2])
            let actionR = SKAction.repeatActionForever(actionS)
            ball.runAction(actionR)
*/
            // 物理シミュレーション用
            // 表示位置
            let wx = randomSource.nextIntWithUpperBound(440) + 150
            let wy = randomSource.nextIntWithUpperBound(200) + 1100
            ball.position = CGPoint(x: wx, y: wy)
            ball.physicsBody = SKPhysicsBody(circleOfRadius: 50) // 物理シミュレーション上の大きさ
            // 反発力
            ball.physicsBody?.restitution = 1.1
            // 回転
            let angle = CGFloat(randomSource.nextUniform() * 6.0)
            ball.zRotation = angle
            
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {

        for touch in touches {
            let location = touch.locationInNode(self)
            let touchNodes = self.nodesAtPoint(location)
            
            for tNode in touchNodes {
                
                for loopID in 0..<ballMax {
                    if tNode == ballList[loopID] {
//print("ボール\(loopID)をタッチしました")
                        answerCheck(loopID)
                        break
                    }
                }
            }
        }
    }
   
    func answerCheck(No:Int) {
        
        if No == mistakeNo {
            msg = "「\(mistake[questionNo])」を発見！(∩´∀｀)∩ﾜｰｲ"
            cnt++
            if cnt > 1 {
                msg2 = "\(cnt)回連続で成功中！"
            }
            player[0].play()
        } else {
            msg = "残念！( ；∀；)"
            cnt = 0
            msg2 = ""
            player[1].play()
        }
        
        msgLabel.text = msg
        msgLabel2.text = msg2
        
        for loopID in 0..<ballMax {
            ballList[loopID].removeFromParent()
        }
        newQuestion()
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    func makeAudioPlayer(res:String) -> AVAudioPlayer? {
        let path = NSBundle.mainBundle().pathForResource(res, ofType: "")
        let url = NSURL.fileURLWithPath(path!)
        
        do {
            return try AVAudioPlayer(contentsOfURL: url)
        } catch _ {
            return nil
        }
    }
}
