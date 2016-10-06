//
//  WikiHelper.swift
//  iWiki
//
//  Created by Vladimir Vlasov on 05.10.16.
//  Copyright © 2016 Sofa Technologies. All rights reserved.
//

import UIKit

class WikiInfo: NSObject {
    let title: String!
    let info: String!
    let url: String!
    
    init(title: String!, info: String!, url: String!) {
        self.title = title
        self.info = info
        self.url = url
        
        super.init()        
    }
    
    func attributedString() -> NSAttributedString! {
        let str = NSMutableAttributedString(string: self.title)
        str.addAttribute(NSLinkAttributeName, value: self.url, range: NSMakeRange(0, str.length))
        
        str.append(NSAttributedString(string: "\n\n\(self.info!)"))
        
        let font = UIFont.systemFont(ofSize: 14)
        str.addAttribute(NSFontAttributeName, value: font, range: NSMakeRange(0, str.length))
        
        return str
    }
}

class WikiHelper: NSObject {
    
    static let userAgent = "iNerd/1.0; vladvlasov.ios@gmail.com"
    
    static let requestTemplate = "https://en.wikipedia.org/w/api.php?action=opensearch&search=%@&limit=1&format=json"
    
    typealias Payload = [String: AnyObject]
    
    enum WikiHelperError: Error {
        case ConnectionError
        case ParsingError
        case InvalidResponse
        case NothingWasFound
    }
    
    static public func fetchInfo(topic: String!, completionHandler: @escaping (WikiInfo?, WikiHelperError?) -> Swift.Void) {
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = ["Api-User-Agent": userAgent];
        
        let session = URLSession(configuration: config)
        
        let escapedSearchString = topic.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)!
        let url = URL(string: String(format: requestTemplate, escapedSearchString))!
        
        let request = URLRequest(url: url)
        
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            if error != nil {
                completionHandler(nil, WikiHelperError.ConnectionError)
            } else {
                var json: Array<AnyObject>!
                
                do {                    
                    json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions()) as? Array<AnyObject>
                    
                    guard let titleResults = (json[1] as? Array<String>),
                        let infoResults =  (json[2] as? Array<String>),
                        let linkResults = (json[3] as? Array<String>)
                        else {
                            completionHandler(nil, WikiHelperError.ParsingError )
                            return
                    }
                    
                    if (titleResults.count > 0) && (infoResults.count > 0) && (linkResults.count > 0)  {
                        let wikiInfo = WikiInfo(title: titleResults[0], info: infoResults[0], url: linkResults[0])
                        completionHandler(wikiInfo, nil)
                    } else {
                        completionHandler(nil, WikiHelperError.NothingWasFound )
                    }
                } catch {
                    completionHandler(nil, WikiHelperError.InvalidResponse )
                }
            }
        }
        
        dataTask.resume()
    }
}
