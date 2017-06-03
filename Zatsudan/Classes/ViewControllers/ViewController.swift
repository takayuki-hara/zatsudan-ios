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

    // MARK: - IBAction
    @IBAction func didPushClearButton(_ sender: AnyObject) {
        self.messages.removeAll()
        self.collectionView.reloadData()
        self.mode = "dialog"
        self.context = randomString(18)
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        //自分のsenderId, senderDisokayNameを設定
        self.senderId = "you"
        self.senderDisplayName = "you"
        
        //吹き出しの設定
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        self.incomingBubble = bubbleFactory?.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
        self.outgoingBubble = bubbleFactory?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleGreen())
        
        //アバターの設定
        self.incomingAvatar = JSQMessagesAvatarImageFactory.avatarImage(with: R.image.apiIcon()!, diameter: 64)
        self.outgoingAvatar = JSQMessagesAvatarImageFactory.avatarImage(with: R.image.youIcon()!, diameter: 64)

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
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        //新しいメッセージデータを追加する
        guard let message = JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text) else { return }
        self.messages.append(message)
        
        //メッセージの送信処理を完了する(画面上にメッセージが表示される)
        self.finishReceivingMessage(animated: true)
        self.inputToolbar.contentView.textView.text = ""

        //対話メッセージを要求する
        self.requestMessage(text)
    }

    //アクセサリーボタンが押された時に呼ばれる
    override func didPressAccessoryButton(_ sender: UIButton!) {
        //何もしない（未実装）
        //メソッドがないと落ちる
    }

    //アイテムごとに参照するメッセージデータを返す
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return self.messages[indexPath.item]
    }
    
    //アイテムごとのMessageBubble(背景)を返す
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = self.messages[indexPath.item]
        if message.senderId == self.senderId {
            return self.outgoingBubble
        }
        return self.incomingBubble
    }
    
    //アイテムごとにアバター画像を返す
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        let message = self.messages[indexPath.item]
        if message.senderId == self.senderId {
            return self.outgoingAvatar
        }
        return self.incomingAvatar
    }
    
    //アイテムの総数を返す
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }


    // MARK: - Private Methods
    
    //対話メッセージを要求する
    private func requestMessage(_ text: String) {
        guard let dialogue = Dialogue() else { return }
        let param = self.createRequestParam(text: text)

        //API
        //Memo: DialogueErrorクラスがx86_64にないので返り値は受けとらない
        dialogue.request(param,
            onComplete: { result in
                guard let ret = result, let text = ret.utt, let mode = ret.mode, let context = ret.context else { return }
                self.showResponseMessage(text)
                self.mode = mode
                self.context = context
                self.requestSound(text)
            },
            onError: { error in
                self.errorAlert("エラーコード：\(String(describing: error?.code))")
        })
    }

    //リクエストパラメータを生成する
    private func createRequestParam(text: String) -> DialogueRequestParam? {
        guard let param = DialogueRequestParam() else { return nil }

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
            let calendar = Calendar.current
            let comps = calendar.dateComponents([.year, .month, .day], from: birth)
            if let year = comps.year, let month = comps.month, let day = comps.day {
                param.birthdateY = year
                param.birthdateM = month
                param.birthdateD = day
            }
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
    private func showResponseMessage(_ text: String) {
        if let message = JSQMessage(senderId: "api", displayName: "api", text: text) {
            self.messages.append(message)
            self.finishReceivingMessage(animated: true)
        }
    }

    //ランダムな文字列を生成する
    private func randomString(_ length: Int) -> String {
        let alphabet = "1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let upperBound = UInt32(alphabet.characters.count)
        return String((0..<length).map { _ -> Character in
            return alphabet[alphabet.characters.index(alphabet.startIndex, offsetBy: Int(arc4random_uniform(upperBound)))]
            })
    }

    //エラーコード表示
    private func errorAlert(_ message: String) {
        let alert = UIAlertController(title: "エラー", message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { action in
            print(message)
        }
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }

    //合成音声の要求
    private func requestSound(_ text: String) {
        guard let ssml = AiTalkSsml() else { return }
        guard let voice = AiTalkVoice(voiceName: "nozomi") else { return }
        guard let search = AiTalkTextToSpeech() else { return }

        voice.addText(text)
        ssml.add(voice)
        search.requestAiTalkSsml(toSound: ssml.make(), onComplete: { data in
                print("onComplete")
                guard let sound = data else { return }
                self.playAudio(sound)
            }) { receiveError in
                self.errorAlert("エラーコード：\(String(describing: receiveError?.code))"
            )
        }
    }
    
    //合成音声の再生
    private func playAudio(_ data: Data) {
        print("playAudio data.length=\(data.count)")
        let convData = AiTalkTextToSpeech.convertByteOrder16(data)
        AiTalkAudioPlayer.manager().playSound(AiTalkAddHeader.addHeader(convData))
    }

}

