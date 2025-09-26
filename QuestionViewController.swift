//
//  QuestionViewController.swift
//  AI_Noise_Remover_APP
//
//  Created by PGNV on 17/09/25.
//

import UIKit

class QuestionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        nextBtn.isHidden = true
    }
    
    var questionsClicked = ["1_h","2_h","3_h","4_h","5_h","6_h"]
    var questionsUnclicked = ["1","2","3","4","5","6"]
    var selectedIndex: IndexPath?

    
    @IBAction func nextButton(_ sender: UIButton) {
        let introVC = storyboard?.instantiateViewController(withIdentifier: "IntroViewController") as! IntroViewController
        self.navigationController?.pushViewController(introVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questionsClicked.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tablecell", for: indexPath) as! QuestionTableViewCell
        cell.selectionStyle = .none
            
            if selectedIndex == indexPath {
                cell.imgView.image = UIImage(named: questionsClicked[indexPath.row])
            } else {
                cell.imgView.image = UIImage(named: questionsUnclicked[indexPath.row])
            }
            return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        if selectedIndex == indexPath {
                selectedIndex = nil
                nextBtn.isHidden = true
            } else {
                selectedIndex = indexPath
                nextBtn.isHidden = false
            }
        tableView.reloadData()
    }
    
}
