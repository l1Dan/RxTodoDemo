//
//  UserDefaultsManager.swift
//  RxTodoDemo
//
//  Created by Leo on 2019/3/12.
//  Copyright © 2019 Leo. All rights reserved.
//

import Foundation

struct UserDefaultsManager {
    
}

extension UserDefaultsManager {
    
    private static let tasksKey = "com.l1dan.task.key"
    
    static func importTasks(_ tasks: [Task]) {
        let info = tasks.map { ["title": $0.title, "isSelected": $0.isSelected] }
        UserDefaults.standard.set(info, forKey: tasksKey)
        UserDefaults.standard.synchronize()
    }
    
    static func exportTasks() -> [Task]? {
        guard let info = UserDefaults.standard.value(forKey: tasksKey)
            as? [[String: Any]] else {
                return nil
        }
        return info.map { Task(title: ($0["title"] as? String) ?? "", isSelected: ($0["isSelected"] as? Bool) ?? false) }
    }
    
}
