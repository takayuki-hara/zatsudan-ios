//
//  ViewController.swift
//  Zatsudan
//
//  Created by TakayukiHARA on 2016/05/29.
//  Copyright © 2016年 Hispot Co., LTD. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class ViewController: JSQMessagesViewController {

    // MARK: - Properties
    var messages = [JSQMessage]()
    var incomingBubble: JSQMessagesBubbleImage!
    var outgoingBubble: JSQMessagesBubbleImage!
    var incomingAvatar: JSQMessagesAvatarImage!
    var outgoingAvatar: JSQMessagesAvatarImage!
    var mode = "dialog" // dialog | srtr
    var context = ""

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        //自分のsenderId, senderDisokayNameを設定
        self.senderId = "you"
        self.senderDisplayName = "you"
        
        //吹き出しの設定
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        self.incomingBubble = bubbleFactory.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
        self.outgoingBubble = bubbleFactory.outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleGreenColor())
        
        //アバターの設定
        self.incomingAvatar = JSQMessagesAvatarImageFactory.avatarImageWithImage(R.image.apiIcon()!, diameter: 64)
        self.outgoingAvatar = JSQMessagesAvatarImageFactory.avatarImageWithImage(R.image.youIcon()!, diameter: 64)

        //初期化
        AuthApiKey.initializeAuth("6e2f54636b655364647a6f6d524644424b6e4f50504e665a517772333376324d354e6f4c4e514a59307744")
        self.context = randomString(12)
        print(self.context)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Private Methods

    //Sendボタンが押された時に呼ばれる
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        
        //新しいメッセージデータを追加する
        let message = JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text)
        self.messages.append(message)
        
        //メッセジの送信処理を完了する(画面上にメッセージが表示される)
        self.finishReceivingMessageAnimated(true)

        //対話メッセージを要求する
        self.requestMessage(text)
    }

    //アイテムごとに参照するメッセージデータを返す
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return self.messages[indexPath.item]
    }
    
    //アイテムごとのMessageBubble(背景)を返す
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = self.messages[indexPath.item]
        if message.senderId == self.senderId {
            return self.outgoingBubble
        }
        return self.incomingBubble
    }
    
    //アイテムごとにアバター画像を返す
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        let message = self.messages[indexPath.item]
        if message.senderId == self.senderId {
            return self.outgoingAvatar
        }
        return self.incomingAvatar
    }
    
    //アイテムの総数を返す
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    //対話メッセージを要求する
    func requestMessage(text: String) {
        let dialogue = Dialogue()
        let param = DialogueRequestParam()
        param.utt = text
        param.mode = self.mode
        param.context = self.context

//        //DialogueErrorクラスがx86_64にないためコメント
//        let sendError =
        dialogue.request(param,
            onComplete: { result in
                let message = JSQMessage(senderId: "api", displayName: "api", text: result.utt)
                self.messages.append(message)
                self.finishReceivingMessageAnimated(true)
                self.mode = result.mode
                self.context = result.context
            },
            onError: { error in
                print(error.code)
        })
//        if sendError != nil {
//            print(sendError.code)
//        }
    }

    //ランダムな文字列を生成する
    func randomString(length: Int) -> String {
        let alphabet = "-_1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let upperBound = UInt32(alphabet.characters.count)
        return String((0..<length).map { _ -> Character in
            return alphabet[alphabet.startIndex.advancedBy(Int(arc4random_uniform(upperBound)))]
            })
    }
}

