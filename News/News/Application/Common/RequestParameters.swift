//
//  RequestParameters.swift
//  News
//
//  Created by Yury Khadatovich on 25.01.22.
//

import Foundation

struct RequestParameters {
    static let question = "q="
    static let country = "country="
    static func from(hoursAgo: Double) -> String {
        "from=" + DateManager.shared.getDate(hoursAgo: hoursAgo)
    }
    static func from(daysAgo: Double) -> String {
        "from=" + DateManager.shared.getDate(daysAgo: daysAgo)
    }
    static func to() -> String {
        "to=" + DateManager.shared.getCurrentDate()
    }
    
}

enum Countries: String {
    case ae, ar, at, au
    case be, bg, br
    case ca, ch, cn, co, cu, cz
    case de
    case eg
    case fr
    case gb, gr
    case hk, hu
    case id, ie, il, `in`, it
    case jp
    case kr
    case lt, lv
    case ma, mx, my
    case ng, nl, no, nz
    case ph, pl, pt
    case ro, rs, ru
    case sa, se, sg, si, sk
    case th, tr, tw
    case ua, us
    case ve
    case za
}
