//
//  MuridClassController.swift
//  skripsi
//
//  Created by Hanz Christian on 05/03/23.
//

import UIKit

class MuridClassController: UIViewController{
    
    // MARK: - Variables & Outlet
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var descClassLbl: UILabel!
    
    var selectedIdx: IndexPath = IndexPath(row: 20, section: 0)
    var previousIdx: IndexPath?
    var classModel = ClassModel()
    var modulModel = ModulModel()
    var listofModul = [Modul]()
    var jumlahModul = [JumlahModul]()
    
    var modulCount = JumlahModul(modulNum: 0)
    var className: String?
    var classDesc: String?
    var takeURL: String?
    
}
// MARK: - View Life Cycle
extension MuridClassController{
    override func viewDidLoad(){
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        DispatchQueue.main.async{ [self] in
            modulModel.fetchModul { [self] modul in
                listofModul.append(modul)
                modulCount.modulNum += 1
                jumlahModul.append(modulCount)
                tableView.reloadData()
            }
        }

        classModel.fetchSelectedClass { [self] classess in
            className = classess.className
            classDesc = classess.classDesc
            
            descClassLbl.text = classDesc
            setNavItem()
        }
    
        let nibMurid = UINib(nibName: "ExpandableTVC", bundle: nil)
        tableView.register(nibMurid, forCellReuseIdentifier: "ExpandableTVC")
    }
}
// MARK: - IBActions

// MARK: - Private/Functions
extension MuridClassController{
    private func setNavItem(){
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationItem.title = className
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Kembali", style: .plain, target: self, action: #selector(dismissSelf))
        
        navigationItem.leftBarButtonItem?.tintColor = UIColor(red: 0.251, green: 0.055, blue: 0.196, alpha: 1)
        
        navigationController?.navigationBar.largeTitleTextAttributes =
        [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 28)]
    }
    @objc private func dismissSelf(){
        dismiss(animated: true,completion: nil)
    }
    
    
}
// MARK: - TableView Delegate & Datasource
extension MuridClassController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listofModul.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExpandableTVC", for: indexPath) as! ExpandableTVC
        
        let modul = jumlahModul[indexPath.row]
        let eachModul = listofModul[indexPath.row]
        
        SelectedModul.selectedModul.modulPath = eachModul.modulid
        cell.modulNumLbl.text = "Modul \(modul.modulNum)"
        cell.modulNameLbl.text = "\(eachModul.modulName)"
        cell.modulDescLbl.text = "\(eachModul.modulDesc)"
        
        //fix font for Button
        
        let attrFont = UIFont.boldSystemFont(ofSize: 14)
        let titlePdf = "Pdf bab \(modul.modulNum)"
        let titleTugas = "Tugas bab \(modul.modulNum)"
        let attrTitle = NSAttributedString(string: titlePdf, attributes: [NSAttributedString.Key.font: attrFont])
        let attrTitle2 = NSAttributedString(string: titleTugas, attributes: [NSAttributedString.Key.font: attrFont])

        cell.modulPdfBtn.setAttributedTitle(attrTitle, for: UIControl.State.normal)
        cell.tugasBtn.setAttributedTitle(attrTitle2, for: UIControl.State.normal)
        
        cell.selectionStyle = .none
        cell.makeSheet = { [weak self] in
            let storyboard = UIStoryboard(name: "HomePage", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "InputTugasController") as! InputTugasController
            vc.modalPresentationStyle = .fullScreen
            let nav =  UINavigationController(rootViewController: vc)
            
            if let sheet = nav.presentationController as? UISheetPresentationController{
                sheet.detents = [.medium()]
                sheet.preferredCornerRadius = 15
                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            }
            SelectedModul.selectedModul.modulPath = eachModul.modulid
            SelectedIdx.selectedIdx.indexPath.row = indexPath.row
            self!.present(nav,animated: true)
        }
        
        //        cell.animate()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(selectedIdx == indexPath){
            return 280
        }
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIdx = indexPath
        
        tableView.beginUpdates()
        tableView.reloadRows(at: [indexPath], with: .none)
        tableView.endUpdates()
    }
    
}

