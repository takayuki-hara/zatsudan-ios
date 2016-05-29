//
//  ViewController.swift
//  Zatsudan
//
//  Created by TakayukiHARA on 2016/05/29.
//  Copyright © 2016年 Hispot Co., LTD. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import SwiftyUserDefaults

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
        self.incomingBubble = bubbleFactory.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleBlueColor())
        self.outgoingBubble = bubbleFactory.outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleGreenColor())
        
        //アバターの設定
        self.incomingAvatar = JSQMessagesAvatarImageFactory.avatarImageWithImage(R.image.apiIcon()!, diameter: 64)
        self.outgoingAvatar = JSQMessagesAvatarImageFactory.avatarImageWithImage(R.image.youIcon()!, diameter: 64)

        //初期化
        AuthApiKey.initializeAuth("6e2f54636b655364647a6f6d524644424b6e4f50504e665a517772333376324d354e6f4c4e514a59307744")
        self.context = randomString(18)
        print(self.context)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


    // MARK: - Override Methods

    //Sendボタンが押された時に呼ばれる
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        
        //新しいメッセージデータを追加する
        let message = JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text)
        self.messages.append(message)
        
        //メッセージの送信処理を完了する(画面上にメッセージが表示される)
        self.finishReceivingMessageAnimated(true)
        self.inputToolbar.contentView.textView.text = ""

        //対話メッセージを要求する
        self.requestMessage(text)
    }

    //アクセサリーボタンが押された時に呼ばれる
    override func didPressAccessoryButton(sender: UIButton!) {
        //何もしない（未実装）
        //メソッドがないと落ちる
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


    // MARK: - Private Methods
    
    //対話メッセージを要求する
    private func requestMessage(text: String) {
        let dialogue = Dialogue()
        let param = self.createRequestParam(text)

        //API
        //Memo: DialogueErrorクラスがx86_64にないので返り値は受けとらない
        dialogue.request(param,
            onComplete: { result in
                self.showResponseMessage(result.utt)
                self.mode = result.mode
                self.context = result.context
            },
            onError: { error in
                self.errorAlert("エラーコード：\(error.code)")
        })
    }

    //リクエストパラメータを生成する
    private func createRequestParam(text: String) -> DialogueRequestParam {
        let param = DialogueRequestParam()
        param.utt = text
        param.mode = self.mode
        param.context = self.context

        if Defaults[.userName].characters.count != 0 {
            param.nickname = Defaults[.userName]
        }
        if Defaults[.userKana].characters.count != 0 {
            param.nickname_y = Defaults[.userKana]
        }
        if Defaults[.userSex] == 0 {
            param.sex = "男"
        } else {
            param.sex = "女"
        }
        switch Defaults[.userBlood] {
        case 0: param.bloodtype = "A"
        case 1: param.bloodtype = "B"
        case 2: param.bloodtype = "C"
        case 3: param.bloodtype = "D"
        default: break
        }
        if let birth = Defaults[.userBirthDay] {
            let calendar = NSCalendar.currentCalendar()
            let comps = calendar.components([.Year, .Month, .Day], fromDate: birth)
            param.birthdateY = comps.year
            param.birthdateM = comps.month
            param.birthdateD = comps.day
        }
        param.place = Area(rawValue: Defaults[.userArea])?.toString()
        switch Defaults[.userLangage] {
        case 1: param.character = 20
        case 2: param.character = 30
        default: break
        }
        
        return param
    }

    //レスポンスを表示する
    private func showResponseMessage(text: String) {
        let message = JSQMessage(senderId: "api", displayName: "api", text: text)
        self.messages.append(message)
        self.finishReceivingMessageAnimated(true)
    }

    //ランダムな文字列を生成する
    private func randomString(length: Int) -> String {
        let alphabet = "1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let upperBound = UInt32(alphabet.characters.count)
        return String((0..<length).map { _ -> Character in
            return alphabet[alphabet.startIndex.advancedBy(Int(arc4random_uniform(upperBound)))]
            })
    }

    //エラーコード表示
    private func errorAlert(message: String) {
        let alert = UIAlertController(title: "エラー", message: message, preferredStyle: .Alert)
        let ok = UIAlertAction(title: "OK", style: .Default) { action in
            print(message)
        }
        alert.addAction(ok)
        presentViewController(alert, animated: true, completion: nil)
    }
}

