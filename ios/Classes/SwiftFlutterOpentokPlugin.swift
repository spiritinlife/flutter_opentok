import Flutter
import UIKit

public class SwiftFlutterOpentokPlugin: NSObject, FlutterPlugin {
    public static var loggingEnabled: Bool = false
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let openTokSubscriberViewFactory = FlutterOpenTokSubscriberViewFactory(registrar: registrar)
        
        let openTokPublisherViewFactory = FlutterOpenTokPublisherViewFactory(registrar: registrar)
        
        registrar.register(openTokSubscriberViewFactory as FlutterPlatformViewFactory, withId: "OPENTOK_SUBSCRIBER_VIEW")
        
        registrar.register(openTokPublisherViewFactory as FlutterPlatformViewFactory, withId: "OPENTOK_PUBLISHER_VIEW")
        
        let openTokViewFactory = FlutterOpenTokViewFactory(registrar: registrar)
        
        registrar.register(openTokViewFactory as FlutterPlatformViewFactory, withId: "OpenTokRendererView")
    }
}
