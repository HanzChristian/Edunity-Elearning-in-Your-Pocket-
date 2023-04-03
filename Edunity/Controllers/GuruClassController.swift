//
//  GuruClassController.swift
//  skripsi
//
//  Created by Hanz Christian on 06/03/23.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

class GuruClassController: UIViewController {
    // MARK: - Variables & Outlet
    @IBOutlet weak var tableView: UITableView!
    let cellTitle = ["Modul", "Kumpulan Tugas"]
    
    let db = Firestore.firestore()
    
    let classModel = ClassModel()
    let modulModel = ModulModel()
    var listofModul = [Modul]()
    var listofTugas = [Tugas]()
    var jumlahModul = [JumlahModul]()
    var jumlahTugas = [JumlahTugas]()
    
    var className: String?
    var row: Int?
    var modulCount = JumlahModul(modulNum: 0)
    var tugasCount = JumlahTugas(tugasNum: 0)
}
extension GuruClassController{
    // MARK: - View Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh(_:)), name: NSNotification.Name(rawValue: "refreshModul"), object: nil)
    }
    
    override func viewDidLoad(){
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        super.viewDidLoad()
        
        DispatchQueue.main.async{ [self] in
            fetchData()
        }
        
        classModel.fetchSelectedClass { [self] classess in
            className = classess.className
            print("ini classname = \(className)")
            setNavItem()
            print("ini listofmodul count = \(listofModul.count)")
            print("ini listoftugas count = \(listofTugas.count)")
            if(listofModul.count > 0 || listofTugas.count > 0){
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hiddenGuru"), object: nil)
            }
            else if(listofModul.count == 0 || listofTugas.count == 0){
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "unhiddenGuru"), object: nil)
            }
        }
        let nibModul = UINib(nibName: "ModulTVC", bundle: nil)
        tableView.register(nibModul, forCellReuseIdentifier: "ModulTVC")
        let nibTugas = UINib(nibName: "TugasTVC", bundle: nil)
        tableView.register(nibTugas, forCellReuseIdentifier: "TugasTVC")
    }
}
// MARK: - IBActions

// MARK: - Private/Functions
extension GuruClassController{
    private func setNavItem(){
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationItem.title = className
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Kembali", style: .plain, target: self, action: #selector(dismissSelf))
        
        print("listofmodul.count = \(listofModul.count)")
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Tambahkan Modul", style: .plain, target: self, action: #selector(toModul))
        
        
        navigationItem.leftBarButtonItem?.tintColor = UIColor(red: 0.251, green: 0.055, blue: 0.196, alpha: 1)
        navigationItem.rightBarButtonItem?.tintColor = UIColor(red: 0.251, green: 0.055, blue: 0.196, alpha: 1)
        
        navigationController?.navigationBar.largeTitleTextAttributes =
        [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 28)]
    }
    @objc private func dismissSelf(){
        dismiss(animated: true,completion: nil)
    }
    
    @objc private func toModul(){
        let storyboard = UIStoryboard(name: "HomePage", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ModulController") as! ModulController
        vc.modalPresentationStyle = .pageSheet
        let nav =  UINavigationController(rootViewController: vc)
        self.present(nav, animated: true)
    }
    
    @objc func btnTappedModul(sender: UIButton){
        let storyboard = UIStoryboard(name: "HomePage", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ModulController") as! ModulController
        vc.modalPresentationStyle = .pageSheet
        let nav =  UINavigationController(rootViewController: vc)
        self.present(nav, animated: true)
    }
    
    @objc func refresh(_ sender: Any){
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){ [self] in
            listofModul.removeAll()
            listofTugas.removeAll()
            fetchData()
            
        }
    }
    
    func showEmpty(){
        if(listofModul.count > 0 || listofTugas.count > 0){
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hiddenGuru"), object: nil)
        }
        else if(listofModul.count == 0 || listofTugas.count == 0){
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "unhiddenGuru"), object: nil)
        }
    }
    
    func fetchData(){
        modulModel.fetchModul { [self] modul in
            listofModul.append(modul)
            modulCount.modulNum += 1
            jumlahModul.append(modulCount)
            tableView.reloadData()
            showEmpty()
        }
        
        modulModel.fetchTugasGuru { [self] tugases in
            listofTugas.append(tugases)
            tugasCount.tugasNum += 1
            jumlahTugas.append(tugasCount)
            tableView.reloadData()
            showEmpty()
        }
    }
    
}

// MARK: - TableView Delegate & Datasource
extension GuruClassController:UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if(listofModul.count == 0) && (listofTugas.count == 0){
            return 0
        }
        else if(listofModul.count != 0) && (listofTugas.count != 0){
            return 2
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        50
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        let frame: CGRect = tableView.frame
        
        if(section == 0){
            //bikin + button
            let plusBtn: UIButton = UIButton(frame: CGRectMake(frame.size.width-70, 10, 30, 30))
            plusBtn.setTitle("+", for: .normal)
            plusBtn.setTitleColor(.black, for: .normal)
            plusBtn.backgroundColor = .white
            plusBtn.addTarget(self, action: #selector(GuruClassController.btnTappedModul(sender:)), for: .touchUpInside)
            headerView.addSubview(plusBtn)
        }
        
        //bikin label section
        let sectionLabel = UILabel(frame: CGRect(x: 4, y: 20, width: tableView.bounds.size.width, height: 5))
        sectionLabel.font = .systemFont(ofSize: 16, weight: .medium)
        sectionLabel.textColor = UIColor.black
        sectionLabel.text = cellTitle[section]
        sectionLabel.sizeToFit()
        headerView.addSubview(sectionLabel)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            // cari tahu BG atau meds
            if (listofTugas.count != 0 && listofModul.count != 0) {
                return listofModul.count
            }
            return 0
        } else if (section == 1){
            return listofTugas.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.section == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: "ModulTVC", for: indexPath) as! ModulTVC
            print("jumlahmodul = \(jumlahModul[indexPath.row])")
            let modul = jumlahModul[indexPath.row]
            let eachModul = listofModul[indexPath.row]
            
            cell.materiLbl.text = "\(eachModul.modulName)"
            cell.modulLbl.text = "Modul \(modul.modulNum)"
            return cell
        }
        else if(indexPath.section == 1){
            let cell = tableView.dequeueReusableCell(withIdentifier: "TugasTVC", for: indexPath) as! TugasTVC
            
            let tugas = jumlahTugas[indexPath.row]
            let eachTugas = listofTugas[indexPath.row]
            
            cell.materitugasLbl.text = "\(eachTugas.tugasName)"
            cell.modultugasLbl.text = "Tugas Modul \(tugas.tugasNum)"
            return cell
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if(indexPath.section == 0){
            return .delete
        }else{
            return .none
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let eachModul = listofModul[indexPath.row]
        let storageRef = Storage.storage().reference().child(eachModul.modulFile)
        
        if(editingStyle == .delete){
            
            let batch = db.batch()
            let dispatchGroup = DispatchGroup()
            
            
            //delete field Modul
            dispatchGroup.enter()
            db.collection("modul").whereField("modulid", isEqualTo: eachModul.modulid).getDocuments { [self] (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                } else {
                    for document in querySnapshot!.documents {
                        let modulDocRef = db.collection("modul").document(document.documentID)
                        //delete the document of the spesific collection
                        batch.deleteDocument(modulDocRef)
                        
                        storageRef.delete { error in
                            if let error = error{
                                print("Error deleting files \(error)")
                            }else{
                                print("file deleted sucessfully!")
                            }
                        }
                    }
                }
                dispatchGroup.leave()
            }
            
            //delete field tugas
            dispatchGroup.enter()
            db.collection("muridTugas").whereField("modulid", isEqualTo: eachModul.modulid).getDocuments { [self] (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                } else {
                    for document in querySnapshot!.documents {
                        let muridTugasDocRef = db.collection("muridTugas").document(document.documentID)
                        batch.deleteDocument(muridTugasDocRef)
                        
//                        guard let tugasFile = document.get("fileTugas") as? String else {
//                                    print("Error: tugasFile field not found in Tugas document.")
//                                    continue
//                                }
//                        let tugasFileRef = Storage.storage().reference(forURL: tugasFile)
//
//                        tugasFileRef.delete { error in
//                            if let error = error{
//                                print("Error deleting tugasFile: \(error)")
//                            }else{
//                                print("All pdf deleted sucesfully!")
//                            }
//                        }
                    }
                }
                dispatchGroup.leave()
            }
            
            dispatchGroup.enter()
            //Decrease the amount of Modul in Homepage
            db.collection("class")
                .whereField("classid", isEqualTo: eachModul.classid)
                .getDocuments { (querySnapshot, err) in
                    if let err = err {
                        print("error class")
                        // Some error occured
                    }else {
                        let document = querySnapshot!.documents.first
                        document!.reference.updateData([
                            "modulCount": FieldValue.increment(Int64(-1))
                        ])
                    }
                    dispatchGroup.leave()
                }
            
            //wait for all the getDocuments() calls completed
            dispatchGroup.notify(queue: .main) {
                //commit batch
                batch.commit() { error in
                    if let error = error {
                        print("Error writing batched updates: \(error)")
                    }else {
                        print("Batched updates successful!")
                    }
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1){ [self] in
                listofModul.removeAll()
                listofTugas.removeAll()
                fetchData()
                self.tableView.reloadData()
            }
            showEmpty()
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshData"), object: nil)
            
            print("delete item")
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let eachModul = listofModul[indexPath.row]
        
        SelectedModul.selectedModul.modulPath = eachModul.modulid
        print("SelectedModul.selectedModul.modulPath adalah = \(SelectedModul.selectedModul.modulPath)")
        if(indexPath.section == 1){
            let storyboard = UIStoryboard(name: "HomePage", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "KumpulanTugasController") as! KumpulanTugasController
            vc.modalPresentationStyle = .fullScreen
            let nav =  UINavigationController(rootViewController: vc)
            self.present(nav, animated: true)
        }
    }
    
    
    
    
}
