//
//  ViewController.swift
//  NewsApplication
//
//  Created by Константин Малков on 29.04.2022.
//
import UIKit
import SafariServices


//table view
//custom cell
//вызов API
//Открывать историю новостей
//Поиск новостей
//Добавить фоновое обновление каждые 2 часа
//Уведомления на каждое обновление фоновое



class ResultViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
    }
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchResultsUpdating {
    
   
    
    //наследование структуры
    private var arcticles = [Arcticle]()
    //наследование редактирования строки
    private var viewModels = [NewsTableViewCellViewModel]()
    
    //поисковая строка
//    private let searchVC = UISearchController(searchResultsController: nil)
    private let searchVC = UISearchController(searchResultsController: ResultViewController())
    //привязка таблицы к вью контроллеру
    private let tableView: UITableView = {
        let table = UITableView()
        
        table.register(NewsTableViewCell.self, forCellReuseIdentifier: NewsTableViewCell.identifier)
        
        return table
    }()

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let button = UIBarButtonItem(title: "Trend", style: .done, target: self, action: #selector(removeAllFromTable))
        
        title = "Новости"
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.refreshControl = UIRefreshControl()//функция ручного обновления данных на странице
        tableView.refreshControl?.addTarget(self,
                                            action: #selector(didPullToRefresh),
                                            for: .valueChanged)
        
        navigationItem.searchController = searchVC
        self.navigationItem.rightBarButtonItem = button
        searchVC.searchResultsUpdater = self
        searchVC.searchBar.delegate = self
        view.backgroundColor = .systemBackground
        
        getAPIcaller()
                
    }
    //функция нужна для отображения всех кодовых визуализаций
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        
    }
    
    @objc private func removeAllFromTable(){
        viewModels.removeAll()
        searchVC.searchBar.text = nil
        didPullToRefresh()
        getAPIcaller()
    }
    
//MARK: - Main methods
    private func getAPIcaller(){
        APICaller.shared.getTopStories { [weak self] result in
            switch result {
            case .success(let arcticles):
                self?.arcticles = arcticles
                self?.viewModels = arcticles.compactMap({
                    NewsTableViewCellViewModel(title: $0.title,
                                               subtitle: $0.description ?? "No description",
                                               imageURL: URL(string: $0.urlToImage ?? ""))
                })
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }

    }
    
    @objc private func didPullToRefresh(){
        arcticles.removeAll()
        if tableView.refreshControl?.isRefreshing == true{
            print("refreshing")
        } else {
            print("not refreshing")
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
            self.tableView.refreshControl?.endRefreshing()
        }
    }
    
//MARK: - table view sources
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       guard let cell = tableView.dequeueReusableCell(
            withIdentifier: NewsTableViewCell.identifier,
            for: indexPath)
                as? NewsTableViewCell else {
            fatalError()
        }
        cell.configure(with: viewModels[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let arcticle = arcticles[indexPath.row]
        
        guard let url = URL(string: arcticle.url ?? "" ) else {
            return
        }
        //создание переменной для перехода при нажатии на ссылку в браузер сафари
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let search = searchVC.searchBar.text else {
            return
        }
        let vc = searchVC.searchResultsUpdater as? ResultViewController
        vc?.view.backgroundColor = .lightGray
        
        
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.isEmpty else {
            return
        }
        APICaller.shared.search(with: text) {[weak self] result in
            switch result {
            case .success(let arcticles):
                self?.arcticles = arcticles
                self?.viewModels = arcticles.compactMap({
                    NewsTableViewCellViewModel(title: $0.title,
                                               subtitle: $0.description ?? "No description",
                                               imageURL: URL(string: $0.urlToImage ?? ""))
                })
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    self?.searchVC.dismiss(animated: true,completion:  nil)
                }
                
            case .failure(let error):
                print(error)
            }
        }
        print(text)
    }

}

