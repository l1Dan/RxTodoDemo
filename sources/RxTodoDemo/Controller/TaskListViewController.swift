//
//  TaskListViewController.swift
//  RxTodoDemo
//
//  Created by Leo on 2019/3/12.
//  Copyright © 2019 Leo. All rights reserved.
//

import UIKit

class TaskListViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = editButtonItem
        navigationItem.rightBarButtonItem = addButtonItem
        
        view.backgroundColor = .white
        view.addSubview(tableView)
        
        addButtonItem.rx.tap.asObservable().subscribe(onNext: { [weak self] in
            self?.updateTask(nil, at: nil)
        }).disposed(by: disposeBag)
        
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: true)
        tableView.isEditing = editing
        addButtonItem.isEnabled = !editing
    }
    
    private lazy var addButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
    private lazy var items = UserDefaultsManager.exportTasks() ?? Task.list
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: UIScreen.main.bounds, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.allowsSelectionDuringEditing = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        return tableView
    }()

}

extension TaskListViewController {
    
    private func updateTask(_ task: Task?, at indexPath: IndexPath?) {
        let viewController = TaskEditViewController()
        task.map { viewController.task = $0 }

        let navigationController = UINavigationController(rootViewController: viewController)
        present(navigationController, animated: true)
        
        viewController.callback = { [weak self] task in
            guard let self = self else { return }
       
            if let current = indexPath {
                self.items[current.row].title = task.title
            } else {
                self.items.append(task)
            }
            UserDefaultsManager.importTasks(self.items)
            self.tableView.reloadData()
        }
    }
    
}

extension TaskListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") else {
            return UITableViewCell()
        }
        cell.textLabel?.text = items[indexPath.row].title
        cell.accessoryType = items[indexPath.row].isSelected ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            updateTask(items[indexPath.row], at: indexPath)
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
            items[indexPath.row].isSelected = !items[indexPath.row].isSelected
            tableView.reloadData()
            UserDefaultsManager.importTasks(items)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            items.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        default: debugPrint("None.")
        }
        
        UserDefaultsManager.importTasks(items)
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        items.swapAt(sourceIndexPath.row, destinationIndexPath.row)
        tableView.moveRow(at: sourceIndexPath, to: destinationIndexPath)
        UserDefaultsManager.importTasks(items)
    }
    
}
