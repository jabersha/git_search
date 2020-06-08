//
//  WebService.swift
//  GitSearch by Jabinho
//
//  Created by Jaber Vieira Da Silva Shamali on 02/06/20.
//  Copyright © 2020 Jaber Vieira Da Silva Shamali. All rights reserved.
//

import Foundation
import CoreData
import UIKit



class WebService {
    
    final let url = URL(string: "https://api.github.com/search/repositories?q=language:swift&sort=stars")
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    public var repo = [Entry]()
    var index = 0
    var indexGet = 0
    var imagem:[UIImage?] = []
    
    func getJson(){
        
    deleteAllRecords()
        
        guard let listUrl = url  else {return}

        
        URLSession.shared.dataTask(with: listUrl) { (data, urlResponse, error) in
            guard let data = data, error == nil, urlResponse != nil else {
                print("Error")
                return
            }
            do
            {
                let decoder = JSONDecoder()
                let repositories = try decoder.decode(Entry.self, from: data)
                self.repo = [repositories]
                print(self.repo[0].items[0].stargazers_count)
                self.saveData()
                   
            } catch{
                print(data)
                print(error)
            }
            
            }
        .resume()
    }
    
    func saveData(){
//        deleteAllRecords()
                
        while(index<=(repo[0].items.count - 1)){
        let entity = NSEntityDescription.entity(forEntityName: "Items", in: context )
        let newEntity = NSManagedObject(entity: entity!, insertInto: context)
            
        newEntity.setValue(repo[0].items[index].id, forKey: "id")
        newEntity.setValue(repo[0].items[index].name, forKey: "name")
        newEntity.setValue(repo[0].items[index].owner.login, forKey: "login")
        newEntity.setValue(repo[0].items[index].html_url, forKey: "html_url")
//        newEntity.setValue(repo[0].items[0].owner.avatar_url, forKey: "avatar_url")
        newEntity.setValue(repo[0].items[index].stargazers_count, forKey: "stargazers_count")
        if let imageURL = URL(string: repo[0].items[index].owner.avatar_url){
                let data = try? Data(contentsOf: imageURL)
                if let data = data {
                    let image = UIImage(data: data)
                    self.imagem.append(image)
                    let img = image!.pngData()
                    newEntity.setValue(img, forKey: "avatar_url")
                } else {
                    print("Erro ao salvar imagem")
            }
        }
            
                index += 1
                do{
                    try context.save()
                } catch {
                    print("Erro ao salvar")
                }
            }
    
    }
        
    func deleteAllRecords() {
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Items")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
            print ("Deletado com sucesso")
        } catch {
            print ("Delete falhou")
        }
    }
}


