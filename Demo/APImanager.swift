//
//  APImanager.swift
//  Demo
//
//  Created by mehmet  akyol on 22.12.2020.
//

import UIKit




struct ApiConnectorTwo {
    
    func getStructData(completion: @escaping(Result<[urunModel], Error>) -> Void){
        
        let url = URL(string: "https://desolate-shelf-18786.herokuapp.com/list")
        let dataTask = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            
            if error != nil{
                return
            }
            
            do{
                let decoder = JSONDecoder()
                let arr = try decoder.decode([urunModel].self, from: data!)
                completion(.success(arr))
            }catch{
                
            }
            
        }
        dataTask.resume()
        
    }
    
}



//        let url = URL(string: "https://desolate-shelf-18786.herokuapp.com/list")
//        URLSession.shared.dataTask(with: url!) { (data, response, error) in
//
//            if error == nil{
//
//                do{
//                    ViewController.urunlerArr = try JSONDecoder().decode([urunModel].self, from: data!)
//                }catch{
//                    print("sorun var ")
//                }
//
//                DispatchQueue.main.async {
//                    print(ViewController.urunlerArr)
//                    self.mainCollectionView.reloadData()
//                }
//            }
//
//        }.resume()
