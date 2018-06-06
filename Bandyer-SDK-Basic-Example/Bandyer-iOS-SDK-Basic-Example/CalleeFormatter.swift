// Copyright © 2018 Bandyer. All rights reserved.
// See LICENSE.txt for licensing information

import Foundation
import BandyerCommunicationCenter

class CalleeFormatter {
    
    static func formatCallee(call: BCXCall?) -> String {
        
        var message = ""
        
        if (call?.isIncoming())! {
            
            message.append(printingDetailForUser(partecipant: (call?.participants.caller)!) + " is calling")
            
            for (index,partecipant) in (call?.participants.callees)!.filter({ (partecipant: BCXCallParticipant) -> Bool in
                return !(partecipant.user.alias==call?.participants.caller.user.alias)
            }).enumerated() {
                message.append(index==0 ? ": " : ",")
                message.append(printingDetailForUser(partecipant: partecipant))
            }
            
        } else {
            
            message.append("You are calling: ")
            
            for (index,partecipant) in (call?.participants.callees)!.filter({ (partecipant: BCXCallParticipant) -> Bool in
                return !(partecipant.user.alias==BandyerCommunicationCenter.instance().callClient.user?.alias)
            }).enumerated() {
                message.append(index==0 ? ": " : "")
                message.append(printingDetailForUser(partecipant: partecipant))
            }
            
        }
        
        return message
        
    }
    
    static private func printingDetailForUser(partecipant: BCXCallParticipant) -> String {
        if (partecipant.user.alias==BandyerCommunicationCenter.instance().callClient.user?.alias) {
            return "you"
        } else {
            return partecipant.user.firstName! + " " + partecipant.user.lastName!
        }
    }
    
}
