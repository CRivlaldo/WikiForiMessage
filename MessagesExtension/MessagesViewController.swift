//
//  MessagesViewController.swift
//  MessagesExtension
//
//  Created by Vladimir Vlasov on 05.10.16.
//  Copyright © 2016 Sofa Technologies. All rights reserved.
//

import UIKit
import Messages

class MessagesViewController: MSMessagesAppViewController, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var searchField: UITextField?
    @IBOutlet weak var textView: UITextView?
    @IBOutlet weak var searchButton: UIButton?
    @IBOutlet weak var spinner: UIActivityIndicatorView?
    @IBOutlet weak var searchButtonWidth: NSLayoutConstraint?
    @IBOutlet weak var searchFieldToSearchButtonDistance: NSLayoutConstraint?
    @IBOutlet weak var textViewToSearchFieldDistance: NSLayoutConstraint?

    @IBAction public func pasteAndSearch() {
        
        let searchText = UIPasteboard.general.string
        self.searchField?.text = searchText
        
        self.searchInfo(searchText)
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        self.searchInfo(searchField?.text)
        
        return true
    }
    
    func searchInfo(_ text: String?) {
        
        guard let trimmedText = text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return
        }
        
        if trimmedText.characters.count == 0 {
            return
        }
        
        self.startSpinner()
        
        WikiHelper.fetchInfo(topic: trimmedText) { (info, error) in
            DispatchQueue.main.async {
                self.spinner?.stopAnimating()
                
                if error != nil {
                    self.textView?.text = self.errorDescription(error!)
                } else {
                    self.textView?.attributedText = info?.attributedString()
                }
            }
        }
    }
    
    func startSpinner() {
        self.view.bringSubview(toFront: self.spinner!)
        self.spinner?.isHidden = false
        self.spinner?.startAnimating()
    }
    
    func errorDescription(_ error: WikiHelper.WikiHelperError!) -> String! {
        switch error! {
        case .ConnectionError:
            return "Please, check your Internet connection..."
        case .NothingWasFound:
            return "Sorry, but nothing has been found..."
        default:
            return "Something went wrong..."
        }
    }
    
    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        self.searchField?.isEnabled = (presentationStyle == .expanded)
    }
    
    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        
        switch presentationStyle {
        case .compact:
            self.searchButton?.isHidden = false
            self.searchField?.placeholder = "Copy text to the clipboard & press \"Paste\""
            self.searchField?.isEnabled = false
            self.searchButtonWidth?.constant = 47
            self.searchFieldToSearchButtonDistance?.constant = 8
            self.textViewToSearchFieldDistance?.constant = 8
        default:
            self.searchButton?.isHidden = true
            self.searchField?.placeholder = "Enter your search request"
            self.searchField?.isEnabled = true
            self.searchButtonWidth?.constant = 0
            self.searchFieldToSearchButtonDistance?.constant = 0
            self.textViewToSearchFieldDistance?.constant = -82
        }
    }

}
