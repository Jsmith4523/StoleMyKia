//
//  StoleMyKiaApp.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/11/23.
//

import SwiftUI
import Firebase


//MARK: DEVELOPER MESSAGE

/*
    This applciation is dedicated to my 2017 Hyundai Elantra SE that I named "Silvey"
 
    I'm exhausted of this 'Kia Boyz' group stealing peoples cars and trashing them later on. For my car which I wanted to keep forever,
    I am annoyed by what happened to it and cops not holding these theives up to a proper ass whoopings and punishment.
    From the video I took of me approaching the thieves stealing my car and making the dumbass decision to share it with the world, I am also annoyed by social media for making fun of my pain you can hear in the video.
    Calling me words such as a p-word, that I deseved to have my car stolen for the way I acted and I should've fought and/or shoot the people who were taking my car, these people I despise of as they have nothing better to do but bring down a person who just had their car stolen and now more financial stress from their parent having a medical accident in their vehicle and totaling it a month before having my vehicle stolen. A big "Thank you" and "F*ck you" to those instagram users, and the DMV Media site (not killmoe) for not removing the video as I requested it. Your words fueled me during the creation of this application. I guess you all serve some purpose of my life you f*cking assholes.
    I hope if you all see this one day have a f*cking stroke trying to read basic SwiftUI syntax and eat sh*t from seeing the amount of files that are in this project for y'all's ungrateful and stealing content asses. deinit this rant, b*tch.
 
    I have a fucking Nissan Altima now.
 
    Only people who served little purpose in life find a car stealing TikTok challenging amusing.
 
    This application, while may not do it's job possibly, is my give back to people who take pride in being roll model citizens.
    This application is not a replacement for acutal authority and law; yet more of a missing-child-on-a-milk-carton type application.
    But the child isn't Asian, it's KDM.
    My car which I once loved is gone. Yeah it may just be metal and glass, but I absolutely loved that car.
    Hoping one day I can find it in the future and fix it up. It may honestly become junkyard parts TBH.
    So here's my solution to the problem. RIP Silvey. Thanks...
 
    -- Jaylen Smith (Developer, March 22, 2023 at 12:41AM)
 */

@main
struct StoleMyKiaApp: App {
    
    @StateObject private var notificationModel = NotificationViewModel()
    @StateObject private var reportsModel = ReportsViewModel()
    
    @UIApplicationDelegateAdaptor (AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            Tab()
                .sheet(isPresented: $reportsModel.isShowingSelectedReportView) {
                    SelectedReportDetailView()
                }
                .environmentObject(reportsModel)
                .environmentObject(notificationModel)
        }
    }
}


class AppDelegate: UIScene, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        UINavigationBar.appearance().barTintColor = .white
        
        return true
    }
}
