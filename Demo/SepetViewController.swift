//
//  SepetViewController.swift
//  Demo
//
//  Created by mehmet  akyol on 8.12.2020.
//

import UIKit

class SepetViewController: UIViewController {
    
    @IBOutlet weak var sepetCollectionView: UICollectionView!
    @IBOutlet weak var toplamText: UILabel!
    @IBOutlet weak var toplamTutarLabel: UILabel!
    
    
    var genelUrunlerArr = [urunModel]()
    var sepettekiUrunlerArr = [urunModel]()
    var toplamTutar = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()

        sepetCollectionView.delegate = self
        sepetCollectionView.dataSource = self
       
        emptyCheck()
        tutarHesapla()
        
        
    }
    
    func emptyCheck(){
        
        if ViewController.sepetEklenenUrunler.isEmpty {
            sepetCollectionView.isHidden = true
            toplamTutarLabel.text = "₺ 0.0"
            // BURAYA SEPETINIZ BOS YAZ..
        }else{
            sepetCollectionView.isHidden = false
            
        }
    }
    
    func tutarHesapla(){
        if ViewController.sepetEklenenUrunler.isEmpty {
            toplamTutarLabel.text = "₺" + "0.0"
        }else{
            for i in ViewController.sepetEklenenUrunler{
                toplamTutar = (Double(i.stock) * i.price) + toplamTutar
            }
            toplamTutarLabel.text = "₺" + String(toplamTutar)
        }

    }
    @IBAction func sepetTemize(_ sender: Any) {
        
        print("temiz sepet")
        ViewController.sepetEklenenUrunler.removeAll()
        sepetCollectionView.reloadData()
        ViewController.urunlerArr.removeAll()
        toplamTutarLabel.text = "₺ 0.0"
        let url = URL(string: "https://desolate-shelf-18786.herokuapp.com/list")
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            
            if error == nil{
                
                do{
                    ViewController.urunlerArr = try JSONDecoder().decode([urunModel].self, from: data!)
                }catch{
                    print("sorun var ")
                }
                
                DispatchQueue.main.async {
                    print(ViewController.urunlerArr)
                    
                }
            }
            
        }.resume()
    }
    
    @IBAction func siparisButtonTapped(_ sender: Any) {
        
        createJSON()
    }
    
    func createJSON(){

       
        var postArr = [[String : Any]]()
        var mainArr = [String:Any]()
        for i in ViewController.sepetEklenenUrunler {
            print(i.id)
            print(i.stock)
            var data = ["id":i.id, "amount":i.stock] as [String : Any]
            //print(data)
            postArr.append(data)
        }
        mainArr = ["products" : postArr] as [String : Any]
        
        print(mainArr)
        sendDataToService(dataArr: mainArr)

        
    }
    


    
    
    func sendDataToService(dataArr : [String : Any]){

        let jsonData = try? JSONSerialization.data(withJSONObject: dataArr, options: JSONSerialization.WritingOptions.prettyPrinted)


        let url = URL(string: "https://desolate-shelf-18786.herokuapp.com/checkout")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                print(responseJSON)
                print("response here!!")
                DispatchQueue.main.async {
                    self.alert(message: (responseJSON["message"] as? String)!, title: (responseJSON["orderID"] as? String)!)
                }

            }
        }

        task.resume()

    }
    
    
    @objc func cikarButtonTapped(sender: UIButton){
        
        if ViewController.sepetEklenenUrunler[sender.tag].stock == 1 {
            
            for (i,element) in ViewController.urunlerArr.enumerated() {
                if ViewController.sepetEklenenUrunler[sender.tag].id == element.id {
                    ViewController.urunlerArr[i].stock += 1
                }
            }
            
            toplamTutar = toplamTutar - ViewController.sepetEklenenUrunler[sender.tag].price
            toplamTutarLabel.text = "₺" + String(toplamTutar)
            
            
            ViewController.sepetEklenenUrunler.remove(at: sender.tag)
            self.sepetCollectionView.reloadData()
        }else{
            ViewController.sepetEklenenUrunler[sender.tag].stock -= 1
            for (i,element) in ViewController.urunlerArr.enumerated() {
                if element.id == ViewController.sepetEklenenUrunler[sender.tag].id {
                    ViewController.urunlerArr[i].stock += 1
                }
            }
            toplamTutar = toplamTutar - ViewController.sepetEklenenUrunler[sender.tag].price
            toplamTutarLabel.text = "₺" + String(toplamTutar)
            
            
            self.sepetCollectionView.reloadData()
        }
        
        emptyCheck()
        
    }
    
    @objc func ekleButtonTapped(sender:UIButton){
        
        for (i,element) in ViewController.urunlerArr.enumerated() {
            if element.id == ViewController.sepetEklenenUrunler[sender.tag].id {
                if element.stock == 0 {
                    alert(message: "Seçtiğiniz ürün stoklarımızda kalmamıştır.")
                    // BURALARA ALERT GEREK..
                }else{
                    print("ekledin")
                    ViewController.sepetEklenenUrunler[sender.tag].stock += 1
                    ViewController.urunlerArr[i].stock -= 1
                    toplamTutar = toplamTutar + ViewController.sepetEklenenUrunler[sender.tag].price
                    toplamTutarLabel.text = "₺" + String(toplamTutar)
                    self.sepetCollectionView.reloadData()
                }
            }

        }
        
    }

}

// MARK: SEPET COLLECTION VIEW DELEGATES..
extension SepetViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ViewController.sepetEklenenUrunler.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "sepetCell", for: indexPath) as! SepetCollectionViewCell
        cell.sepetUrunLabel.text = ViewController.sepetEklenenUrunler[indexPath.row].name
        cell.sepetFiyatLabel.text = "₺" + String(ViewController.sepetEklenenUrunler[indexPath.row].price)
        cell.sepetAdetLabel.text = String(ViewController.sepetEklenenUrunler[indexPath.row].stock)
        cell.sepetImageView.downloaded(from: ViewController.sepetEklenenUrunler[indexPath.row].imageUrl)
        cell.sepetCikarButton.addTarget(self, action: #selector(cikarButtonTapped(sender:)), for: .touchUpInside)
        cell.sepetCikarButton.tag = indexPath.row
        cell.sepetEkleButton.addTarget(self, action: #selector(ekleButtonTapped(sender:)), for: .touchUpInside)
        cell.sepetEkleButton.tag = indexPath.row
        return cell
    }
    
    
}


