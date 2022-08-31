//
//  ProjectDetailsViewController.swift
//  Freelancer
//
//  Created by Kais Segni on 14/06/2021.
//

import SnapKit
import UIKit

// 2. TODO: - Use UIKit to implement ProjectDetailsViewController

class ProjectDetailsViewController: UIViewController, StoryboardInitilizer {
    weak var coordinator: AppCoordinator?
    var project: ProjectDTO!
    weak var timeSpentValueLabel: UILabel!
    weak var buttonStartProgress: UIButton!
    weak var descriptionTextView: UITextView!
    weak var buttonSave: UIButton!
    weak var projectDoneSwitch: UISwitch!

    let projectDetailsViewModel = ProjectDetailsViewModel()
    let projectViewModel = ProjectViewModel()

    enum State {
        case started
        case stopped
    }

    var buttonState: State = .stopped

    // MARK: LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = project.name
        navigationItem.hidesBackButton = false
        descriptionTextView.addDoneButton(
            title: "Done".localized,
            target: self,
            selector: #selector(tapDone(sender:))
        )
    }

    override func loadView() {
        super.loadView()
        createUI()
        view.backgroundColor = .systemBackground
        buttonStartProgress.style()
        buttonSave.style()
        descriptionTextView.style()
        projectDoneSwitch.isOn = project.completed
        // no support for Localization using the String.localized extension?
        timeSpentValueLabel.text = String("\(projectViewModel.timeSpent(project)) hours")
    }

    func createUI() {
        let mainScrollView = createScrollView()
        let timeSpentStackView = createTimeSpentStackView()
        let startStackView = createStartStackView()
        let descriptionStackView = createDescriptionStackView()
        let markDoneStackView = createMarkDoneStackView()
        let saveStackView = createSaveStackView()
        let mainStackView = UIStackView(arrangedSubviews: [
            timeSpentStackView,
            startStackView,
            descriptionStackView,
            markDoneStackView,
            saveStackView
        ])
        mainStackView.axis = .vertical
        mainStackView.distribution = .equalSpacing
        mainScrollView.addSubview(mainStackView)
        mainStackView.snp.makeConstraints { maker in
            maker.leading.equalTo(mainScrollView).offset(20)
            maker.trailing.equalTo(mainScrollView).offset(-20)
            maker.top.equalTo(mainScrollView).offset(20)
            maker.bottom.equalTo(mainScrollView).offset(-20)
            // The current design is not making too much sense:
            // there is a scrollView with one big stackView centered on X and Y axis to it
            // Because of this, the scrollView will not be scrollable.
            // If the UI would be minimal, as it is now - with an UITextView having 205.5 in height, I would
            // just remove the scroll view and just center the stackView to the main view.
            // Alternative solution would be to define:
            // - stackView.width.equalTo(view)
            // - stackView.height.greaterThanOrEaqualTo(view)
            // Also, I would also do one UX improvement for the kayboard overlapping the UI:
            // - set mainScrollView.keyboardDismissMode = .onDrag to alow the user to see the
            // rest of the view content, without the keyboard overlapping most of the UI
            // - change to scrollView bottom insets to make the descriptionTextView centered to the available
            // screen size when the keyaboard appears.
            maker.center.equalTo(mainScrollView)
        }
    }

    func createScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { maker in
            maker.leading.equalToSuperview()
            maker.trailing.equalToSuperview()
            maker.top.equalTo(self.view.safeAreaLayoutGuide)
            maker.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }
        return scrollView
    }

    func createTimeSpentStackView() -> UIStackView {
        let timeSpentLabel = UILabel()
        timeSpentLabel.text = "Time spent:".localized

        let valueLabel = UILabel()
        timeSpentValueLabel = valueLabel

        let stackView = UIStackView(arrangedSubviews: [timeSpentLabel, timeSpentValueLabel])
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        return stackView
    }

    func createStartStackView() -> UIStackView {
        let button = UIButton()
        button.setTitle("Start progress".localized, for: .normal)
        button.addTarget(self, action: #selector(handleStartProgressTap), for: .touchUpInside)
        buttonStartProgress = button
        let stackView = UIStackView(arrangedSubviews: [button])
        stackView.axis = .vertical
        return stackView
    }

    func createDescriptionStackView() -> UIStackView {
        let label = UILabel()
        label.text = "Description".localized

        let textView = UITextView()
        textView.text = "Session description".localized
        textView.snp.makeConstraints { make in
            make.height.equalTo(205.5)
        }
        descriptionTextView = textView

        let stackView = UIStackView(arrangedSubviews: [label, textView])
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        return stackView
    }

    func createMarkDoneStackView() -> UIStackView {
        let label = UILabel()
        label.text = "Mark project as done".localized

        let doneSwitch = UISwitch()
        doneSwitch.addTarget(self, action: #selector(tapDone), for: .valueChanged)
        projectDoneSwitch = doneSwitch

        let stackView = UIStackView(arrangedSubviews: [label, doneSwitch])
        stackView.axis = .horizontal
        return stackView
    }

    func createSaveStackView() -> UIStackView {
        let button = UIButton()
        button.setTitle("Save".localized, for: .normal)
        button.addTarget(self, action: #selector(saveTap), for: .touchUpInside)
        buttonSave = button

        let stackView = UIStackView(arrangedSubviews: [buttonSave])
        stackView.axis = .vertical
        return stackView
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        if buttonState == .started {
            stopProgress()
        }
        projectViewModel.updateProject(
            project.name,
            descriptionTextView.text,
            projectDoneSwitch.isOn,
            projectDetailsViewModel.sessionDuration
        )
        super.viewWillDisappear(animated)
    }

    // MARK: Actions

    @objc
    func tapDone(sender: Any) {
        view.endEditing(true)
    }

    @objc
    func handleStartProgressTap(_ sender: Any) {
        if buttonState == .stopped {
            startProgress()
        } else {
            stopProgress()
        }
    }

    @objc
    func saveTap(_ sender: Any) {
        // this is a bug.
        // In general, this is one of the issues of the AppCoordinator design pattern.
        //
        // Details screens should go back to list by calling
        // navigationController?.popViewController(animated: true)
        // instead of trying to present again the list (source view controller)
        //
        // Each ViewController should be aware from where it is being initialized and
        // how to revert to it's 'presenter' view controller.
        //
        // Doing several times the steps:
        // - List View: select one item
        // - Details view: tap save button
        // the navigationController.viewControllers stack will look like:
        // po navigationController.viewControllers
        // ▿ 10 elements
        // ▿ 0 : <Freelancer.ProjectTableViewController: 0x13bd0bb00>
        // ▿ 1 : <Freelancer.ProjectDetailsViewController: 0x1400075b0>
        // ▿ 2 : <Freelancer.ProjectTableViewController: 0x140108370>
        // ▿ 3 : <Freelancer.ProjectDetailsViewController: 0x140409350>
        // ▿ 4 : <Freelancer.ProjectTableViewController: 0x140008eb0>
        // ▿ 5 : <Freelancer.ProjectDetailsViewController: 0x14040c180>
        // ▿ 6 : <Freelancer.ProjectTableViewController: 0x14000a4a0>
        // ▿ 7 : <Freelancer.ProjectDetailsViewController: 0x1401090b0>
        // ▿ 8 : <Freelancer.ProjectTableViewController: 0x14040c8d0>
        // ▿ 9 : <Freelancer.ProjectDetailsViewController: 0x14040db20>
        coordinator?.goToProjectList()
    }

    // MARK: Helpers

    func startProgress() {
        guard buttonState == .stopped else {
            return
        }
        projectDetailsViewModel.startDate = Date()
        buttonState = .started
        buttonStartProgress.setTitle("Stop Progress".localized, for: .normal)
        buttonStartProgress.backgroundColor = Theme.Color.buttonStateStoped
    }

    func stopProgress() {
        // The validation of the buttonState is missing:
        // guard buttonState == .started else {
        //    return
        // }
        // This is not a big issue, since the buttonState value is verified prior to method call
        // but for the code alignment it should be present since it is present in the startProgress() method.
        let calendar = Calendar.current
        let date = calendar.date(byAdding: .minute, value: 60, to: Date())
        projectDetailsViewModel.endDate = date
        buttonState = .stopped
        buttonStartProgress.setTitle("Start Progress".localized, for: .normal)
        let duration = projectViewModel.timeSpent(project) + projectDetailsViewModel.sessionDuration
        // no support for Localization using the String.localized extension?
        timeSpentValueLabel.text = "\(duration) hours"
        buttonStartProgress.backgroundColor = Theme.Color.buttonStateStarted
    }
}
