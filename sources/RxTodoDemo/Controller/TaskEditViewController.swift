//
//  TaskEditViewController.swift
//  RxTodoDemo
//
//  Created by Leo on 2019/3/12.
//  Copyright © 2019 Leo. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TaskEditViewController: BaseViewController {

    var task = Task(title: "")
    var callback: ((Task) -> ())?
    
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
        
        cancelButtonItem.rx.tap.asObservable().subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            self.dismiss(animated: true)
        }).disposed(by: disposeBag)
        
        doneButtonItem.rx.tap.asObservable().subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            self.dismiss(animated: true)
            self.titleInput.text.map { self.task.title = $0 }
            self.callback?(self.task)
        }).disposed(by: disposeBag)
        
        titleInput.rx.text.orEmpty.map { $0.count > 0 }.bind(to: doneButtonItem.rx.isEnabled).disposed(by: disposeBag)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        titleInput.becomeFirstResponder()
        titleInput.text = task.title
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        titleInput.resignFirstResponder()
    }
    
    private lazy var cancelButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: nil)
    private lazy var doneButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: nil)
    
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
