//
//  TaskListViewController.swift
//  RxTodoDemo
//
//  Created by Leo on 2019/3/12.
//  Copyright © 2019 Leo. All rights reserved.
//

import UIKit

class TaskListViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = editButtonItem
        navigationItem.rightBarButtonItem = addButtonItem
        
        view.backgroundColor = .white
        view.addSubview(tableView)
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: true)
        tableView.isEditing = editing
    }
    
    private lazy var addButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(clickAddButtonItem(_:)))
    private lazy var list = UserDefaultsManager.exportTasks() ?? Task.list
    
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
        viewController.task = task
        let navigationController = UINavigationController(rootViewController: viewController)
        present(navigationController, animated: true)
        
        viewController.callback = { [weak self] task in
            guard let self = self else { return }
       
            if let currentIndexPath = indexPath {
                task.map { self.list[currentIndexPath.row].title = $0.title }
                
            } else {
                task.map { self.list.append(Task(title: $0.title)) }
            }
            UserDefaultsManager.importTasks(self.list)
            self.tableView.reloadData()
        }
    }
    
    @objc
    private func clickAddButtonItem(_ sender: UIBarButtonItem) {
        updateTask(nil, at: nil)
    }
    
}

extension TaskListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") else {
            return UITableViewCell()
        }
        cell.textLabel?.text = list[indexPath.row].title
        cell.accessoryType = list[indexPath.row].isSelected ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            updateTask(list[indexPath.row], at: indexPath)
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
            list[indexPath.row].isSelected = !list[indexPath.row].isSelected
            tableView.reloadData()
            UserDefaultsManager.importTasks(list)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            list.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        default: debugPrint("None.")
        }
        
        UserDefaultsManager.importTasks(list)
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        list.swapAt(sourceIndexPath.row, destinationIndexPath.row)
        tableView.moveRow(at: sourceIndexPath, to: destinationIndexPath)
        UserDefaultsManager.importTasks(list)
    }
    
}
