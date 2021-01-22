//
//  FlutterControllerProtocol.swift
//  flutter_opentok
//
//  Created by Konstantinos Arvanitakis on 22/1/21.
//

import Foundation

public protocol FlutterViewControllerImpl {
    func setup()
    
    func onMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult)
    
    func channelInvokeMethod(_ method: String, arguments: Any?)
}
