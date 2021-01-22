import Flutter
import UIKit

public class SwiftFlutterOpentokPlugin: NSObject, FlutterPlugin {
    public static var loggingEnabled: Bool = false
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let controller = FlutterOpenTokController(registrar: registrar)
        controller.setup()
        
        let openTokSubscriberViewFactory = FlutterOpenTokSubscriberViewFactory(registrar: registrar, controller: controller)
        
        let openTokPublisherViewFactory = FlutterOpenTokPublisherViewFactory(registrar: registrar, controller: controller)
        
        registrar.register(openTokSubscriberViewFactory as FlutterPlatformViewFactory, withId: "OPENTOK_SUBSCRIBER_VIEW")
        
        registrar.register(openTokPublisherViewFactory as FlutterPlatformViewFactory, withId: "OPENTOK_PUBLISHER_VIEW")
    }
}
