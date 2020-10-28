//
//  AddressTextField.swift
//  Dynamic
//
//  Created by Brandon Baker on 4/30/20.
//  Copyright © 2020 Brandon Baker. All rights reserved.
//

import UIKit
import Material
import MapKit

protocol AddressFieldDelegate {
    func didSelectAddress(_ location: Location)
    func didTapTextField(_ textField: UITextField)
}

class AddressTextField: UIView, UITextFieldDelegate, TableViewDelegate, TableViewDataSource, MapSelectionDelegate {
    
    var dataSourceItems: [DataSourceItem] = []
    
    let textField = ThemeTextField()
    let locationManager = DirectionManager()
    
    let tableView = UITableView()
    var addressResults : [Location] = []
    
    var selectedMapItem : Location? = nil
    
    var delegate : AddressFieldDelegate?
    
    init(_ placeholder: String? = nil, canEditTextField: Bool = false) {
        super.init(frame: .zero)
        
        textField.placeholderLabel.text = placeholder
        textField.textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        textField.textField.delegate = self
        self.addSubview(textField)
        textField.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(40)
        }
        
        self.tableView.separatorStyle = .none
        self.tableView.backgroundColor = .themeWhite
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.addSubview(tableView)
        
        if !canEditTextField {
            let overlayButton = UIButton()
            overlayButton.addTarget(self, action: #selector(didTapOverlay), for: .touchUpInside)
            self.addSubview(overlayButton)
            overlayButton.snp.makeConstraints { make in
                make.top.left.right.bottom.equalToSuperview()
            }
        }
        
    }
    
    func didSelectAddress(addressTextField: AddressTextField) {
        self.textField.placeholderLabel.text = addressTextField.textField.placeholderLabel.text
        self.textField.textField.text = addressTextField.textField.textField.text
        self.selectedMapItem = addressTextField.selectedMapItem
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let location = addressResults[indexPath.row]
        self.selectedMapItem = location
        self.textField.textField.text = location.name
        self.addressResults = []
        self.tableView.reloadData()
        delegate?.didSelectAddress(location)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rows = addressResults.count
        tableView.snp.remakeConstraints { make in
            make.top.equalTo(textField.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(40 * rows)
        }
        return rows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = addressResults[indexPath.row].name
        cell.textLabel?.textColor = .blackText
        cell.selectionStyle = .none
        cell.backgroundColor = .themeWhite
        return cell
    }
    
    @objc func didTapOverlay() {
        delegate?.didTapTextField(self.textField.textField)
    }
    
    @objc func textFieldDidChange(_ textField: TextField) {
        guard let string = textField.text else { return }
        locationManager.searchString(string) { mapItems in
            self.addressResults = mapItems
            self.tableView.reloadData()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
