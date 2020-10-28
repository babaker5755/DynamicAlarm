//
//  SoundManager.swift
//  Dynamic
//
//  Created by Brandon Baker on 5/10/20.
//  Copyright © 2020 Brandon Baker. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class SoundManager {
    
    static var instance = SoundManager()
    
    var preview: AVAudioPlayer?
    
    init() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback,
                                                            mode: .default,
                                                            options: [.duckOthers, .allowAirPlay])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch(let error) {
            print(error.localizedDescription)
        }
    }
    
    func isPlaying() -> Bool {
        return preview?.isPlaying ?? false
    }
    
    func stopSound() {
        preview?.stop()
    }
    
    func playSound(alarm: Alarm, volume: Float) {
        
        let sound = alarm.sound
        MPVolumeView.setVolume(volume)
        let path = Bundle.main.path(forResource: sound.rawValue, ofType:nil)!
        let url = URL(fileURLWithPath: path)
        
        do {
            preview = try AVAudioPlayer(contentsOf: url)
            preview?.volume = 1.0
            preview?.play()
        } catch {
            print("couldn't load file :(")
        }
    }

}
extension MPVolumeView {
  static func setVolume(_ volume: Float) {
    let volumeView = MPVolumeView()
    let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
      slider?.value = volume
    }
  }
}
