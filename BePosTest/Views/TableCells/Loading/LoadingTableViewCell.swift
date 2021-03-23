//
//  LoadingTableViewCell.swift
//  BePosTest
//
//  Created by Phuc Nguyen on 20/03/2021.
//

import UIKit

class LoadingTableViewCell: UITableViewCell {
    
    var indicatorView: UIActivityIndicatorView?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            indicator.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 16),
            indicator.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -16)
        ])
        self.indicatorView = indicator
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
