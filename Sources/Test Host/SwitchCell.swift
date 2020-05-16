//
//  SwitchCell.swift
//  Test Host
//
//  Created by Sven Herzberg on 15.10.19.
//

import UIKit

class SwitchCell: UITableViewCell {
    
    @IBOutlet var `switch`: UISwitch!
    
    var onToggle: (Bool) -> Void = { _ in }
    
    #if false
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    #endif
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        onToggle = { _ in }
    }
    
    @IBAction
    func onToggle(_ sender: UISwitch) {
        onToggle(sender.isOn)
    }
    
    #if false
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    #endif
    
}
