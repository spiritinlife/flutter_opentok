//
//  FlutterOpenTokSubscriberView.swift
//  flutter_opentok
//
//  Created by Konstantinos Arvanitakis on 22/1/21.
//

class FlutterOpenTokPublisherView: NSObject, FlutterPlatformView {
    private var controller: FlutterOpenTokController
    
    public init(controller: FlutterOpenTokController) {
        self.controller = controller
    }
    
    func view() -> UIView {
        return controller.publisherView
    }
}
