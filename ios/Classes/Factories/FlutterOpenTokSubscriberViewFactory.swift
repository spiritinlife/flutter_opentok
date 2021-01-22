//
//  FlutterOpenTokViewFactory.swift
//  flutter_opentok
//
//  Created by Genert Org on 23/08/2019.
//

import Foundation

class FlutterOpenTokSubscriberViewFactory: NSObject, FlutterPlatformViewFactory {
    private let registrar: FlutterPluginRegistrar!
    private let controller: FlutterOpenTokController
    
    init(registrar: FlutterPluginRegistrar, controller: FlutterOpenTokController) {
        self.registrar = registrar
        self.controller = controller
    }
    
    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
    
    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        // Setup logging.
        if let arguments = args as? [String: Any],
           let loggingEnabled = arguments["loggingEnabled"] as? Bool {
            SwiftFlutterOpentokPlugin.loggingEnabled = loggingEnabled
        }
        
        controller.initSubscriberView(frame: frame)
        
        return FlutterOpenTokSubscriberView(controller: controller)
    }
}
