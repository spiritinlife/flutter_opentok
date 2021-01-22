//
//  FlutterOpenTokView.swift
//  flutter_opentok
//
//  Created by Genert Org on 22/08/2019.
//

import Foundation
import OpenTok
import os
import SnapKit

class FlutterOpenTokController: NSObject {
    var subscriberView: UIView!
    var publisherView: UIView!
    
    private let registrar: FlutterPluginRegistrar!
    private var channel: FlutterMethodChannel!
    
    // Publisher settings
    var publisherSettings: PublisherSettings?
    
    var screenHeight: Int?
    var screenWidth: Int?
    
    var enablePublisherVideo: Bool?
    
    /// Is audio switched to speaker
    fileprivate(set) var switchedToSpeaker: Bool = true
    
    /// Instance providing us VoIP
    fileprivate var provider: VoIPProvider!
    
    public func initPublisherView(frame: CGRect){
        publisherView = UIView(frame: frame)
        publisherView.isOpaque = false
        publisherView.backgroundColor = UIColor.black
    }
    
    public func initSubscriberView(frame: CGRect){
        subscriberView = UIView(frame: frame)
        subscriberView.isOpaque = false
        subscriberView.backgroundColor = UIColor.black
    }
    
    public init(registrar: FlutterPluginRegistrar) {
        let channelName = "plugins.indoor.solutions/opentok"
        
        self.registrar = registrar
        
        channel = FlutterMethodChannel(name: channelName, binaryMessenger: registrar.messenger())
        
        super.init()
    }
    
    deinit {
        if SwiftFlutterOpentokPlugin.loggingEnabled {
            print("[DEINIT] FlutterOpenTokController")
        }
    }
    
    fileprivate func configureAudioSession() {
        if SwiftFlutterOpentokPlugin.loggingEnabled {
            print("[FlutterOpenTokController] Configure audio session")
            print("[FlutterOpenTokController] Switched to speaker = \(switchedToSpeaker)")
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, options: [.mixWithOthers, .allowBluetooth])
        } catch {
            if SwiftFlutterOpentokPlugin.loggingEnabled {
                print("[FlutterOpenTokController] Session setCategory error: \(error)")
            }
        }
        
        do {
            try AVAudioSession.sharedInstance().setMode(switchedToSpeaker ? AVAudioSession.Mode.videoChat : AVAudioSession.Mode.voiceChat)
        } catch {
            if SwiftFlutterOpentokPlugin.loggingEnabled {
                print("[FlutterOpenTokController] Session setMode error: \(error)")
            }
        }
        
        do {
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(switchedToSpeaker ? .speaker : .none)
        } catch {
            if SwiftFlutterOpentokPlugin.loggingEnabled {
                print("[FlutterOpenTokController] Session overrideOutputAudioPort error: \(error)")
            }
        }
        
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            if SwiftFlutterOpentokPlugin.loggingEnabled {
                print("[FlutterOpenTokController] Session setActive error: \(error)")
            }
        }
    }
    
    fileprivate func closeAudioSession() {
        if SwiftFlutterOpentokPlugin.loggingEnabled {
            print("[FlutterOpenTokController] Close audio session")
        }
        
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            if SwiftFlutterOpentokPlugin.loggingEnabled {
                print("[FlutterOpenTokController] Session setActive error: \(error)")
            }
        }
    }
    
    /// Convenience getter for current video view based on provider implementation
    var subscriberVideoView: UIView? {
        if let openTokProvider = self.provider as? OpenTokVoIPImpl {
            return openTokProvider.subscriberView
        }
        return nil
    }
    
    var publisherVideoView: UIView? {
        if let openTokProvider = self.provider as? OpenTokVoIPImpl {
            return openTokProvider.publisherView
        }
        return nil
    }
    
    /**
     Create an instance of VoIPProvider. This is what implements VoIP
     for the application.
     */
    private func createProvider() {
        provider = OpenTokVoIPImpl(delegate: self, publisherSettings: publisherSettings)
    }
}

extension FlutterOpenTokController: FlutterViewControllerImpl {
    func setup() {
        // Create VoIP provider
        createProvider()
        
        // Listen for method calls from Dart.
        channel.setMethodCallHandler {
            [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            self?.onMethodCall(call: call, result: result)
        }
    }
    
    func onMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
        print("methodcallcalled")
        print(call.method)
        if call.method == "connect" {
            guard let args = call.arguments else {
                return
            }
            print(args)
            if let methodArgs = args as? [String: Any],
               let apiKey = methodArgs["apiKey"] as? String,
               let sessionId = methodArgs["sessionId"] as? String,
               let token = methodArgs["token"] as? String,
               let publisherArg = methodArgs["publisherSettings"] as? AnyObject{
                print(apiKey)
                provider?.connect(apiKey: apiKey, sessionId: sessionId, token: token)
//                do {
//                    let jsonDecoder = JSONDecoder()
//
//                    publisherSettings = try jsonDecoder.decode(PublisherSettings.self, from: publisherArg.data(using: .utf8)!)
//                } catch {
//                    if SwiftFlutterOpentokPlugin.loggingEnabled {
//                        print("OpenTok publisher settings error: \(error.localizedDescription)")
//                    }
//                }
                result(nil)
            } else {
                result("iOS could not extract flutter arguments in method: (create)")
            }
        } else if call.method == "destroy" {
            provider?.disconnect()
            result(nil)
        } else if call.method == "enablePublisherVideo" {
            provider?.enablePublisherVideo()
            result(nil)
        } else if call.method == "disablePublisherVideo" {
            provider?.disablePublisherVideo()
            result(nil)
        } else if call.method == "unmutePublisherAudio" {
            provider?.unmutePublisherAudio()
            result(nil)
        } else if call.method == "mutePublisherAudio" {
            provider?.mutePublisherAudio()
            result(nil)
        } else if call.method == "muteSubscriberAudio" {
            provider?.muteSubscriberAudio()
            result(nil)
        } else if call.method == "unmuteSubscriberAudio" {
            provider?.unmuteSubscriberAudio()
            result(nil)
        } else if call.method == "switchAudioToSpeaker" {
            switchAudioSessionToSpeaker()
            result(nil)
        } else if call.method == "switchAudioToReceiver" {
            switchAudioSessionToReceiver()
            result(nil)
        } else if call.method == "getSdkVersion" {
            result(OPENTOK_LIBRARY_VERSION)
        } else {
            result(FlutterMethodNotImplemented)
        }
    }
    
    func channelInvokeMethod(_ method: String, arguments: Any?) {
        channel.invokeMethod(method, arguments: arguments) {
            (result: Any?) -> Void in
            if let error = result as? FlutterError {
                if SwiftFlutterOpentokPlugin.loggingEnabled {
                    if #available(iOS 10.0, *) {
                        os_log("%@ failed: %@", type: .error, method, error.message!)
                    } else {
                        // Fallback on earlier versions
                    }
                }
            } else if FlutterMethodNotImplemented.isEqual(result) {
                if SwiftFlutterOpentokPlugin.loggingEnabled {
                    if #available(iOS 10.0, *) {
                        os_log("%@ not implemented", type: .error)
                    } else {
                        // Fallback on earlier versions
                    }
                }
            }
        }
    }
}

extension FlutterOpenTokController: VoIPProviderDelegate {
    func didCreateStream() {
        channelInvokeMethod("onCreateStream", arguments: nil)
    }
    
    func didCreatePublisherStream() {
        channelInvokeMethod("onCreatePublisherStream", arguments: nil)
        
        if let view = self.publisherVideoView {
            channelInvokeMethod("[onReceiveVideo", arguments: nil)
            
            publisherView.addSubview(view)
            
            view.backgroundColor = .black
            view.snp.makeConstraints { (make) -> Void in
                make.top.equalTo(publisherView)
                make.left.equalTo(publisherView)
                make.bottom.equalTo(publisherView)
                make.right.equalTo(publisherView)
            }
        }
    }
    
    func willConnect() {
        configureAudioSession()
        
        channelInvokeMethod("onWillConnect", arguments: nil)
        
        if let enablePublisherVideo = self.enablePublisherVideo {
            if enablePublisherVideo == true {
                let videoPermission = AVCaptureDevice.authorizationStatus(for: .video)
                let videoEnabled = (videoPermission == .authorized)
                
                provider?.isAudioOnly = !videoEnabled
            }
        }
    }
    
    func didConnect() {
        channelInvokeMethod("onSessionConnect", arguments: nil)
    }
    
    func didDisconnect() {
        closeAudioSession()
        
        channelInvokeMethod("onSessionDisconnect", arguments: nil)
    }
    
    func didReceiveVideo() {
        if SwiftFlutterOpentokPlugin.loggingEnabled {
            print("[FlutterOpenTokController] Receive video")
        }
        
        channelInvokeMethod("onReceiveVideo", arguments: nil)
        
        if let view = self.subscriberVideoView {
            channelInvokeMethod("[onReceiveVideo", arguments: nil)
            
            subscriberView.addSubview(view)
            
            view.backgroundColor = .black
            view.snp.makeConstraints { (make) -> Void in
                make.top.equalTo(subscriberView)
                make.left.equalTo(subscriberView)
                make.bottom.equalTo(subscriberView)
                make.right.equalTo(subscriberView)
            }
        }
    }
}

extension FlutterOpenTokController {
    func switchAudioSessionToSpeaker() {
        if SwiftFlutterOpentokPlugin.loggingEnabled {
            print(#function)
        }
        
        do {
            try AVAudioSession.sharedInstance().setMode(AVAudioSession.Mode.videoChat)
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
            switchedToSpeaker = true
        } catch {
            if SwiftFlutterOpentokPlugin.loggingEnabled {
                print("Session overrideOutputAudioPort error: \(error)")
            }
        }
    }
    
    func switchAudioSessionToReceiver() {
        if SwiftFlutterOpentokPlugin.loggingEnabled {
            print(#function)
        }
        
        do {
            try AVAudioSession.sharedInstance().setMode(AVAudioSession.Mode.voiceChat)
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSession.PortOverride.none)
            switchedToSpeaker = false
        } catch {
            if SwiftFlutterOpentokPlugin.loggingEnabled {
                print("Session overrideOutputAudioPort error: \(error)")
            }
        }
    }
}

struct PublisherSettings: Codable {
    var name: String?
    var audioTrack: Bool?
    var videoTrack: Bool?
    var audioBitrate: Int?
}
