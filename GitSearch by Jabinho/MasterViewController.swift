//
//  MasterViewController.swift
//  GitSearch by Jabinho
//
//  Created by Jaber Vieira Da Silva Shamali on 02/06/20.
//  Copyright © 2020 Jaber Vieira Da Silva Shamali. All rights reserved.
//

import SwiftUI
import CoreData
import Network

class MasterViewController:UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    
    let webService = WebService()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var items = [Item]()
    var imagem:[UIImage?] = []
    var fetchingMore = false
    let monitor = NWPathMonitor()
    let queue = DispatchQueue(label: "Monitor")
    
    lazy var refresh : UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .gray
        refreshControl.addTarget(self, action: #selector(resquestData), for: .valueChanged)
        return refreshControl
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        monitor.start(queue: queue)
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                self.webService.getJson()
            }else{
                self.showOfflineAlert()
            }
        }
        self.tableView.dataSource = self
        self.tableView.delegate = self
        if !UserDefaults.standard.bool(forKey: Keys.firstAcess){
            sleep(3)
            UserDefaults.standard.set(true, forKey: Keys.firstAcess)

        }
        getData()
        print("DidLoad \(self.items.count)")
        tableView.refreshControl = refresh
        }

    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
//
    
    @objc
    func resquestData(){
        monitor.pathUpdateHandler = { path in
            if path.status == .unsatisfied {
                self.webService.getJson()
                self.getData()
                
            }else{
                self.showOfflineAlert()
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0 , execute: {self.refresh.endRefreshing()})
        fetchingMore = false
        self.tableView.reloadData()


    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if items.count > 0 && !fetchingMore{
            return items.count/2
        }else{
            return items.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "repo") as! RepoCell
        cell.autorLb.text = "Autor: \(items[indexPath.row].owner.login)"
        cell.nameLb.text = items[indexPath.row].name
        cell.starsLb.text = "Stars: \(items[indexPath.row].stargazers_count)"
        
        if !self.imagem.isEmpty && imagem.count == items.count{
            cell.imgView.image = self.imagem[indexPath.row]
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let urlString = items[indexPath.row].html_url
        
        if let url = URL(string: urlString){
            UIApplication.shared.open(url, options: [:], completionHandler: nil)        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - scrollView.frame.height{
            if !fetchingMore{
                begingFetch()
            }
        }
    }
    
    func begingFetch(){
        fetchingMore = true
        print("Fim da tabela")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0 , execute: {self.tableView.reloadData()})
    }
    
    func showOfflineAlert() {
         DispatchQueue.main.async {
        let alert = UIAlertController(title: "Offline", message: "Você está desconectado", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))

        self.present(alert, animated: true)
        }
    }
        
    func getData(){
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Items")
            request.returnsObjectsAsFaults = true
            
             do{
                let result = try! self.context.fetch(request)
                 for data in result as! [NSManagedObject]{
                    self.items.append(Item.init(id: data.value(forKey: "id") as! Int, name: data.value(forKey: "name") as! String, owner: Owner.init(login: data.value(forKey: "login") as! String, avatar_url: data.value(forKey: "avatar_url")  as? String ?? ""), stargazers_count: data.value(forKey: "stargazers_count") as! Int, html_url: data.value(forKey: "html_url") as! String))
                    var img: UIImage?{
                             return UIImage(data: data.value(forKey: "avatar_url") as! Data)
                    }
                                     self.imagem.append(img)

                 }
             }
         }
        
    

}
