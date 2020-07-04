//
//  HomeVC.swift
//  NetLet
//
//  Created by Mohammed Yusuf Mitha on 02/03/20.
//  Copyright © 2020 Mohammed Yusuf Mitha. All rights reserved.
//

import UIKit
import Stevia
import Alamofire

class HomeVC: Base {

    var myTableView = UITableView()
    var reportIssueButton = UIButton()
    var reportedButton = UIButton()
    var approvedButton = UIButton()
    
    var currentButton : UIButton?
    
    var fetchedAppointments : AppointmentModel?
    var refreshControl = UIRefreshControl()

    var logoutButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(isloggedin == false){
            let dest = LoginVC()
            self.navigationController?.pushViewController(dest, animated: true)
        } else{
            token = UserDefaults.standard.string(forKey: "token")!
        }
        setUpView()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchIssues()
    }
    func setUpView(){
        self.view.backgroundColor = myBackgroundColor

        self.view.addSubview(myTableView)
        myTableView.translatesAutoresizingMaskIntoConstraints = false
        
     
        
        myTableView.fillHorizontally()
        myTableView.topAnchor.constraint(equalTo: topBar.bottomAnchor).isActive = true
        myTableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        myTableView.register(HomeCV.self, forCellReuseIdentifier: "HomeCV")
        myTableView.showsVerticalScrollIndicator = false
        myTableView.showsHorizontalScrollIndicator = false
        myTableView.delegate = self
        myTableView.dataSource = self
        myTableView.rowHeight = UITableView.automaticDimension
        myTableView.estimatedRowHeight = 10
        topBar.title.text = "Appointments"
        
        topBar.addSubview(reportIssueButton)
        reportIssueButton.translatesAutoresizingMaskIntoConstraints = false

        reportIssueButton.topAnchor.constraint(equalTo: topBar.topAnchor).isActive = true
        reportIssueButton.trailingAnchor.constraint(equalTo: topBar.trailingAnchor,constant: -10*iPhoneFactorX).isActive = true
        reportIssueButton.bottomAnchor.constraint(equalTo: topBar.bottomAnchor).isActive = true
        reportIssueButton.adjustDefaultButton(fontColor: "#FF6347", fontSize: 15, fontType: "2")
        reportIssueButton.setTitle("Add", for: .normal)
        reportIssueButton.addTarget(self, action: #selector(reportIssueButtonAction), for: .touchUpInside)
 
        
        topBar.addSubview(logoutButton)
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        
        logoutButton.topAnchor.constraint(equalTo: topBar.topAnchor).isActive = true
        logoutButton.leadingAnchor.constraint(equalTo: topBar.leadingAnchor,constant: 10*iPhoneFactorX).isActive = true
        logoutButton.bottomAnchor.constraint(equalTo: topBar.bottomAnchor).isActive = true
        logoutButton.adjustDefaultButton(fontColor: "#FF6347", fontSize: 15, fontType: "2")
        logoutButton.setTitle("LOG OUT", for: .normal)
        logoutButton.addTarget(self, action: #selector(logoutButtonAction), for: .touchUpInside)
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        myTableView.addSubview(refreshControl) 
    }
    @objc func refresh() {
       fetchIssues()
    }
    
    @objc func logoutButtonAction(){
        
        isloggedin = false
        token = ""
        
        UserDefaults.standard.set(false, forKey: "isloggedin")
        UserDefaults.standard.set("", forKey: "token")
        UserDefaults.standard.synchronize()
        
        let dest = LoginVC()
        self.navigationController?.pushViewController(dest, animated: true)
        
    }
    func fetchIssues(){
    fetchAppointments()
    }
    
    @objc func reportedButtonAction(){
//        selectButton(reportedButton)
//        deselectButton(approvedButton)
    }
    @objc func approvedButtonAction(){
//        selectButton(approvedButton)
//        deselectButton(reportedButton)
    }
    
    
    
    @objc func reportIssueButtonAction(){
         //write adding appointment code here
        let dest = appointmentPopUpVC()
        dest.modalPresentationStyle = .overCurrentContext
        dest.modalTransitionStyle = .crossDissolve
        self.present(dest, animated: true)
    }
    func fetchAppointments(){
        API.callDictionaryAPI(webserviceFor: StringIdentifiers.fetchAppointment, webMethod: .get, parameters: [:]) { (error, task) in
            self.refreshControl.endRefreshing()
            if let task = task as? AppointmentModel{
                self.fetchedAppointments = task
                self.myTableView.reloadData()
            }
            
        }
    }
}
extension HomeVC : UITableViewDataSource, UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedAppointments?.appointments?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HomeCV", for: indexPath) as? HomeCV else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        cell.setUpView(fetchedAppointments?.appointments?[indexPath.row])
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dest = appointmentPopUpVC()
        dest.appointmentObject = fetchedAppointments?.appointments?[indexPath.row]
        dest.modalPresentationStyle = .overCurrentContext
        dest.modalTransitionStyle = .crossDissolve
        self.present(dest, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
 
            AF.request("http://192.168.8.103/clinic/api/doctor/deleteAppointment/\(fetchedAppointments!.appointments![indexPath.row].id! ?? 0)", method:.delete, parameters: [:], encoding: JSONEncoding.default, headers: ["Authorization": token])
                .responseJSON { (response) in
                    self.fetchIssues()
                    
                    
            }
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
}
