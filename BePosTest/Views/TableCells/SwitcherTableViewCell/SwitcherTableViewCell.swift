//
//  SwitcherTableViewCell.swift
//  BePosTest
//
//  Created by Phuc Nguyen on 22/03/2021.
//

import UIKit
import RxSwift
import RxCocoa

class SwitcherTableViewCell: UITableViewCell {
    
    @IBOutlet weak var modeLabel: UILabel!
    @IBOutlet weak var modeSwitcher: UISwitch!
    
    var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        self.disposeBag = DisposeBag()
    }
    
    func configure(isDark: Bool) {
        self.modeLabel.text = "Dark mode:"
        self.modeSwitcher.isOn = isDark
    }
    
}
