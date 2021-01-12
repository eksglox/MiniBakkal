//
//  ViewController.swift
//  Demo
//
//  Created by mehmet  akyol on 8.12.2020.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var mainCollectionView: UICollectionView!

    @IBOutlet weak var cartButton: UIButton!
    
    
    static var urunlerArr = [urunModel]()
    static var sepetEklenenUrunler = [urunModel]()
    
    let badgeSize = 18
    let badgeTag = 12
    var badgeCount = UILabel()
    var totalCountForBadge = 0
    var storeArr = [urunModel]()
//    var storeArr = [urunModel](){
//        didSet{
//            DispatchQueue.main.async {
//                self.mainCollectionView.reloadData()
//            }
//        }
//    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getData()
       
    }
    

  
    override func viewDidAppear(_ animated: Bool) {
        updateBadge()
        mainCollectionView.reloadData()
    }
    
    @IBAction func tapped(_ sender: Any) {
        
        performSegue(withIdentifier: "sepet", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let sepetVC = segue.destination as! SepetViewController
        sepetVC.genelUrunlerArr = ViewController.urunlerArr
    }
    
    private func updateBadge(){
        totalCountForBadge = 0
        for i in ViewController.sepetEklenenUrunler {
            totalCountForBadge = i.stock + totalCountForBadge
        }
        showBadge(count: totalCountForBadge)
    }

    
    
    // MARK: GET DATA FROM URL..
    func getData(){
        
        let requestMethod = ApiConnectorTwo()
        requestMethod.getStructData { [weak self] result in
            switch result{
            case .failure(let error):
                print(error)
            case .success(let arr):
                self?.storeArr = arr
                DispatchQueue.main.async {
                    self?.mainCollectionView.reloadData()
                }
            }
        }
  
    }
    
    

    //MARK: -URUN EKLEME VE CIKARMA FONKSIYONLARI..
    
    @objc func ekleAction(sender: UIButton){
        let indexPath = IndexPath(row: sender.tag, section: 0)
        let col = mainCollectionView.cellForItem(at: indexPath) as! CustomCollectionViewCell
        col.urunCikarButton.isHidden = false
        col.adetLabel.isHidden = false
        
        var eklenenAdet = Int(col.adetLabel.text!)
        
        if ViewController.urunlerArr[sender.tag].stock == 0 {
            alert(message: "Seçtiğiniz ürün stoklarımızda kalmamıştır.")
        }else{
            eklenenAdet! += 1
            totalCountForBadge += 1
            showBadge(count: totalCountForBadge)
            var stocktanDusenAdet = 1
            var totalCount = ViewController.urunlerArr[sender.tag].stock
            var sonAdet = totalCount - stocktanDusenAdet
            
            
            ViewController.urunlerArr[sender.tag].stock = sonAdet
            
            
            var added = ViewController.urunlerArr[sender.tag]
            if ViewController.sepetEklenenUrunler.isEmpty {
                added.stock = eklenenAdet!
                ViewController.sepetEklenenUrunler.append(added)
            }else{
                if let data = ViewController.sepetEklenenUrunler.firstIndex(where: {$0.id == added.id}) {
                    ViewController.sepetEklenenUrunler[data].stock += 1
                }else{
                    added.stock = eklenenAdet!
                    ViewController.sepetEklenenUrunler.append(added)
                }
                
            }

            col.adetLabel.text = String(eklenenAdet!)
        }
       
    }


    @objc func cikarAction(sender:UIButton){
        
        let indexPath = IndexPath(row: sender.tag, section: 0)
        let col = mainCollectionView.cellForItem(at: indexPath) as! CustomCollectionViewCell
       
        totalCountForBadge -= 1
        showBadge(count: totalCountForBadge)
        
        var cikarilacakAdet = Int(col.adetLabel.text!)

        for (i,element) in ViewController.sepetEklenenUrunler.enumerated(){
            if element.id == ViewController.urunlerArr[sender.tag].id {
                if element.stock == 1 {
                    col.adetLabel.isHidden = true
                    col.urunCikarButton.isHidden = true
                    ViewController.sepetEklenenUrunler.remove(at: i)
                    ViewController.urunlerArr[sender.tag].stock += 1
                }else{
                    cikarilacakAdet! -= 1
                    
                    ViewController.sepetEklenenUrunler[i].stock -= 1
                    ViewController.urunlerArr[sender.tag].stock += 1
                }
                
            }
        }
        col.adetLabel.text = String(cikarilacakAdet!)
        
        print(ViewController.sepetEklenenUrunler)
        print(ViewController.urunlerArr)

        
    }
    
    //MARK: -BADGE BOLUMU:
    func badgeLabel(count: Int) -> UILabel {
        badgeCount = UILabel(frame: CGRect(x: 0, y: 0, width: badgeSize, height: badgeSize))
        badgeCount.tag = badgeTag
        badgeCount.layer.cornerRadius = badgeCount.bounds.size.height / 2
        badgeCount.layer.masksToBounds = true
        badgeCount.textColor = .red
        badgeCount.textAlignment = .center
        badgeCount.backgroundColor = .white
        badgeCount.text = String(count)
        return badgeCount
    }
    
    func showBadge(count: Int){
        let badge = badgeLabel(count: count)
        cartButton.addSubview(badge)
        
        
        NSLayoutConstraint.activate([badge.leftAnchor.constraint(equalTo: cartButton.leftAnchor, constant: 1),
                                    badge.topAnchor.constraint(equalTo: cartButton.topAnchor, constant: -5),
                                    badge.widthAnchor.constraint(equalToConstant: CGFloat(badgeSize)),
                                    badge.heightAnchor.constraint(equalToConstant: CGFloat(badgeSize))])
    }
    
    
    
}

// MARK: -MAIN VIEWCONTROLLER DELEGATES..

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return storeArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CustomCollectionViewCell
        cell.urunAdiLabel.text = storeArr[indexPath.row].name
        cell.fiyatLabel.text = "₺" + String(storeArr[indexPath.row].price)
        cell.productImageView.downloaded(from: storeArr[indexPath.row].imageUrl)
        var adetCount = 0
        cell.adetLabel.text = String(adetCount)
        cell.urunCikarButton.isHidden = true
        cell.adetLabel.isHidden = true
        cell.urunEkleButton.addTarget(self, action: #selector(ekleAction(sender:)), for: .touchUpInside)
        cell.urunEkleButton.tag = indexPath.row
        cell.urunCikarButton.addTarget(self, action: #selector(cikarAction(sender:)), for: .touchUpInside)
        cell.urunCikarButton.tag = indexPath.row
        return cell
    }
    
    
}



// MARK: -TURN URL TO IMAGE EXTENSION..
extension UIImageView {
    func downloaded(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
        }.resume()
    }
    func downloaded(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}


extension UIViewController {
  func alert(message: String, title: String = "") {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
    alertController.addAction(OKAction)
    self.present(alertController, animated: true, completion: nil)
  }
}
