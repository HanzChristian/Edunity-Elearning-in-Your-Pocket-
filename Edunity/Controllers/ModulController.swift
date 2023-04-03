//
//  ModulController.swift
//  skripsi
//
//  Created by Hanz Christian on 07/03/23.
//

import UIKit
import MobileCoreServices
import UniformTypeIdentifiers
import FirebaseFirestore
import FirebaseStorage

class ModulController: UIViewController {
    // MARK: - Variables & Outlet
    @IBOutlet weak var tableView: UITableView!
    let cellTitle = ["Nama Modul", "Deskripsi Modul","Nama Tugas","Deskripsi Tugas","Upload File Modul"]
    var height = 52.0
    let storageRef = Storage.storage().reference()
    var path = ""
    var fileRef: StorageReference? = nil
    let db = Firestore.firestore()
    var counter = 0
    var tugasNameTVC = TugasNameTVC()
    var tugasDescTVC = TugasDescriptionTVC()
    
    var displayURL: String?
    var fullURL: String?
    var extractURL: URL?
    var classid : String?
    var classname: String?
    var numModul: Int?
    
    var modulNameTVC: ModulNameTVC?
    var modulDescriptionTVC: ModulDescriptionTVC?
    var classModel = ClassModel()
    
}
// MARK: - View Life Cycle
extension ModulController{
    override func viewDidLoad(){
        super.viewDidLoad()
        
        //dismiss gesture
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:)))
        view.addGestureRecognizer(tapGesture)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        classModel.fetchSelectedClass { [self] classess in
            classid = classess.classid
            classname = classess.className
            
            print("ini classid = \(classid)")
            setNavItem()
        }
        
        
        let nibModulName = UINib(nibName: "ModulNameTVC", bundle: nil)
        tableView.register(nibModulName, forCellReuseIdentifier: "ModulNameTVC")
        let nibModulDescription = UINib(nibName: "ModulDescriptionTVC", bundle: nil)
        tableView.register(nibModulDescription, forCellReuseIdentifier: "ModulDescriptionTVC")
        let nibTugasName = UINib(nibName: "TugasNameTVC", bundle: nil)
        tableView.register(nibTugasName, forCellReuseIdentifier: "TugasNameTVC")
        let nibTugasDescription = UINib(nibName: "TugasDescriptionTVC", bundle: nil)
        tableView.register(nibTugasDescription, forCellReuseIdentifier: "TugasDescriptionTVC")
        let nibUploadFile = UINib(nibName: "UploadTVC", bundle: nil)
        tableView.register(nibUploadFile, forCellReuseIdentifier: "UploadTVC")
        
        
    }
}
// MARK: - IBActions

// MARK: - Private/Functions
extension ModulController{
    private func setNavItem(){
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationItem.title = "Modul \(classname!)"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Batal", style: .plain, target: self, action: #selector(dismissSelf))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Simpan", style: .plain, target: self, action: #selector(saveItem))
        
        navigationItem.leftBarButtonItem?.tintColor = UIColor(red: 0.251, green: 0.055, blue: 0.196, alpha: 1)
        navigationItem.rightBarButtonItem?.tintColor = UIColor(red: 0.251, green: 0.055, blue: 0.196, alpha: 1)
        navigationController?.navigationBar.largeTitleTextAttributes =
        [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 28)]
    }
    
    @objc private func dismissSelf(){
        dismiss(animated: true,completion: nil)
    }
    
    @objc private func saveItem(){
        
        let modulid = "\(UUID().uuidString)"
        let tugasid = "\(UUID().uuidString)"

        let path = "pdf/\(displayURL!)"
        print("ini adalah pathnya ! = \(path)")
            
            if let nameModul = modulNameTVC?.nameTF.text,!nameModul.isEmpty,let descModul = modulDescriptionTVC?.descTV.text,!descModul.isEmpty,let nameTugas = tugasNameTVC.tugasNameTV.text,!nameTugas.isEmpty, let descTugas = tugasDescTVC.tugasDescTVC.text,!descTugas.isEmpty{
            storeData(nameModul: nameModul, descModul: descModul, fileModul: path, classid: classid!,modulid: modulid,nameTugas: nameTugas,descTugas: descTugas,tugasid: tugasid)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshModul"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshData"), object: nil)
            dismiss(animated: true,completion: nil)
        }else{
            print("ga masuk bro")
            print("ini nama modul = \(modulNameTVC?.nameTF.text), ini desc modul = \(modulDescriptionTVC?.descTV.text), ini filemodul = \(fullURL), ini classid = \(classid)")
        }
      
    }
    
    func storeData(nameModul: String, descModul: String,fileModul: String,classid: String,modulid: String,nameTugas: String,descTugas: String,tugasid: String){
        storageRef.child("pdf/\(displayURL!)").putFile(from: extractURL!,metadata: nil){ [self]
            (_,err) in
            
            if err != nil{
                print("error disini gan \(err?.localizedDescription)")
                return
            }
            
            
            db.collection("modul").addDocument(data: [
                "nameModul": nameModul,
                "descModul": descModul,
                "fileModul": fileModul,
                "classid": classid,
                "modulid": modulid,
                "nameTugas": nameTugas,
                "descTugas": descTugas,
                "tugasid": tugasid,
                "timestamp": FieldValue.serverTimestamp()
            ])
            
            //Add Modul count to display in app
            db.collection("class")
                .whereField("classid", isEqualTo: classid)
                .getDocuments { (querySnapshot, err) in
                    if let err = err {
                        print("error class")
                        // Some error occured
                    }else {
                        let document = querySnapshot!.documents.first
                        document!.reference.updateData([
                            "modulCount": FieldValue.increment(Int64(1))
                        ])
                    }
                }
            
            db.collection("muridClass")
                .whereField("classid", isEqualTo: classid)
                .getDocuments { (querySnapshot,err) in
                if let err = err{
                    print("error murid class")
                }else{
                    let document = querySnapshot!.documents.first
                    if(document != nil){
                        document!.reference.updateData([
                            "modulCount": FieldValue.increment(Int64(1))
                        ])
                    }
                }
            }
        }
    }
    
}
// MARK: - TableView Datasource & Delegate
extension ModulController:UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0){
            return 1
        }else if (section == 1){
            return 1
        }else if (section == 2){
            return 1
        }else if(section == 3){
            return 1
        }else if(section == 4){
            return 1
        }else{
            return 5
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.section == 1){
            if(indexPath.row == 0){
                height = 80
            }
        }else if(indexPath.section == 3){
            if(indexPath.row == 0){
                height = 80
            }
        }
        else{
            height = 52
        }
        return height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.section == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: "ModulNameTVC", for: indexPath) as! ModulNameTVC
            modulNameTVC = cell
            return modulNameTVC!
        }
        else if(indexPath.section == 1){
            let cell = tableView.dequeueReusableCell(withIdentifier: "ModulDescriptionTVC", for: indexPath) as! ModulDescriptionTVC
            modulDescriptionTVC = cell
            return modulDescriptionTVC!
        }
        else if(indexPath.section == 2){
            let cell = tableView.dequeueReusableCell(withIdentifier: "TugasNameTVC",for: indexPath) as! TugasNameTVC
            tugasNameTVC = cell
            return tugasNameTVC
        }
        else if(indexPath.section == 3){
            let cell = tableView.dequeueReusableCell(withIdentifier: "TugasDescriptionTVC",for: indexPath) as! TugasDescriptionTVC
            tugasDescTVC = cell
            return tugasDescTVC
        }
        else if(indexPath.section == 4){
            let cell = tableView.dequeueReusableCell(withIdentifier: "UploadTVC", for: indexPath) as! UploadTVC
           
            cell.importFile = { [weak self] in
                let supportedTypes: [UTType] = [UTType.pdf]
                let pickerViewController = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes, asCopy: true)
                pickerViewController.delegate = self
                pickerViewController.allowsMultipleSelection = false
                pickerViewController.shouldShowFileExtensions = true
                pickerViewController.modalPresentationStyle = .fullScreen
                self!.present(pickerViewController, animated: true, completion: nil)
            }
            if(displayURL == nil){
                cell.filenameLbl.setTitle("Masukkan File", for: .normal)
            }else{
                cell.filenameLbl.setTitle("\(displayURL!)", for: .normal)
            }
            
            return cell
        }
        return UITableViewCell()
    }
    
}
// MARK: - UIDocumentPickerViewController Deleagte and such
extension ModulController:UIDocumentPickerDelegate{
    

    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let myURL = urls.first else {
            return
        }
        print("import result : \(myURL)")
        
        // extractURL to firebase Storage as URL,
        // fullURL to save in firestore,
        // displayURL to display in application
        extractURL = myURL
        fullURL = myURL.absoluteString
        displayURL = myURL.lastPathComponent
        
        self.tableView.reloadData()
    }
    

    public func documentMenu(_ documentMenu:UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .fullScreen
        present(documentPicker, animated: true, completion: nil)
    }


    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("view was cancelled")
    }
}
