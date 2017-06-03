//
//  SettingViewController.swift
//  Zatsudan
//
//  Created by TakayukiHARA on 2016/05/29.
//  Copyright © 2016年 Hispot Co., LTD. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

class SettingViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var nameLabel: UITextField!
    @IBOutlet weak var kanaLabel: UITextField!
    @IBOutlet weak var sexSegControl: UISegmentedControl!
    @IBOutlet weak var bloodSegControl: UISegmentedControl!
    @IBOutlet weak var birthDataPicker: UIDatePicker!
    @IBOutlet weak var areaPicker: UIPickerView!
    @IBOutlet weak var langSegControl: UISegmentedControl!

    // MARK: - IBAction
    @IBAction func didChangeName(_ sender: AnyObject) {
        if let name = nameLabel.text {
            Defaults[.userName] = name
        }
    }
    @IBAction func didChangeKana(_ sender: AnyObject) {
        if let kana = kanaLabel.text {
            Defaults[.userKana] = kana
        }
    }
    @IBAction func didChangeSex(_ sender: AnyObject) {
        Defaults[.userSex] = sexSegControl.selectedSegmentIndex
    }
    @IBAction func didChangeBlood(_ sender: AnyObject) {
        Defaults[.userBlood] = bloodSegControl.selectedSegmentIndex
    }
    @IBAction func didChangeDate(_ sender: AnyObject) {
        Defaults[.userBirthDay] = birthDataPicker.date
    }
    @IBAction func didChangeLang(_ sender: AnyObject) {
        Defaults[.userLangage] = langSegControl.selectedSegmentIndex
    }

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.areaPicker.dataSource = self
        self.areaPicker.delegate = self

        self.setValues()

        // キーボード外のタッチでキーボードを閉じるための設定
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SettingViewController.closeSoftKeyboard))
        self.view.addGestureRecognizer(gestureRecognizer)    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Private Methods
    private func setValues() {
        self.nameLabel.text = Defaults[.userName]
        self.kanaLabel.text = Defaults[.userKana]
        self.sexSegControl.selectedSegmentIndex = Defaults[.userSex]
        self.bloodSegControl.selectedSegmentIndex = Defaults[.userBlood]
        if let birth = Defaults[.userBirthDay] {
            self.birthDataPicker.date = birth
        } else {
            self.birthDataPicker.date = Date()
        }
        self.areaPicker.selectRow(Defaults[.userArea], inComponent: 0, animated: true)
        self.langSegControl.selectedSegmentIndex = Defaults[.userLangage]
    }

    func closeSoftKeyboard() {
        self.view.endEditing(true)
    }
}

extension SettingViewController: UIPickerViewDelegate {
    
    // MARK: - UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Area(rawValue: row)?.toString()
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        Defaults[.userArea] = row
    }
}

extension SettingViewController: UIPickerViewDataSource {
    
    // MARK: - UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Area.count
    }
    
}

