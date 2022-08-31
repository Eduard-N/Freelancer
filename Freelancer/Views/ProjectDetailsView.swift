//
//  ProjectDetailsView.swift
//  Freelancer
//
//  Created by Eduard Nita on 31/08/2022.
//

import SwiftUI

struct ProjectDetailsView: View {
    weak var coordinator: AppCoordinator?
    var project: ProjectDTO
    let projectDetailsViewModel = ProjectDetailsViewModel()
    let projectViewModel = ProjectViewModel()

    @State private var completed: Bool = false
    @State private var descriptionText: String = ""

    private var progressButtonColor: Color {
        if buttonState == .started {
            return Color(Theme.Color.buttonStateStoped)
        }
        return Color(Theme.Color.buttonStateStarted)
    }

    enum ButtonState {
        case started
        case stopped
    }

    @State var buttonState: ButtonState = .stopped

    var body: some View {
        VStack {
            HStack {
                Text("Time spent:".localized)
                Spacer()
                Text(durationText)
            }
            Spacer()
            Button(action: handleProgressButton) {
                Text(buttonState == .started ? "Stop progress".localized : "Start progress".localized)
                    .frame(maxWidth: .infinity)
            }
            .padding(.all, 8.0)
            .background(progressButtonColor)
            Spacer()
            VStack(alignment: .leading, spacing: 0) {
                Text("Description".localized)
                    .frame(alignment: .leading)
                TextEditor(text: $descriptionText)
                    .frame(height: 205.5, alignment: .center)
                    .shadow(color: .gray, radius: 4, x: 0, y: 0)
            }
            Spacer()
            Toggle("Mark project as done".localized, isOn: $completed)
            Spacer()
            Button(action: doSave) {
                Text("Save".localized)
                    .frame(maxWidth: .infinity)
            }
            .padding(.all, 8.0)
            .background(Color(Theme.Color.buttonStateStarted))
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .onAppear {
            completed = project.completed
        }
        .onDisappear {
            if buttonState == .started {
                stopProgress()
            }
            projectViewModel.updateProject(
                project.name,
                descriptionText,
                completed,
                projectDetailsViewModel.sessionDuration
            )
        }
    }

    // MARK: Actions

    func doSave() {
        coordinator?.goToProjectList()
    }

    func handleProgressButton() {
        if buttonState == .stopped {
            startProgress()
        } else {
            stopProgress()
        }
    }

    // MARK: Helpers

    func startProgress() {
        guard buttonState == .stopped else {
            return
        }
        projectDetailsViewModel.startDate = Date()
        buttonState = .started
    }

    func stopProgress() {
        guard buttonState == .started else {
            return
        }
        let calendar = Calendar.current
        let date = calendar.date(byAdding: .minute, value: 60, to: Date())
        projectDetailsViewModel.endDate = date
        buttonState = .stopped
    }

    var durationText: String {
        let duration = projectViewModel.timeSpent(project) + projectDetailsViewModel.sessionDuration
        return "\(duration) hours"
    }
}

struct ProjectDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectDetailsView(coordinator: nil, project: ProjectDTO())
    }
}
