//
//  ViewController.swift
//  StepCounterDemo
//
//  Created by Sergio Herrera on 4/2/21.
//

import CoreMotion
import UIKit

class ViewController: UIViewController {
    // determine type of activity user doing at the moment
    let activityManager = CMMotionActivityManager()
    // retrieve pedometer related info for user
    let pedometer = CMPedometer()
    
    @IBOutlet var activityTypeLbl: UILabel!
    @IBOutlet var stepCountLbl: UILabel!
    @IBOutlet var startStopBtn: UIButton!
    var buttonStarted = false
    var currentSteps = 0
    var totalSteps = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        startStopBtn.layer.cornerRadius = 8
    }
    
    @IBAction func buttonPressed(_ sender: Any) {
        buttonStarted.toggle()
        // user opts to start tracking
        if buttonStarted {
            print("currently counting steps")
            startStopBtn.setTitle("Stop", for: .normal)
            startStopBtn.backgroundColor = UIColor.red
            startTracking()
            countSteps()
        }
        // user opts to stop counter
        else {
            print("paused counting")
            startStopBtn.setTitle("Start", for: .normal)
            startStopBtn.backgroundColor = UIColor.systemBlue
            stopTracking()
            self.activityTypeLbl.text = "Activity: None"
            self.totalSteps += self.currentSteps
            print("total steps = \(self.totalSteps) and previous steps = \(self.currentSteps)")
        }
    }
    
    func startTracking() {
        if CMMotionActivityManager.isActivityAvailable() {
            trackActivityType()
        } else {
            let activityNotAvailableMsg = "Activity type not available"
            activityTypeLbl.text = activityNotAvailableMsg
            print(activityNotAvailableMsg)
        }
        
        if CMPedometer.isStepCountingAvailable() {
            countSteps()
        } else {
            let stepsNotAvailableMsg = "Step count not available"
            stepCountLbl.text = stepsNotAvailableMsg
            print(stepsNotAvailableMsg)
        }
    }
    
    // stop tracking updates
    func stopTracking() {
        pedometer.stopUpdates()
        activityManager.stopActivityUpdates()
    }
    
    // count user's steps
    func countSteps() {
        // startUpdates() has "from" and "to" for time frame
        pedometer.startUpdates(from: Date()) {
            data, error in
            
            if error == nil {
                if let response = data {
                    DispatchQueue.main.async {
                        let steps = Int(response.numberOfSteps)
                        self.currentSteps = steps
                        print("Number of steps = \(self.totalSteps + self.currentSteps)")
                        self.stepCountLbl.text = "Steps: \(self.totalSteps + self.currentSteps)"
                    }
                }
            }
        }
    }
    
    // track user's current activity
    func trackActivityType() {
        // get updates from CMMotionActivityManager
        activityManager.startActivityUpdates(to: OperationQueue.main) {
            data in
            
            DispatchQueue.main.async {
                if let activity = data {
                    if activity.running {
                        print("running")
                        self.activityTypeLbl.text = "Activity: running"
                    } else if activity.walking {
                        print("walking")
                        self.activityTypeLbl.text = "Activity: walking"
                    } else if activity.stationary {
                        print("stationary")
                        self.activityTypeLbl.text = "Activity: stationary"
                    } else if activity.automotive {
                        print("automotive")
                        self.activityTypeLbl.text = "Activity: automotive"
                    }
                }
            }
        }
    }
}
