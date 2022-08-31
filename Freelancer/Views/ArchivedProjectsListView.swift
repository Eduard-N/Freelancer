//
//  ArchivedProjectsListView.swift
//  Freelancer
//
//  Created by Eduard Nita on 31/08/2022.
//

import SwiftUI

class ProjectsListViewModel: ObservableObject {
    @Published var completedProjects: [ProjectDTO] = []
}

struct ArchivedProjectsListView: View {
    @ObservedObject var viewModel: ProjectViewModel = ProjectViewModel(fetchCompleted: true)

    weak var coordinator: AppCoordinator?

    var body: some View {
        List(viewModel.completedProjects) { project in
            NavigationLink {
                ProjectDetailsView(coordinator: coordinator, project: project)
            } label: {
                VStack(alignment: .leading) {
                    Text("Project: \(project.name)")
                        .font(.system(size: 15))
                    Text("Amount spent: \(viewModel.timeSpent(project))")
                        .font(.system(size: 18))
                }
                .frame(height: 80)
            }
        }
        .listStyle(.plain)
        .navigationTitle("archived".localized)
    }
}

struct ArchivedProjectsListView_Previews: PreviewProvider {
    static var previews: some View {
        ArchivedProjectsListView()
    }
}
