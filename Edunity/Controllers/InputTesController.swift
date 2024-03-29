//
//  InputTesController.swift
//  skripsi
//
//  Created by Hanz Christian on 06/04/23.
//

import Foundation
import UIKit
import FirebaseFirestore

class InputTesController:UIViewController{
    
    // MARK: - Variables & Outlet
    
    @IBOutlet weak var tableView: UITableView!
    
    let cellTitle = ["Nama Tes","Deskripsi Tes","Waktu Pengerjaan"]
    let db = Firestore.firestore()
    let modulModel = ModulModel()
    let tesModel = TesModel()
    
    var tesNameTVC: TesNameTVC?
    var tesDescTVC: TesDescriptionTVC?
    var timerTVC: TimerTVC?
    var largeTitle: String?
    var exist: String?
    var prevtesName: String?
    var prevtesDesc: String?
    var prevTimer: String?
    
}
extension InputTesController{
    // MARK: - View Life Cycle
    
    override func viewDidLoad(){
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        //dismiss gesture
//        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:)))
//        view.addGestureRecognizer(tapGesture)
        
        let nibTesName = UINib(nibName: "TesNameTVC", bundle: nil)
        tableView.register(nibTesName, forCellReuseIdentifier: "TesNameTVC")
        let nibTesDesc = UINib(nibName: "TesDescriptionTVC", bundle: nil)
        tableView.register(nibTesDesc, forCellReuseIdentifier: "TesDescriptionTVC")
        let nibTimer = UINib(nibName: "TimerTVC", bundle: nil)
        tableView.register(nibTimer, forCellReuseIdentifier: "TimerTVC")
        
        modulModel.fetchModulTes { [self] modules in
            largeTitle = modules.modulName
            tesModel.fetchTesInModul { [self] tes, error in
                if let error = error{
                    exist = nil
                    setNavItem()
                    return
                }
                exist = tes?.tesid
                setNavItem()
            }
        }
    }
}
// MARK: - IBActions

// MARK: - Private/Functions
extension InputTesController{
    private func setNavItem(){
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationItem.title = "Input Tes \(largeTitle!)"
        
        if(exist != nil){
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Update", style: .plain, target: self, action: #selector(updateItem))
        }else{
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Simpan", style: .plain, target: self, action: #selector(saveItem))
        }
        
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Batal", style: .plain, target: self, action: #selector(dismissSelf))
        
        navigationItem.rightBarButtonItem?.tintColor = UIColor(red: 0.251, green: 0.055, blue: 0.196, alpha: 1)
        navigationItem.leftBarButtonItem?.tintColor = UIColor(red: 0.251, green: 0.055, blue: 0.196, alpha: 1)
        
        navigationController?.navigationBar.largeTitleTextAttributes =
        [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 28)]
    }
    
    @objc private func saveItem(){
        let tesid = UUID().uuidString
        
        if let nameTes = tesNameTVC?.tesNameTV.text,!nameTes.isEmpty,let descTes = tesDescTVC?.tesDescTF.text,!descTes.isEmpty,let timer = timerTVC?.timerLbl.text,!timer.isEmpty{
            
            let time = timerTVC?.selectedTimeInterval
            
            storeData(nameTes: nameTes, descTes: descTes, modulid: SelectedModul.selectedModul.modulPath,classid: SelectedClass.selectedClass.classPath,tesid: tesid,nameModul: largeTitle!,timer:time!,displayedTime:timer)
            print("Saved")
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshModul"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshData"), object: nil)
            
            dismissSelf()
        }else{
            print("ga masuk bro")
        }
    }
    
    @objc private func updateItem(){
        
        if let nameTes = tesNameTVC?.tesNameTV.text,!nameTes.isEmpty,let descTes = tesDescTVC?.tesDescTF.text,!descTes.isEmpty,let timer = timerTVC?.timerLbl.text,!timer.isEmpty{
            
            let time = timerTVC?.selectedTimeInterval
            updateData(nameTes: nameTes, descTes: descTes,timer: time!,displayedTime: timer)
            print("Update succesful!")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshModul"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshData"), object: nil)
            dismissSelf()
        }else{
            print("ga masuk bro")
        }
        
    }
    
    @objc private func dismissSelf(){
        self.dismiss(animated: true,completion: nil)
    }
    
    private func storeData(nameTes: String,descTes: String, modulid: String, classid: String, tesid: String,nameModul: String,timer: Double,displayedTime: String){
        
        db.collection("tes").whereField("classid", isEqualTo: classid).getDocuments { querySnapshot, error in
            let count = querySnapshot?.count ?? 0
            if let error = error{
                // Upload data
                self.db.collection("tes").addDocument(data: [
                    "nameTes": nameTes,
                    "descTes": descTes,
                    "nameModul": nameModul,
                    "modulid": modulid,
                    "classid": classid,
                    "tesid": tesid,
                    "timer": timer,
                    "displayedTime": displayedTime,
                    "count": count + 1
                ])
                return
            }else{
                self.db.collection("tes").addDocument(data: [
                    "nameTes": nameTes,
                    "descTes": descTes,
                    "nameModul": nameModul,
                    "modulid": modulid,
                    "classid": classid,
                    "tesid": tesid,
                    "timer": timer,
                    "displayedTime": displayedTime,
                    "count": count + 1
                ])
            }
        }
    
    }
    
    private func updateData(nameTes: String,descTes: String,timer: Double,displayedTime: String){
        db.collection("tes").whereField("classid", isEqualTo: SelectedClass.selectedClass.classPath).whereField("modulid", isEqualTo: SelectedModul.selectedModul.modulPath).getDocuments { (querySnapshot, err) in
            if let err = err{
                print("error")
            }else{
                let document = querySnapshot!.documents.first
                document!.reference.updateData([
                    "nameTes": nameTes,
                    "descTes": descTes,
                    "timer": timer,
                    "displayedTime": displayedTime
                ])
            }
        }
    }
    
    
}
// MARK: - TableView Delegate & Datasource
extension InputTesController:UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.section == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: "TesNameTVC", for: indexPath) as! TesNameTVC
            
            tesNameTVC = cell
            
            tesModel.fetchTesInModul { [self] tes, error in
                if let error = error{
                    return
                }
                prevtesName = tes?.tesName
                tesNameTVC?.tesNameTV.text = prevtesName
            }
            
            return tesNameTVC!
            
        }else if(indexPath.section == 1){
            let cell = tableView.dequeueReusableCell(withIdentifier: "TesDescriptionTVC", for: indexPath) as! TesDescriptionTVC
            
            tesDescTVC = cell
            
            tesModel.fetchTesInModul { [self] tes, error in
                if let error = error{
                    return
                }
                prevtesDesc = tes?.tesDesc
                tesDescTVC?.tesDescTF.text = prevtesDesc
            }
            
            return tesDescTVC!
        }else if(indexPath.section == 2){
            let cell = tableView.dequeueReusableCell(withIdentifier: "TimerTVC", for: indexPath) as! TimerTVC
            
            timerTVC = cell
            
            tesModel.fetchTesInModul { [self] tes, error in
                if let error = error{
                    return
                }
                prevTimer = tes?.displayedTime
                timerTVC?.timerLbl.text = prevTimer
            }
            
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.section == 1){
            return 63
        }
        else{
            return 44
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        let sectionLabel = UILabel(frame: CGRect(x: 5, y: 0, width: tableView.bounds.size.width, height: 5))
        sectionLabel.font = .systemFont(ofSize: 16, weight: .medium)
        sectionLabel.textColor = UIColor.black
        sectionLabel.text = cellTitle[section]
        sectionLabel.sizeToFit()
        headerView.addSubview(sectionLabel)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? TimerTVC{
            if !cell.isFirstResponder{
                _ = cell.becomeFirstResponder()
            }
        }
    }
    
}
