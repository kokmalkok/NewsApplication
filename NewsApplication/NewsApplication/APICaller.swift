//
//  APICaller.swift
//  NewsApplication
//
//  Created by Константин Малков on 29.04.2022.
//

import Foundation
//класс без возможности создания подклассов
final class APICaller{
    
    static let shared = APICaller()
    //наследование в структуру ссылки на все статьи со всеми данными, тайлтами,фото и ссылками
    struct Constants {
        //ссылка на ресурс для скачивания данных
        static let topHeadlinesURL = URL(string:"https://newsapi.org/v2/top-headlines?country=us&apiKey=9679b37384304d6d80fabceb7d7a5c59")
        
    }
    private init(){}
    //функция для наследования данных со ссылки на сториборд, либо для вывода ошибки
    public func getTopStories(completion: @escaping (Result<[Arcticle], Error>) -> Void) {
        guard let url = Constants.topHeadlinesURL else { //разворачиваем структуру
            return
        }
        //загрузка ссылок при входе в приложение
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {//вывод ошибки
                completion(.failure(error))
            } //декодирования json в текст формат для интеграции в строки
            else if let data = data {
                do {
                    let result = try JSONDecoder().decode(APIResponse.self, from: data)
                    //вывод в функцию getTopStories либо информации либо ошибка вывода
                    print("Arcticles: \(result.articles.count)")
                    completion(.success(result.articles))
                } catch {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
    
    public func search(with query: String, completion: @escaping (Result<[Arcticle], Error>) -> Void) {
        let urlSearch = "https://newsapi.org/v2/everything?q=\(query)&apiKey=9679b37384304d6d80fabceb7d7a5c59"
        guard let URL = URL(string: urlSearch) else {
            return
        }
        //загрузка ссылок при входе в приложение
        let task = URLSession.shared.dataTask(with: URL) { data, _, error in
            if let error = error {//вывод ошибки
                completion(.failure(error))
            } //декодирования json в текст формат для интеграции в строки
            else if let data = data {
                do {
                    let result = try JSONDecoder().decode(APIResponse.self, from: data)
                    //вывод в функцию getTopStories либо информации либо ошибка вывода
                    print("Arcticles: \(result.articles.count)")
                    completion(.success(result.articles))
                } catch {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
}
//структура нужна для форматирования json в swift текст с дальнейшей работой
struct APIResponse: Codable {
    //наследование структуры ниже
    let articles: [Arcticle]
}
//структура с наследованием API пунктов новостей, которые там имеются
struct Arcticle: Codable{
    let source: Source
    let title: String
    let description: String?
    let url: String?
    let urlToImage: String?
    let publishedAt: String

}
//отдельная структура тк там идет несколько подпунктов, которые мы не берем
struct Source: Codable{
    let name: String
}
