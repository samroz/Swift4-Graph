//
//  WebServiceRequest.swift
//  Semiconductor app
//
//  Created by mac on 02/09/2018.
//  Copyright © 2018 mac. All rights reserved.
//

import Foundation

class WebserviceRequests {
    
    func getGraphData(didFinishParsing: @escaping (NSDictionary) -> Int){
        let graphdata = GetGraphData(didFinishParsingCallback: didFinishParsing)
        graphdata.getGraphData()
    }
}
