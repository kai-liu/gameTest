//
//  ViewController.swift
//  gameTest
//
//  Created by Aigo on 16/3/25.
//  Copyright © 2016年 Aigo. All rights reserved.
//

import UIKit
import AVFoundation

let UD = NSUserDefaults.standardUserDefaults()

func UD_SET(udValue: NSInteger, udKey: String) {
    UD.setInteger(udValue, forKey: udKey)
    UD.synchronize()
}

func UD_GET(udKey: String)-> NSInteger? {
    return UD.objectForKey(udKey) as? NSInteger
}

func MIN(a a: NSInteger, b: NSInteger)-> NSInteger {
    return a>b ? b : a
}

class ViewController: UIViewController {
    
    var btnFirst : UIButton! = nil
    var toStart : Bool = true
    var timer : NSTimer! = nil
    var timeInterval : NSInteger = 0
    var column : NSInteger = 0
    var row : NSInteger = 0
    var currentLevel : NSInteger = 1
    var completeTips = "🙇恭 喜 通 关🙇\n\n想要啥\n\n买 买 买"
    
    @IBOutlet weak var bestScore: UILabel!
    @IBOutlet weak var useTime: UILabel!
    @IBOutlet weak var lbCurrentLevel: UILabel!
    @IBOutlet weak var btnChooseDiff: UIButton!
    @IBOutlet weak var btnReStart: UIButton!
    
    var touch : AVAudioPlayer?
    var remove : AVAudioPlayer?
    var error : AVAudioPlayer?
    var clock : AVAudioPlayer?
    var GO : AVAudioPlayer?
    var BGMusic : AVAudioPlayer?
    var success : AVAudioPlayer?
    var lose : AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = UIColor.blackColor()
        useTime.text = String(timeInterval)
        if (UD_GET("lastLevel") != nil ) {
            currentLevel = UD_GET("lastLevel")!
        }
        self.configButtons(currentLevel)
        if let BGMusic = self.playAudio("BGMusic") {
            self.BGMusic = BGMusic
            self.BGMusic?.numberOfLoops = -1
        }
        BGMusic!.play()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.restartAction(_:)), name: UIApplicationWillEnterForegroundNotification, object: nil)
    }
    
    func configImageArray(level : NSInteger) -> NSMutableArray {
        
        var imageCount : NSInteger = 0
        
        switch level {
        case 1:
            imageCount = 8
            break
        case 2:
            imageCount = 20
            break
        case 3:
            imageCount = 50
            break
        case 4:
            imageCount = 80
            break
        case 5:
            imageCount = 103
            break
        default:
            break
        }
        
        let imageArray = NSMutableArray()
        for _ in 0...column*row/2-1 {
            let indexRandom = NSInteger(arc4random())%imageCount+1
            let imageStr = String(indexRandom)
            imageArray.addObject(imageStr)
            imageArray.addObject(imageStr)
        }
        
        return imageArray
    }

    func configButtons(level: NSInteger) {
        UD_SET(level, udKey: "lastLevel")
        self.flipAnimationForView(self.lbCurrentLevel)
        lbCurrentLevel.text = "Level  " + String(level)
        switch level {
        case 1:
            column = 5
            row = 6
            break
        case 2:
            column = 6
            row = 8
            break
        case 3:
            column = 6
            row = 10
            break
        case 4:
            column = 7
            row = 10
            break
        case 5:
            column = 7
            row = 12
            break
        default:
            break
        }
        let tipLabel = UILabel(frame: self.view.bounds)
        tipLabel.backgroundColor = UIColor.clearColor()
        tipLabel.alpha = 0
        tipLabel.text = "第 " + String(level) + " 关"
        tipLabel.textColor = UIColor.whiteColor()
        tipLabel.textAlignment = .Center
        tipLabel.font = UIFont.boldSystemFontOfSize(40)
        self.view.addSubview(tipLabel)
        self.flipAnimationForView(self.bestScore)
        if UD_GET(String(currentLevel)) != nil {
            bestScore.text = String(UD_GET(String(currentLevel))!) + " s"
        } else {
            bestScore.text = "0 s"
        }
        UIView.animateWithDuration(2, animations: {
            tipLabel.alpha = 1
            }) { (finish) in
                if finish {
                    
                    if let GO = self.playAudio("GO") {
                        self.GO = GO
                    }
                    self.GO?.play()

                    tipLabel.removeFromSuperview()
                    
                    let buttonWidth = (CGRectGetWidth(self.view.bounds)-40)/CGFloat(self.column)
                    let imageArray = self.configImageArray(level)
                    
                    for i in 0...self.column-1 {
                        for j in 0...self.row-1 {
                            let imgButton = UIButton(frame: CGRectMake(20+CGFloat(i)*buttonWidth, 0, buttonWidth, buttonWidth))
                            let indexRandom = NSInteger(arc4random()) % imageArray.count
                            let imageStr = imageArray[indexRandom] as! String
                            imgButton.setImage(UIImage(named:  imageStr), forState: .Normal)
                            imageArray.removeObjectAtIndex(indexRandom)
                            imgButton.tag = NSInteger(imageStr)!
                            imgButton.addTarget(self, action: #selector(ViewController.buttonAction(_:)), forControlEvents: .TouchUpInside)
                            self.view.addSubview(imgButton)
                            
                            UIView.animateWithDuration(0.5, delay: 0.1, usingSpringWithDamping: 0.6, initialSpringVelocity: 3, options: .CurveEaseOut, animations: {
                                imgButton.frame = CGRectMake(20+CGFloat(i)*buttonWidth, 30+CGFloat(j)*buttonWidth, buttonWidth, buttonWidth)
                                }, completion: { (finish) in
                                    if finish {
                                        self.btnReStart.enabled = true
                                        self.btnChooseDiff.enabled = true
                                        if self.toStart {
                                            self.toStart = false
                                            self.timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(self.timerAction), userInfo: nil, repeats: true)
                                        }
                                    }
                            })
                        }
                    }
                }
        }
    }
    
    func buttonAction(button : UIButton) {
        
        if btnFirst==nil {
            btnFirst = button
            btnFirst.enabled = false
            btnFirst.layer.borderColor = UIColor.whiteColor().CGColor
            btnFirst.layer.borderWidth = 2
            if let touch = self.playAudio("touch") {
                self.touch = touch
            }
            touch!.play()
        } else {
            
            if btnFirst.tag == button.tag {
                
                btnFirst.removeFromSuperview()
                button.removeFromSuperview()
                btnFirst = nil
                if let remove = self.playAudio("remove") {
                    self.remove = remove
                }
                remove!.play()
                if self.view.subviews.count==8 {
                    
                    clock?.stop()
                    timer.invalidate()
                    timer = nil
                    if bestScore.text == "0 s" {
                        UD_SET(NSInteger(useTime.text!)!, udKey: String(currentLevel))
                    } else {
                        let lastScore : NSInteger =  UD_GET(String(currentLevel))!
                        let betterScore = MIN(a: lastScore, b: NSInteger(useTime.text!)!)
                        UD_SET(NSInteger(betterScore), udKey: String(currentLevel))
                    }
                    self.flipAnimationForView(self.bestScore)
                    bestScore.text = String(UD_GET(String(currentLevel))!) + " s"
                    currentLevel += 1
                    if currentLevel == 6 {
                        if let success = self.playAudio("success") {
                            self.success = success
                        }
                        success?.play()
                        currentLevel -= 1
                        let tipLabel = UILabel(frame: CGRectMake(0, 0, self.view.bounds.size.width, 400))
                        tipLabel.center = self.view.center
                        tipLabel.backgroundColor = UIColor.clearColor()
                        tipLabel.text = completeTips
                        tipLabel.numberOfLines = 0
                        tipLabel.textColor = UIColor.whiteColor()
                        tipLabel.textAlignment = .Center
                        tipLabel.font = UIFont.boldSystemFontOfSize(30)
                        self.view.addSubview(tipLabel)
                        return
                    }
                    self.restartAction(self)
                }
            } else {
                btnFirst.layer.borderWidth = 0
                btnFirst.enabled = true
                btnFirst = nil
                if let error = self.playAudio("error") {
                    self.error = error
                }
                error!.play()
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            }
        }
    }
    
    func timerAction() {
        timeInterval += 1
        self.flipAnimationForView(self.useTime)
        useTime.text = String(timeInterval)
        if timeInterval == currentLevel * 15 - 3 {
            useTime.textColor = UIColor.redColor()
            useTime.font = UIFont.boldSystemFontOfSize(60)
            if let clock = self.playAudio("clock") {
                self.clock = clock
                self.clock?.numberOfLoops = 2
            }
            clock?.play()
        }
        if timeInterval == currentLevel * 15 {
            
            if timer != nil {
                timer.invalidate()
                timer = nil
            }
            if let lose = self.playAudio("lose") {
                self.lose = lose
            }
            lose!.play()
            self.view.userInteractionEnabled = false
            let tipLabel = UILabel(frame: CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height))
            tipLabel.alpha = 0.5
            tipLabel.backgroundColor = UIColor(white: 0, alpha: 0.9)
            tipLabel.text = "😭oh no过关失败~"
            tipLabel.textColor = UIColor.whiteColor()
            tipLabel.textAlignment = .Center
            tipLabel.font = UIFont.boldSystemFontOfSize(30)
            self.view.addSubview(tipLabel)
            btnReStart.enabled = false
            btnChooseDiff.enabled = false
            
            UIView.animateWithDuration(4, animations: {
                tipLabel.alpha = 1
            }) { (finish) in
                if finish {
                    tipLabel.removeFromSuperview()
                    self.restartAction(self)
                }
            }
        }
    }
    
    func actionSheetArray() -> NSMutableArray {
        return ["取消", "第1关", "第2关", "第3关", "第4关", "第5关", "重置"]
    }
    
    @IBAction func chooseDifficulty(sender: AnyObject) {
        
        let actionSheet = UIAlertController(title: "请宝宝选择难度(共5关)(づ｡◕ ‿‿ ◕｡)づ", message: "嗯哼,宝宝只能选择已经通过的难度☺️", preferredStyle: .ActionSheet)
        for i in 0...6 {
            let title = (UD_GET(String(i)) != nil) ? String(self.actionSheetArray()[i])+"   "+String(UD_GET(String(i))!)+"s" : String(self.actionSheetArray()[i])
            
            let action = UIAlertAction(title: title, style: i==0 ? .Cancel : .Default, handler: { (action) in
                if i != 0 && i != 6 {
                    self.currentLevel = i
                    self.restartAction(self)
                } else if (i == 6) {
                    let appDomain = NSBundle.mainBundle().bundleIdentifier
                    UD.removePersistentDomainForName(appDomain!)
                    self.currentLevel = 1
                    self.restartAction(self)
                }
            })
            actionSheet.addAction(action)
            if UD_GET(String(i)) == nil && i != 0 {
                break
            }
        }
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }

    @IBAction func restartAction(sender: AnyObject) {
        self.view.userInteractionEnabled = true
        btnReStart.enabled = false
        btnChooseDiff.enabled = false
        btnFirst = nil
        useTime.textColor = UIColor.whiteColor()
        useTime.font = UIFont.systemFontOfSize(55)
        clock?.stop()
    
        for view in self.view.subviews {
            if !view.isKindOfClass(UILabel) {
                if view.isKindOfClass(UIButton) {
                    let button = view as! UIButton
                    if !(button.titleLabel?.text == "重新开始") &&
                       !(button.titleLabel?.text == "选关") {
                        button.removeFromSuperview()
                    }
                }
            } else {
                let label = view as! UILabel
                if label.text == completeTips || label.text == "😭oh no过关失败~" || label.text == "第 " + String(currentLevel) + " 关" {
                    label.removeFromSuperview()
                } 
            }
        }
        self.configButtons(currentLevel)
        if timer != nil {
            timer.invalidate()
            timer = nil
        }
        toStart = true
        timeInterval = 0
        useTime.text = String(timeInterval)
    }
    
    func playAudio(audioName: String) -> AVAudioPlayer? {
        let pathStr = NSBundle.mainBundle().pathForResource(audioName, ofType: "mp3")
        let url = NSURL(fileURLWithPath: pathStr!)
        
        var audioPlayer:AVAudioPlayer?
        do {
            try audioPlayer = AVAudioPlayer(contentsOfURL: url)
                audioPlayer?.volume = 0.5
                audioPlayer?.enableRate = true
            } catch {
                print("Player not available")
        }
        
        return audioPlayer
    }
    
    func flipAnimationForView(view: UIView) {
        UIView.animateWithDuration(0.5) {
            UIView.setAnimationCurve(.EaseInOut)
            UIView.setAnimationTransition(.FlipFromLeft, forView: view, cache: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}