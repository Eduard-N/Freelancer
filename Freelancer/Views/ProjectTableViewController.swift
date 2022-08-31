//
//  ProjectTableViewController.swift
//  Freelancer
//
//  Created by Kais Segni on 14/06/2021.
//

import RealmSwift
import UIKit

// 3. TODO: - Use SwiftUI to implement ProjectTableViewController

class ProjectTableViewController: UITableViewController, StoryboardInitilizer {
    let viewModel = ProjectViewModel()
    weak var coordinator: AppCoordinator?
    var dataSource: ([ProjectDTO], [ProjectDTO])!

    let searchController = UISearchController(searchResultsController: nil)
    var filteredProjects: [ProjectDTO] = []

    override func loadView() {
        super.loadView()

        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search".localized
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        dataSource = viewModel.dataSource()
        viewModel.updateDataSourceHandler = { [weak self] in
            /*
             1. TODO: - call did didUpdate()
             */
            self?.didUpdate()
        }
        let addButton = UIBarButtonItem(
            title: "add".localized,
            style: .plain,
            target: self,
            action: #selector(addTapped)
        )
        navigationItem.rightBarButtonItem = addButton
        let archivedButton = UIBarButtonItem(
            title: "archived".localized,
            style: .plain,
            target: self,
            action: #selector(archivedTapped)
        )
        navigationItem.leftBarButtonItem = archivedButton
        title = "projects".localized
        tableView.tableFooterView = UIView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.bind()
    }

    override func viewWillDisappear(_ animated: Bool) {
        viewModel.unbind()
        super.viewWillDisappear(animated)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if isFiltering {
            return 1
        }
        return dataSource.1.count > 0 ? 2 : 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredProjects.count
        }
        return section == 0 ? dataSource.0.count : dataSource.1.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = project(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "project", for: indexPath)
        cell.textLabel?.text = "Project: \(data.name)"
        let timeSpent = viewModel.timeSpent(data)
        cell.detailTextLabel?.text = "Amount spent: \(timeSpent)"
        return cell
    }

    func project(at indexPath: IndexPath) -> ProjectDTO {
        if isFiltering {
            return filteredProjects[indexPath.row]
        }
        if indexPath.section == 0 {
            return dataSource.0[indexPath.row]
        } else {
            return dataSource.1[indexPath.row]
        }
    }

    override func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let deleteContextAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            let project = self.project(at: indexPath)
            self.showAlertWithTwoButtons(
                "Delete \(project.name)",
                "Are you sure you want to delete \(project.name) ?",
                okButtonTitle: "Ok", { self.viewModel.deleteProject(project) },
                cancelButtonTitle: "Cancel",
                nil
            )
        }

        let invoiceContextAction = UIContextualAction(style: .normal, title: "Invoice") { _, _, _ in
            let project = self.project(at: indexPath)
            let amount = self.viewModel.invoicedAmount(project)
            if amount > 0 {
                self.showAlertWithTwoButtons(
                    "Invoice \(project.name)",
                    "Are you sure you want to invoice \(amount) dkk ?",
                    okButtonTitle: "Ok", { self.viewModel.invoice(project) },
                    cancelButtonTitle: "Cancel",
                    nil
                )
            } else {
                self.showAlertWithOneButton(
                    "Unable to invoice amount",
                    self.viewModel.timeSpent(project) > 0 ?
                        "Amount was already invoiced" : "Log work sessions before requesting an invoice"
                )
            }
        }
        let swipeActions = UISwipeActionsConfiguration(actions: [deleteContextAction, invoiceContextAction])
        return swipeActions
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        coordinator?.goToProjectDetailsViewController(project(at: indexPath))
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isFiltering {
            return nil
        }
        var title: String?
        if section == 0 {
            if dataSource.0.count > 0 {
                title = "In progress"
            }
        }
        if section == 1 {
            if dataSource.1.count > 0 {
                title = "Completed"
            }
        }
        return title
    }

    // MARK: Helpers

    @objc private func addTapped() {
        showInputDialog(
            title: "Add project",
            subtitle: "Add project name",
            actionTitle: "Ok",
            cancelTitle: "Cancel",
            inputPlaceholder: "Project name here",
            inputKeyboardType: .asciiCapable,
            cancelHandler: nil,
            actionHandler: { name in
                if let prpjectName = name {
                    if !self.viewModel.exist(prpjectName) {
                        self.viewModel.saveProject(prpjectName, false)
                    } else {
                        self.showAlertWithOneButton(
                            "An error occured",
                            "An other project named \(prpjectName) already exist"
                        )
                    }
                }
            })
    }

    @objc
    private func archivedTapped() {
        coordinator?.goToProjectArchive()
    }

    func didUpdate() {
        dataSource = viewModel.dataSource()
        tableView.reloadData()
    }
}

extension ProjectTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filter(for: searchBar.text ?? "")
    }

    var isFiltering: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }

    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }

    func filter(for searchText: String) {
        filteredProjects = viewModel.getProjects(name: searchText)
        tableView.reloadData()
    }
}
