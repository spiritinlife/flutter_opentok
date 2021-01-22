//
//  VoIPProviderDelegateProtocol.swift
//  flutter_opentok
//
//  Created by Konstantinos Arvanitakis on 22/1/21.
//

import Foundation

public protocol VoIPProviderDelegate {
    func willConnect()
    func didConnect()
    func didDisconnect()
    func didReceiveVideo()
    func didCreateStream()
    func didCreatePublisherStream()
}
