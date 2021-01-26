//
//  VoIPProviderProtocol.swift
//  flutter_opentok
//
//  Created by Konstantinos Arvanitakis on 22/1/21.
//

import Foundation

public protocol VoIPProvider {
    /// Whether VoIP connection has been established.
    var isConnected: Bool { get }

    // Set whether publisher has audio or not.
    var isAudioOnly: Bool { get set }

    func connect(apiKey: String, sessionId: String, token: String)
    func disconnect()

    func mutePublisherAudio()
    func unmutePublisherAudio()

    func muteSubscriberAudio()
    func unmuteSubscriberAudio()

    func enablePublisherVideo()
    func disablePublisherVideo()
    
    func changeCameraPosition()
    func sendMessage(message: String, messageType: String)
}
