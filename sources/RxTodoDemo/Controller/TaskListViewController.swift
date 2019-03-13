//
//  TaskListViewController.swift
//  RxTodoDemo
//
//  Created by Leo on 2019/3/12.
//  Copyright © 2019 Leo. All rights reserved.
//

import UIKit
import RxCocoa

class TaskListViewController: BaseViewController {

    private lazy var addButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
    private lazy var items = BehaviorRelay(value: UserDefaultsManager.exportTasks() ?? Task.list)
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: UIScreen.main.bounds, style: .plain)
        tableView.tableFooterView = UIView()
        tableView.allowsSelectionDuringEditing = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = editButtonItem
        navigationItem.rightBarButtonItem = addButtonItem
        
        view.backgroundColor = .white
        view.addSubview(tableView)
        
        addButtonItem.rx.tap.asObservable().subscribe(onNext: { [weak self] in
            self?.updateTask(nil, at: nil)
        }).disposed(by: disposeBag)
        
        items.subscribe(onNext: { items in
            UserDefaultsManager.importTasks(items)
        }).disposed(by: disposeBag)
        
        items.bind(to: tableView.rx.items(cellIdentifier: "Cell", cellType: UITableViewCell.self)) { (row, item, cell) in
            cell.textLabel?.text = item.title
            cell.accessoryType = item.isSelected ? .checkmark : .none
        }.disposed(by: disposeBag)
        
        tableView.rx.itemSelected.subscribe(onNext: { [weak self] indexPath in
            guard let self = self else { return }
            
            let items = self.items.value
            if self.tableView.isEditing {
                self.updateTask(items[indexPath.row], at: indexPath)
            } else {
                self.tableView.deselectRow(at: indexPath, animated: true)
                items[indexPath.row].isSelected = !items[indexPath.row].isSelected
            }
        }).disposed(by: disposeBag)
        
        tableView.rx.itemMoved.subscribe(onNext: { [weak self] (sourceIndexPath, destinationIndexPath) in
            guard let self = self else { return }
            
            var items = self.items.value
            let source = items[sourceIndexPath.row]
            items.remove(at: sourceIndexPath.row)
            items.insert(source, at: destinationIndexPath.row)
            self.items.accept(items)
        }).disposed(by: disposeBag)
        
        tableView.rx.itemDeleted.subscribe(onNext: { [weak self] indexPath in
            guard let self = self, let editingStyle = self.tableView.cellForRow(at: indexPath)?.editingStyle else { return }
            
            var items = self.items.value
            switch editingStyle {
            case .delete:
                items.remove(at: indexPath.row)
                self.items.accept(items)
            default: debugPrint("None Ops.")
            }
        }).disposed(by: disposeBag)
        
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: true)
        tableView.isEditing = editing
        addButtonItem.isEnabled = !editing
    }

}

extension TaskListViewController {
    
    private func updateTask(_ task: Task?, at indexPath: IndexPath?) {
        let viewController = TaskEditViewController()
        task.map { viewController.task = $0 }

        let navigationController = UINavigationController(rootViewController: viewController)
        present(navigationController, animated: true)
        
        viewController.callback = { [weak self] task in
            guard let self = self else { return }
       
            var items = self.items.value
            if let current = indexPath {
                items[current.row].title = task.title
            } else {
                items.append(task)
            }
            self.items.accept(items)
        }
    }
    
}
