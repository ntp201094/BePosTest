//
//  StockTableViewCell.swift
//  BePosTest
//
//  Created by Phuc Nguyen on 18/03/2021.
//

import UIKit
import RxSwift
import RxCocoa

final class StockTableViewCell: UITableViewCell {
    
    @IBOutlet weak var changesLabel: UILabel!
    @IBOutlet weak var companyImageView: UIImageView!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    
    var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.companyImageView.contentMode = .scaleAspectFit
        self.nameLabel.numberOfLines = 0
        favoriteButton.setTitle("Favorite", for: .normal)
        favoriteButton.setTitle("Unfavorite", for: .selected)
    }
    
    override func prepareForReuse() {
        self.disposeBag = DisposeBag()
    }
    
    func configure(viewModel: StockCellViewModel) {
        self.changesLabel.text = "\(0)"
        self.companyImageView.image = UIImage(systemName: "rectangle")
        self.symbolLabel.text = viewModel.symbol
        self.nameLabel.text = viewModel.name
        self.priceLabel.text = "\(viewModel.price)"
        self.favoriteButton.isSelected = viewModel.isFavorite
    }
    
}
