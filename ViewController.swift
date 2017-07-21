//
//  ViewController.swift
//  ResumeProject
//
//  Created by john fletcher on 5/31/16.
//  Copyright © 2016 John Fletcher. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Firebase



class ViewController: UIViewController {
    
    var rider = [RiderOrDriver]()
    

    @IBOutlet var videoView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupView()
        
        let uref = FIRDatabase.database().reference().child("users")
        uref.observe(.value, with: { (snapshot) in
            
            self.rider = []
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                
                for snap in snapshots {
                    
                    
                    if let riderDictionary = snap.value as? Dictionary<String, AnyObject>{
                        
                        let rid = RiderOrDriver(uid: snap.key, dictionary: riderDictionary)
                        
                        self.rider.insert(rid , at: 0)
                    }
                }
                
            }
            
            
        })
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func setupView() {
        
        let path = URL(fileURLWithPath: Bundle.main.path(forResource: "appmovie1", ofType: "mov")!)
        
        let player = AVPlayer(url: path)
        
        let newLayer = AVPlayerLayer(player: player)
        newLayer.frame = self.videoView.frame
        self.videoView.layer.addSublayer(newLayer)
        newLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.greekRowTextCenter(self.videoView)
        player.play()
        player.actionAtItemEnd = AVPlayerActionAtItemEnd.none
        
        NotificationCenter.default.addObserver(self, selector: "videoDidPlayToEnd:", name: NSNotification.Name(rawValue: "AVPlayerItemDidPlayToEndTimeNotification"), object: player.currentItem)
        
    
        self.createGreekRowButtons(self.videoView)
        
        
    }
    
    
    
    func videoDidPlayToEnd(_ notification: Notification){
        
        
        let player: AVPlayerItem = notification.object as! AVPlayerItem
        player.seek(to: kCMTimeZero)
    }
    
    func greekRowTextCenter(_ containerView: UIView!){
        
        let half:CGFloat = 1.0 / 2.0
        
        let greekRowLabel = UILabel()
        greekRowLabel.text = "GroupRide"
        greekRowLabel.font = UIFont(name: "Apple Color Emoji", size: 65.0)
        greekRowLabel.backgroundColor = UIColor.clear
        greekRowLabel.textColor = UIColor.white
        greekRowLabel.sizeToFit()
        greekRowLabel.textAlignment = NSTextAlignment.center
        greekRowLabel.frame.origin.x = (containerView.frame.size.width - greekRowLabel.frame.size.width) * half
        greekRowLabel.frame.origin.y = (containerView.frame.size.height - greekRowLabel.frame.size.height) * half
        containerView.addSubview(greekRowLabel)
        
        
    }
    
    
    func createGreekRowButtons(_ containerView: UIView!){
        
        
        
        let margin:CGFloat = 5.0
        let middleSpacing:CGFloat = 7.5
        
        let signIn = UIButton()
        signIn.setTitle("SignIn", for: UIControlState())
        signIn.setTitleColor(UIColor.black, for: UIControlState())
        signIn.backgroundColor = UIColor.green
        signIn.frame.size.width = (((containerView.frame.size.width - signIn.frame.size.width) - (margin * 2)) / 2 - middleSpacing)
        signIn.frame.size.height = 35.0
        signIn.frame.origin.x = margin
        signIn.frame.origin.y = ((containerView.frame.size.height - signIn.frame.size.height) - 25)
        signIn.addTarget(self, action: "signInButtonPressed:", for: UIControlEvents.touchUpInside)
        containerView.addSubview(signIn)
        
        
        let register = UIButton()
        register.setTitle("Register", for: UIControlState())
        register.setTitleColor(UIColor.black, for: UIControlState())
        register.backgroundColor = UIColor.green
        register.frame.size.width = (((containerView.frame.size.width - register.frame.size.width) - (margin * 2)) / 2 - middleSpacing)
        register.frame.size.height = 35.0
        register.frame.origin.x = ((containerView.frame.size.width - register.frame.size.width) - margin)
        register.frame.origin.y = ((containerView.frame.size.height - register.frame.size.height) - 25)
        register.addTarget(self, action: "registerButtonPressed:", for: UIControlEvents.touchUpInside)
        containerView.addSubview(register)
        
        
    }
    
    


    func signInButtonPressed(_ sender: UIButton!){
        
        var dict = [String:String]()
        
        for data in rider {
            
            dict[data.uid] = data.isRider
            
        }
        
       
    
    
        if FIRAuth.auth()?.currentUser != nil{
        
            
            if let riderValue = dict[(FIRAuth.auth()?.currentUser?.uid)!] {
                if riderValue == "true"{
            
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let riderVC = storyboard.instantiateViewController(withIdentifier: "riderSID")
            
            self.present(riderVC, animated: true, completion: nil)
            
                }else{
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let driverVC = storyboard.instantiateViewController(withIdentifier: "DriverVC")
                    
                    let navigationController = UINavigationController(rootViewController: driverVC)
                    self.present(navigationController, animated: true, completion: nil)

                    
                }
            }
        }else{
        
    
    
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let signUpVC: SignUpViewController = storyboard.instantiateViewController(withIdentifier: "signUp") as! SignUpViewController
        signUpVC.buttonTitlePressed = sender.titleLabel?.text
        
        let navigationController = UINavigationController(rootViewController: signUpVC)
        
        self.present(navigationController, animated: true, completion: nil)
        
        
        print("Let's Sign In")
        
        
        }
    }




    
    func registerButtonPressed(_ sender: UIButton!){
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let signUpVC: SignUpViewController = storyBoard.instantiateViewController(withIdentifier: "signUp") as! SignUpViewController
        
        let navigationController = UINavigationController(rootViewController: signUpVC)
        
        
        self.present(navigationController, animated: true, completion: nil)
        
        print("Register")
        
        
    }
    
    
    
    
    
}

