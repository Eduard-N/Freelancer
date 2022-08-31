//
//  FreelancerTests.swift
//  FreelancerTests
//
//  Created by Kais Segni on 10/06/2021.
//

@testable import Freelancer
import XCTest

class ProjectTests: XCTestCase {
    var viewModel: ProjectViewModel!

    let pythonProject = ProjectDTO(name: "Python", completed: false)
    let javatProject = ProjectDTO(name: "Java", completed: false)
    let swiftProject = ProjectDTO(name: "Swift", completed: false)

    override func setUp() {
        viewModel = ProjectViewModel()
        viewModel.deleteProjects()
    }

    override func tearDown() {}

    // 4. TODO: - Implement bellow tests

    func testSaveProject() {
        // given
        XCTAssert(viewModel.getProjects().count == 0, "testSaveProject must run on clean database")

        // when
        let project = pythonProject
        viewModel.saveProject(project)

        // then
        let projects = viewModel.getProjects()
        XCTAssert(projects.count == 1, "testSaveProject found projects.count != 1: \(projects.count)")
        let fetchedProject = projects.first

        XCTAssertNotNil(fetchedProject, "testSaveProject couldn't fetch items from local database")
        XCTAssert(fetchedProject?.name == project.name, "testSaveProject found saved item with different name")
        XCTAssert(
            fetchedProject?.completed == project.completed,
            "testSaveProject found saved item with invalid state"
        )
    }

    func testFetchProject() {
        // given
        XCTAssert(viewModel.getProjects().count == 0, "testFetchProject must run on clean database")
        viewModel.saveProject(pythonProject)
        viewModel.saveProject(javatProject)
        viewModel.saveProject(swiftProject)

        // when
        let projects = viewModel.getProjects(name: pythonProject.name)

        // then
        XCTAssert(
            projects.count == 1,
            "testFetchProject found incorrect number of projects: \(projects.count)"
        )
    }

    func testDeleteProject() {
        // given
        XCTAssert(viewModel.getProjects().count == 0, "testDeleteProject must run on clean database")
        viewModel.saveProject(pythonProject)
        viewModel.saveProject(javatProject)
        viewModel.saveProject(swiftProject)

        // when
        viewModel.deleteProject(javatProject)

        // then
        XCTAssertFalse(
            viewModel.exist(javatProject),
            "testDeleteProject found deleted project still in the database"
        )
    }

    func testProjectExist() {
        // given
        XCTAssert(viewModel.getProjects().count == 0, "testProjectExist must run on clean database")
        viewModel.saveProject(pythonProject)
        viewModel.saveProject(javatProject)
        viewModel.saveProject(swiftProject)

        // when
        let javaExists = viewModel.exist(javatProject)
        let pythonExists = viewModel.exist(pythonProject)
        let swiftExists = viewModel.exist(swiftProject)

        // then
        XCTAssert(javaExists, "testProjectExist didn't find javatProject")
        XCTAssert(pythonExists, "testProjectExist didn't find pythonExists")
        XCTAssert(swiftExists, "testProjectExist didn't find swiftExists")
    }

    func testFetchAllProjects() {
        // given
        XCTAssert(viewModel.getProjects().count == 0, "testFetchAllProjects must run on clean database")
        viewModel.saveProject(pythonProject)
        viewModel.saveProject(javatProject)
        viewModel.saveProject(swiftProject)

        // when
        let project = viewModel.getProjects()

        // then
        XCTAssert(project.count == 3, "testFetchAllProjects didn't contain all the saved projects")
    }

    func testFetchCompletedProjects() {
        // given
        XCTAssert(viewModel.getProjects().count == 0, "testFetchCompletedProjects must run on clean database")
        viewModel.saveProject(pythonProject)
        viewModel.saveProject(javatProject)
        viewModel.saveProject(swiftProject)

        // when
        let initialProjects = viewModel.projectRepository.fetch(
            Project.self,
            predicate: NSPredicate(format: "completed = true"),
            sorted: nil
        )
        var updatedProject = swiftProject
        updatedProject.completed = true
        viewModel.updateProject(updatedProject)
        let completedProjects = viewModel.projectRepository.fetch(
            Project.self,
            predicate: NSPredicate(format: "completed = true"),
            sorted: nil
        )

        // then
        XCTAssert(
            initialProjects.count == 0,
            "testFetchCompletedProjects found initial completed projects"
        )
        XCTAssert(
            completedProjects.count == 1,
            "testFetchCompletedProjects found different number of completed projects"
        )
    }

    func testFetchArchivedProjects() {
        // given
        XCTAssert(viewModel.getProjects().count == 0, "testFetchCompletedProjects must run on clean database")
        viewModel.saveProject(pythonProject)
        viewModel.saveProject(javatProject)
        viewModel.saveProject(swiftProject)
        
        // when
        let initialProjects = viewModel.projectRepository.fetch(
            Project.self,
            predicate: NSPredicate(format: "completed = false"),
            sorted: nil
        )
        var updatedProject = swiftProject
        updatedProject.completed = true
        viewModel.updateProject(updatedProject)
        let completedProjects = viewModel.projectRepository.fetch(
            Project.self,
            predicate: NSPredicate(format: "completed = false"),
            sorted: nil
        )
        
        // then
        XCTAssert(
            initialProjects.count == 3,
            "testFetchArchivedProjects found initial completed projects"
        )
        XCTAssert(
            completedProjects.count == 2,
            "testFetchArchivedProjects found different number of in progress projects"
        )
    }
}
