//
//  ViewController.swift
//  fIreSample
//
//  Created by YAMAMOTOHIROKI on 2016/03/06.
//  Copyright © 2016年 YAMAMOTOHIROKI. All rights reserved.
//

import UIKit
import Firebase
import JSQMessagesViewController

class ViewController: JSQMessagesViewController {
    var rootRef: Firebase!
    var messageRef: Firebase!
    var messages = [JSQMessage]()
    var outgoingBubbleImageView: JSQMessagesBubbleImage!
    var incomingBubbleImageView: JSQMessagesBubbleImage!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rootRef = Firebase(url: "https://[YOUR_APPNAME].firebaseio.com/")
        let factory = JSQMessagesBubbleImageFactory()
        outgoingBubbleImageView = factory.outgoingMessagesBubbleImageWithColor(
            UIColor.jsq_messageBubbleBlueColor())
        incomingBubbleImageView = factory.incomingMessagesBubbleImageWithColor(
            UIColor.jsq_messageBubbleGreenColor())
    
        self.senderId = "2"
        self.senderDisplayName = "いちろう"
        
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSizeZero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
        
        messageRef = rootRef.childByAppendingPath("messages")
        messageRef.observeEventType(.ChildAdded) { (snapshot: FDataSnapshot!) in
            if snapshot.exists() {
                let id = snapshot.value["sender_id"] as! Int
                let text = snapshot.value["body"] as! String
                let name = snapshot.value["sender_name"] as! String
                let message = JSQMessage(senderId: String(id), displayName: name, text: text)
                self.messages.append(message)
                self.finishReceivingMessage()
            }
        }
        

        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return messages[indexPath.row]
    }
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        
        let postRef = messageRef.childByAutoId()
        let post1 = [
            "sender_id": 2,
            "sender_name": "いちろう",
            "timestamp": [ ".sv": "timestamp" ],
            "body" : text
        ]
        postRef.setValue(post1)
        finishSendingMessage()
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!,
        messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
            let message = messages[indexPath.item]
            if message.senderId == senderId {
                return outgoingBubbleImageView
            }
            return incomingBubbleImageView
    }    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        messageRef.removeAllObservers()
    }
}

