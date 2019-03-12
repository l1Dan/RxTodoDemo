//
//  TaskEditViewController.swift
//  RxTodoDemo
//
//  Created by Leo on 2019/3/12.
//  Copyright © 2019 Leo. All rights reserved.
//

import UIKit

class TaskEditViewController: UIViewController {

    var task: Task?
    var callback: ((Task?) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = cancelButtonItem
        navigationItem.rightBarButtonItem = doneButtonItem
        
        view.backgroundColor = .white
        view.addSubview(titleInput)
        
        titleInput.translatesAutoresizingMaskIntoConstraints = false
        titleInput.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 15).isActive = true
        titleInput.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        titleInput.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(titleInputTextDidChangeNotification(_:)), name: UITextField.textDidChangeNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        titleInput.becomeFirstResponder()
        titleInput.text = task?.title
        titleInput.text.map { doneButtonItem.isEnabled = $0.count > 0 }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        titleInput.resignFirstResponder()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private lazy var cancelButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(clickCancelButtonItem(_:)))
    private lazy var doneButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(clickDoneButtonItem(_:)))
    
    private lazy var titleInput: UITextField = {
        let titleInput = UITextField()
        titleInput.autocorrectionType = .no
        titleInput.borderStyle = .roundedRect
        titleInput.font = UIFont.systemFont(ofSize: 14)
        titleInput.textColor = .black
        titleInput.tintColor = .lightGray
        titleInput.placeholder = "Add Todo list."
        return titleInput
    }()

}

@objc
extension TaskEditViewController {
    
    private func titleInputTextDidChangeNotification(_ note: Notification) {
        titleInput.text.map { doneButtonItem.isEnabled = $0.count > 0 }
    }
    
    private func clickCancelButtonItem(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    private func clickDoneButtonItem(_ sender: UIBarButtonItem) {
        clickCancelButtonItem(sender)
        titleInput.text.map { task = task ?? Task(title:$0) }
        task?.title = titleInput.text ?? ""
        callback?(task)
    }
    
}
