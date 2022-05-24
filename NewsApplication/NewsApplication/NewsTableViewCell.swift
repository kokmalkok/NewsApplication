//
//  NewsTableViewCell.swift
//  NewsApplication
//
//  Created by Константин Малков on 29.04.2022.
//

import UIKit
//класс предназначен для инициализации в строку четырех типов данных
class NewsTableViewCellViewModel {
    //константы и данные , которые пользователь будет видеть и с которыми будет взаимодействовать
    let title: String
    let subtitle: String
    let imageURL: URL?
    var imageData: Data? = nil
    //инициализатор чтобы не дописывать везде 0 или nil
    init (
        title: String,
        subtitle:String,
        imageURL: URL?) {
            self.title = title
            self.subtitle = subtitle
            self.imageURL = imageURL
            
        }
    
}

class NewsTableViewCell: UITableViewCell {
    //идентификатор для взаимодействия с классом
    static let identifier = "NewsTableViewCell"
    //заглавный тайтл новостей
    private let newsTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 20,weight: .semibold)
        
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 16,weight: .thin)
        
        return label
    }()
    
    
    private let newsImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 6
        imageView.layer.masksToBounds = true
        imageView.clipsToBounds = true
        imageView.backgroundColor = .secondarySystemBackground
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(newsTitleLabel)
        contentView.addSubview(newsImageView)
        contentView.addSubview(subtitleLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        newsTitleLabel.frame = CGRect(x: 10,
                                      y: 0,
                                      width: contentView.frame.size.width - 10,
                                      height: 80)
        subtitleLabel.frame = CGRect(x: 10,
                                      y: 70,
                                      width: contentView.frame.size.width - 85,
                                      height: contentView.frame.size.height/2)
        newsImageView.frame = CGRect(x: contentView.frame.size.width-70,
                                      y: 80,
                                      width: 60,
                                      height: contentView.frame.size.height-90)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        newsTitleLabel.text = nil
        subtitleLabel.text = nil
        newsImageView.image = nil
    }
    //функция конфигурации и загрузки данных из ссылки
    func configure(with viewModel: NewsTableViewCellViewModel){
        newsTitleLabel.text = viewModel.title
        subtitleLabel.text = viewModel.subtitle
        
        //загрузка фото
        if let data = viewModel.imageData {
            newsImageView.image = UIImage(data: data)
        } else if let url = viewModel.imageURL {
            //fetch
            URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
                guard let data = data, error == nil else {
                    return
                }
                viewModel.imageData = data
                DispatchQueue.main.async {
                    self?.newsImageView.image = UIImage(data: data)
                }

            }.resume()
        }
    }
}
