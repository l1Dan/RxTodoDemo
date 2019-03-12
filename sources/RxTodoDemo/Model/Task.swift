//
//  Task.swift
//  RxTodoDemo
//
//  Created by Leo on 2019/3/12.
//  Copyright © 2019 Leo. All rights reserved.
//

import Foundation

class Task {
    
    var title: String = ""
    var isSelected: Bool = false
    
    init(title: String, isSelected: Bool = false) {
        self.title = title
        self.isSelected = isSelected
    }
    
}

extension Task {
    
    static var list: [Task] {
        return [
            Task(title: "Go to https://github.com/devxoul"),
            Task(title: "Star repositories I am intersted in"),
            Task(title: "Make a pull request")
        ]
    }
    
}
