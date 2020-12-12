//
//  ViewController.swift
//  CoreDataDemo
//
//  Created by Айдар Рахматуллин on 24.11.2020.
//

import UIKit
import CoreData


class TaskListViewController: UITableViewController {
    
    let context = StorageManager.shared.context
    
    private let cellID = "cell"
    var tasks: [Task] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavigationBar()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        tasks = StorageManager.shared.fetchData()

    }
    
    private func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navBarAppearance.backgroundColor = UIColor(
            red: 21/255,
            green: 101/255,
            blue: 192/255,
            alpha: 194/255
        )
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
        )
        
        navigationController?.navigationBar.tintColor = .white
    }
    
    
    @objc private func addNewTask() {
        showAlert(with: "Add New Task", and: "What do you want to do?")
    }

    
    private func editTask(at indexPath: IndexPath) {
        showEditAlert(with: "Edit Task", and: "What do you want to edit?", at: indexPath)
    }
    
    private func edit(taskName: String, indexPath: IndexPath) {

        tasks[indexPath.row].name = taskName
        tableView.reloadRows(at: [indexPath], with: .automatic)

        if context.hasChanges {
            do {
                try context.save()
            } catch let error {
                print(error)
            }
        }
    }
    
    // MARK: - TableViewDataSource & TableViewDelegate
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tasks.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = tasks[indexPath.row].name
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let task = tasks[indexPath.row]
            StorageManager.shared.delete(taskName: task, at: indexPath)
            tasks.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let edit = editAction(with: indexPath)
        return UISwipeActionsConfiguration(actions: [edit])
    }
    
    func editAction(with indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "Edit") { (_, _, completion) in
            self.editTask(at: indexPath)
            completion(true)
        }
        action.backgroundColor = .systemGray
        action.image = UIImage(systemName: "square.and.pencil")
        return action
    }
}

// MARK: - AlertControllers

extension TaskListViewController {
    
    private func showAlert(with title: String, and message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
            StorageManager.shared.save(taskName: task) { (task) in
                self.tasks.append(task)
                
                let index = IndexPath(row: self.tasks.count - 1, section: 0)
                self.tableView.insertRows(at: [index], with: .automatic)
                
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    private func showEditAlert(with title: String, and message: String, at indexPath: IndexPath) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
            self.edit(taskName: task, indexPath: indexPath)
            self.tasks[indexPath.row].name = task
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addTextField { (textField) in
            textField.text = self.tasks[indexPath.row].name }
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
}
