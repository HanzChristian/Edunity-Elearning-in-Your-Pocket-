//
//  HomePageController.swift
//  skripsi
//
//  Created by Hanz Christian on 28/02/23.
//

import UIKit
import Firebase
import FirebaseFirestore

class HomePageController: UIViewController {
    
    // MARK: - Variables & Outlet
    
    let role = UserDefaults.standard.string(forKey: "role")
    let dateFormatter = DateFormatter()
    let dates = Date()
    
    let db = Firestore.firestore()
    let userModel = UserModel()
    let classModel = ClassModel()
    var listofClass = [Class]()
    
    
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var findclassBtn: UIButton!
}

// MARK: - View Life Cycle

extension HomePageController{
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        if(listofClass.count == 0){
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "unhidden"), object: nil)
        }else{
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hidden"), object: nil)
        }

        Core.shared.notNewUser()
        self.userModel.fetchUser{user in
        }
    
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh(_:)), name: NSNotification.Name(rawValue: "refreshData"), object: nil)
        
        fetchData()
        
        if(role == "pengajar"){ //pengajar
            setBtn()
        }
        self.tableView.delegate = self
        self.tableView.dataSource = self
        tableView.separatorStyle = .none
        
        //make pull refresh view
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        
        self.tableView.refreshControl = refreshControl
        
        let nibClass = UINib(nibName: "ClassTVC", bundle: nil)
        tableView.register(nibClass, forCellReuseIdentifier: "ClassTVC")
        
        setTime()
    }
}

// MARK: - Private/Functions
extension HomePageController{
    @IBAction func btnPressed(_ sender: UIButton) {
        if (role == "pelajar"){
            let storyboard = UIStoryboard(name: "HomePage", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "FindClassController") as! FindClassController
            vc.modalPresentationStyle = .automatic
            let nav =  UINavigationController(rootViewController: vc)
            self.present(nav, animated: true)
        }else{
            let storyboard = UIStoryboard(name: "HomePage", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "MakeClassController") as! MakeClassController
            vc.modalPresentationStyle = .automatic
            let nav =  UINavigationController(rootViewController: vc)
            self.present(nav, animated: true)
        }
    }
    
    func setBtn(){
        if let attrFont = UIFont(name: "Helvetica", size: 12) {
            let title = "Bentuk Kelas"
            let attrTitle = NSAttributedString(string: title, attributes: [NSAttributedString.Key.font: attrFont])
            findclassBtn.setAttributedTitle(attrTitle, for: UIControl.State.normal)
        }
    }
    
    func fetchData(){
        if(role == "pengajar"){
            classModel.fetchClassGuru(completion: { [self] classess in
                listofClass.append(classess)
                tableView.reloadData()
                print("listofClass guru = \(listofClass.count)")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hidden"), object: nil)
            })
            
        }else if(role == "pelajar"){
            classModel.fetchClassMurid { [self] classess in
                listofClass.append(classess)
                tableView.reloadData()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hidden"), object: nil)
            }
        }
    }
    
    @objc func refresh(_ sender: Any){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7){ [self] in
            listofClass.removeAll()
            fetchData()
            self.tableView.refreshControl?.endRefreshing()
        }
    }
    
    func setTime(){
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: dates)
        let minutes = calendar.component(.minute, from: dates)
        
        let string = ("20 Jun 2022 \(hour):\(minutes):00 +0700")
        
        dateFormatter.dateFormat = "dd MMM yyyy HH:mm:ss Z"
        
        let newDate = dateFormatter.date(from: string)!
        
        //pagi
        let startMorning = ("20 Jun 2022 01:00:00 +0700")
        let endMorning = ("20 Jun 2022 11:59:00 +0700")
        
        //siang
        let startNoon = ("20 Jun 2022 12:00:00 +0700")
        let endNoon = ("20 Jun 2022 13:59:00 +0700")
        
        //sore
        let startEvening = ("20 Jun 2022 14:00:00 +0700")
        let endEvening = ("20 Jun 2022 17:59:00 +0700")
        
        
        let startMorningDate = dateFormatter.date(from: startMorning)!
        let endMorningDate = dateFormatter.date(from: endMorning)!
        let startNoonDate = dateFormatter.date(from: startNoon)!
        let endNoonDate = dateFormatter.date(from: endNoon)!
        let startEveningDate = dateFormatter.date(from: startEvening)!
        let endEveningDate = dateFormatter.date(from: endEvening)!
        
        if(newDate >= startMorningDate && newDate <= endMorningDate){
            timeLbl.text = "Selamat Pagi!"
        }
        else if(newDate >= startNoonDate && newDate <= endNoonDate){
            timeLbl.text = "Selamat Siang!"
        }
        else if(newDate >= startEveningDate && newDate <= endEveningDate){
            timeLbl.text = "Selamat Sore!"
        }else{
            timeLbl.text = "Selamat Malam!"
        }
    }
    
    
}
// MARK: - TableView Delegate & Resource
extension HomePageController:UITableViewDelegate,UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listofClass.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClassTVC", for: indexPath) as! ClassTVC
        
        
        let eachClass = listofClass[indexPath.row]
        
        cell.classImg.image = eachClass.classImg
        cell.classtitleLbl.text = eachClass.className
        cell.classmodulLbl.text = "\(eachClass.classModule) modul"
        cell.classenrollmentkeyLbl.text = "Enrollment Key : \(eachClass.classEnrollment)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 145.0
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            let separatorView = UIView(frame: CGRect(x: 0, y: cell.frame.height - 10, width: cell.frame.width, height: 10))
            separatorView.backgroundColor = UIColor(red: 250/255, green: 238/255, blue: 228/255, alpha: 1.0)
            separatorView.tag = 100
           cell.addSubview(separatorView)
       }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let eachClass = listofClass[indexPath.row]
        
        if(role == "pengajar"){
            SelectedClass.selectedClass.classPath = eachClass.classid
            SelectedIdx.selectedIdx.indexPath = indexPath
            
            self.performSegue(withIdentifier: "guruclassSegue", sender: self)
        }
        else{
            SelectedClass.selectedClass.classPath = eachClass.classid
            SelectedIdx.selectedIdx.indexPath = indexPath
            let storyboard = UIStoryboard(name: "HomePage", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "MuridClassController") as! MuridClassController
            let nav =  UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if(role == "pengajar"){
            return .delete
        }else{
            return .none
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let eachClass = listofClass[indexPath.row]
        
        let storageRef = Storage.storage().reference().child(eachClass.classImgString)
        
        if(editingStyle == .delete){
            
            
            let batch = db.batch()
            
            //wait for all getDocuments() completed
            let dispatchGroup = DispatchGroup()
            
            //delete field in Class
            dispatchGroup.enter()
            db.collection("class").whereField("classid", isEqualTo: eachClass.classid).getDocuments { [self] (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                } else {
                    for document in querySnapshot!.documents {
                        let classDocRef = db.collection("class").document(document.documentID)
                        //delete the document of the spesific collection
                        batch.deleteDocument(classDocRef)
                        
                        //delete image in storage
                        storageRef.delete { error in
                            if let error = error{
                                print("error delete img = \(error)")
                            }else{
                                print("img deleted succesfully!")
                            }
                        }
                    }
                }
                dispatchGroup.leave()
            }
            
            //delete field in Modul
            dispatchGroup.enter()
            db.collection("modul").whereField("classid", isEqualTo: eachClass.classid).getDocuments { [self] (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                } else {
                    for document in querySnapshot!.documents {
                        let modulDocRef = db.collection("modul").document(document.documentID)
                        batch.deleteDocument(modulDocRef)
                    }
                }
                dispatchGroup.leave()
            }
            
            //delete field in muridClass
            dispatchGroup.enter()
            db.collection("muridClass").whereField("classid", isEqualTo: eachClass.classid).getDocuments { [self] (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                } else {
                    for document in querySnapshot!.documents {
                        let muridClassDocRef = db.collection("muridClass").document(document.documentID)
                        batch.deleteDocument(muridClassDocRef)
                        
                        storageRef.delete { error in
                            if let error = error{
                                print("error delete img = \(error)")
                            }else{
                                print("img deleted succesfully!")
                            }
                        }
                    }
                }
                dispatchGroup.leave()
            }
            
            //delete field in muridTugas
            dispatchGroup.enter()
            db.collection("muridTugas").whereField("classid", isEqualTo: eachClass.classid).getDocuments { [self] (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                } else {
                    for document in querySnapshot!.documents {
                        let muridTugasDocRef = db.collection("muridTugas").document(document.documentID)
//                        batch.updateData(["classid": FieldValue.delete()], forDocument: muridTugasDocRef)
                        batch.deleteDocument(muridTugasDocRef)
                    }
                }
                dispatchGroup.leave()
            }
            
            //delete field in tes
            dispatchGroup.enter()
            db.collection("tes").whereField("classid", isEqualTo: eachClass.classid).getDocuments { [self] (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                } else {
                    for document in querySnapshot!.documents {
                        let tesDocRef = db.collection("tes").document(document.documentID)
                        batch.deleteDocument(tesDocRef)
                    }
                }
                dispatchGroup.leave()
            }
            
            //delete field in muridTes
            dispatchGroup.enter()
            db.collection("muridTes").whereField("classid", isEqualTo: eachClass.classid).getDocuments { [self] (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                } else {
                    for document in querySnapshot!.documents {
                        let muridTesDocRef = db.collection("muridTes").document(document.documentID)
                        batch.deleteDocument(muridTesDocRef)
                    }
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
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7){ [self] in
                listofClass.removeAll()
                fetchData()
            }
        }
    }
 
}
