//
//  AppCoordinator.swift
//  Freelancer
//
//  Created by Kais Segni on 14/06/2021.
//

import SwiftUI
import UIKit

class AppCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        goToProjectList()
    }

    func goToProjectDetailsViewController(_ project: ProjectDTO) {
        let projectDetailsViewController = ProjectDetailsViewController() // .instantiate()
        projectDetailsViewController.coordinator = self
        projectDetailsViewController.project = project
        // Why animate false? Animations are good for UX
        navigationController.pushViewController(projectDetailsViewController, animated: false)
    }

    func goToProjectList() {
        let projectTableViewController = ProjectTableViewController.instantiate()
        projectTableViewController.coordinator = self
        // Why animate false? Animations are good for UX
        navigationController.pushViewController(projectTableViewController, animated: false)
    }

    func goToProjectArchive() {

        let listView = ArchivedProjectsListView()
        let hostingController = UIHostingController(rootView: listView)
        navigationController.pushViewController(hostingController, animated: true)
    }

    func goToProjectDetailsView(_ project: ProjectDTO) {
        let detailsView = ProjectDetailsView(coordinator: self, project: project)
        let hostingController = UIHostingController(rootView: detailsView)
        navigationController.pushViewController(hostingController, animated: true)
    }

    func didFinish(_ coordinator: Coordinator) {
        childCoordinators.removeAll(where: { $0 === coordinator })
    }
}
