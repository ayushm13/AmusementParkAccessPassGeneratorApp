//
//  ViewController.swift
//  AmusementParkAccessPassGeneratorApp
//
//  Created by Abhilash Muraleedharan on 28/10/18.
//  Copyright © 2018 AbhilashApps. All rights reserved.
//

import UIKit

class AccessPassFormVC: UIViewController {
    
    // MARK: - IB Outlets
    @IBOutlet weak var containerViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var subMenuView: UIStackView!
    @IBOutlet weak var dateOfBirthLabel: UILabel!
    @IBOutlet weak var dateOfBirthTextField: UITextField!
    @IBOutlet weak var dateOfVisitLabel: UILabel!
    @IBOutlet weak var dateOfVisitTextField: UITextField!
    @IBOutlet weak var projectNumberLabel: UILabel!
    @IBOutlet weak var projectNumberTextField: UITextField!
    @IBOutlet weak var managementTierLabel: UILabel!
    @IBOutlet weak var managementTierTextField: UITextField!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var streetAddressLabel: UILabel!
    @IBOutlet weak var streetAddressTextField: UITextField!
    @IBOutlet weak var companyLabel: UILabel!
    @IBOutlet weak var companyTextField: UITextField!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var stateTextField: UITextField!
    @IBOutlet weak var zipcodeLabel: UILabel!
    @IBOutlet weak var zipcodeTextField: UITextField!
    @IBOutlet weak var generatePassButton: UIButton!
    @IBOutlet weak var populateDataButton: UIButton!
    
    // MARK: - Stored Properties
    let subMenuButtonBackgroundColor = UIColor(red: 48/255, green: 41/255, blue: 55/255, alpha: 1.0)
    let disabledLabelTextColor = UIColor.lightGray
    let enabledLabelTextColor = UIColor.black
    let dataProvider = FormDataProvider()
    let dataValidator = FormDataValidator()
    var chosenAccessPass: PassCategory?
    var chosenAccessPassSubType: PassSubType?
    var generatedAccessPass: Swipable?
    
    lazy var subMenuBlankView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = subMenuButtonBackgroundColor
        return view
    }()
    
    lazy var projectPicker: UIPickerView = {
        let picker = UIPickerView()
        picker.tag = AccessPassFormPickerView.project.tag
        picker.delegate = self
        return picker
    }()
    
    lazy var companyPicker: UIPickerView = {
        let picker = UIPickerView()
        picker.tag = AccessPassFormPickerView.company.tag
        picker.delegate = self
        return picker
    }()
    
    lazy var managementTierPicker: UIPickerView = {
        let picker = UIPickerView()
        picker.tag = AccessPassFormPickerView.managementTier.tag
        picker.delegate = self
        return picker
    }()
    
    lazy var dateOfBirthPicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        return datePicker
    }()
    
    lazy var dateOfVisitPicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        return datePicker
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // testAllParkAccessPasses()
        configureRelevantTextFieldsWithUIPickerViews()
        configureRelevantTextFieldsWithDatePickerViews()
        
        // Registering this class as an observer for the KeyboardWillShow notification.
        NotificationCenter.default.addObserver(self, selector: #selector(AccessPassFormVC.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        // Registering this class as an observer for the KeyboardWillHide notification.
        NotificationCenter.default.addObserver(self, selector: #selector(AccessPassFormVC.keyBoardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    // MARK: - IB Actions
    @IBAction func guestMenuOptionSelected(_ sender: Any) {
        deactivateForm()
        displaySubMenu(for: .guest)
        chosenAccessPass = PassCategory.guest
    }
    
    @IBAction func employeeMenuOptionSelected(_ sender: Any) {
        deactivateForm()
        displaySubMenu(for: .employee)
        chosenAccessPass = PassCategory.employee
    }
    
    @IBAction func managerMenuOptionSelected(_ sender: Any) {
        subMenuView.removeAllArrangedSubviews()
        subMenuView.addArrangedSubview(subMenuBlankView)
        deactivateForm()
        activateForm(for: .manager)
        chosenAccessPass = PassCategory.manager
        chosenAccessPassSubType = PassSubType.managerPass
    }
    
    @IBAction func contractorMenuOptionSelected(_ sender: Any) {
        subMenuView.removeAllArrangedSubviews()
        subMenuView.addArrangedSubview(subMenuBlankView)
        deactivateForm()
        activateForm(for: .contractor)
        chosenAccessPass = PassCategory.contractor
    }
    
    @IBAction func vendorMenuOptionSelected(_ sender: Any) {
        subMenuView.removeAllArrangedSubviews()
        subMenuView.addArrangedSubview(subMenuBlankView)
        deactivateForm()
        activateForm(for: .vendor)
        chosenAccessPass = PassCategory.vendor
    }
    
    @IBAction func generatePassButtonTapped(_ sender: Any) {
        validateFormDataAndGeneratePass()
    }
    
    @IBAction func populateDataButtonTapped(_ sender: Any) {
        populateFormData()
    }
    
    
    // MARK: - Methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "checkGeneratedPass" {
            guard let accessPassCheckVC = segue.destination as? AccessPassCheckVC else {
                return
            }
            accessPassCheckVC.parkAccessPass = generatedAccessPass
        }
    }
    
    func displaySubMenu(for passType: PassCategory) {
        let associatedPassSubTypes = passType.passSubTypeList
        updateSubMenuStackView(with: associatedPassSubTypes)
    }
    
    func updateSubMenuStackView(with passSubTypeList: [PassSubType]) {
        let menuButtonSubViews = prepareSubMenuButtons(using: passSubTypeList)
        subMenuView.removeAllArrangedSubviews()
        for buttonView in menuButtonSubViews {
            subMenuView.addArrangedSubview(buttonView)
        }
    }
    
    func prepareSubMenuButtons(using passSubTypesList: [PassSubType]) -> [UIButton] {
        var subMenuButtonViews = [UIButton]()
        for pass in passSubTypesList {
            let button = UIButton(type: .system)
            button.translatesAutoresizingMaskIntoConstraints = false
            let title = pass.subMenuButtonTitle ?? ""
            button.setTitle(title, for: .normal)
            button.backgroundColor = subMenuButtonBackgroundColor
            button.tintColor = UIColor.white
            if let selector = getButtonActionSelector(for: pass) {
                button.addTarget(self, action: selector, for: .touchUpInside)
            }
            subMenuButtonViews.append(button)
        }
        return subMenuButtonViews
    }
    
    func getButtonActionSelector(for passType: PassSubType) -> Selector? {
        var selector: Selector?
        switch passType {
        case .classicGuestPass: selector = #selector(AccessPassFormVC.classicGuestFormSelected)
        case .vipGuestPass: selector = #selector(AccessPassFormVC.vipGuestFormSelected)
        case .freeChildGuestPass: selector = #selector(AccessPassFormVC.freeChildGuestFormSelected)
        case .seniorGuestPass: selector = #selector(AccessPassFormVC.seniorGuestFormSelected)
        case .seasonGuestPass: selector = #selector(AccessPassFormVC.seasonPassGuestFormSelected)
        case .hourlyEmployeeMaintenancePass: selector = #selector(AccessPassFormVC.maintenanceEmployeeFormSelected)
        case .hourlyEmployeeFoodServicePass: selector = #selector(AccessPassFormVC.foodServiceEmployeeFormSelected)
        case .hourlyEmployeeRideServicePass: selector = #selector(AccessPassFormVC.rideServiceEmployeeFormSelected)
        default: selector = nil
        }
        return selector
    }
    
    func generateAccessPassUsing(dateOfBirth: String?, dateOfVisit: String?, projectNumber: String?, managementTier: String?, firstName: String?,
                                 lastName: String?, streetAddress: String?, city: String?, state: String?, zipcode: String?, company: String?,
                                 forPassCategory category: PassCategory?, forPassSubType type: PassSubType?) {
        
        if let passCategory = category {
            do {
                switch passCategory {
                case .guest:
                    if let passType = type {
                        switch passType {
                        case .classicGuestPass:
                            generatedAccessPass = try ClassicGuestPass(firstName: firstName, lastName: lastName, dateOfBirth: getDate(fromString: dateOfBirth), streetAddress: streetAddress, city: city, state: state, zipcode: zipcode)
                        case .vipGuestPass:
                            generatedAccessPass = try VIPGuestPass(firstName: firstName, lastName: lastName, dateOfBirth: getDate(fromString: dateOfBirth), streetAddress: streetAddress, city: city, state: state, zipcode: zipcode)
                        case .freeChildGuestPass:
                            generatedAccessPass = try FreeChildGuestPass(dateOfBirth: getDate(fromString: dateOfBirth), firstName: firstName, lastName: lastName, streetAddress: streetAddress, city: city, state: state, zipcode: zipcode)
                        case .seasonGuestPass:
                            generatedAccessPass = try SeasonGuestPass(firstName: firstName, lastName: lastName, dateOfBirth: getDate(fromString: dateOfBirth), streetAddress: streetAddress, city: city, state: state, zipcode: zipcode)
                        case .seniorGuestPass:
                            generatedAccessPass = try SeniorGuestPass(dateOfBirth: getDate(fromString: dateOfBirth), firstName: firstName, lastName: lastName, streetAddress: streetAddress, city: city, state: state, zipcode: zipcode)
                        default: break
                        }
                    }
                case .employee:
                    if let passType = type {
                        switch passType {
                        case .hourlyEmployeeFoodServicePass:
                            generatedAccessPass = try HourlyEmployeeFoodServicesPass(firstName: firstName, lastName: lastName, streetAddress: streetAddress, city: city, state: state, zipcode: zipcode, dateOfBirth: getDate(fromString: dateOfBirth))
                        case .hourlyEmployeeRideServicePass:
                            generatedAccessPass = try HourlyEmployeeRideServicesPass(firstName: firstName, lastName: lastName, streetAddress: streetAddress, city: city, state: state, zipcode: zipcode, dateOfBirth: getDate(fromString: dateOfBirth))
                        case .hourlyEmployeeMaintenancePass:
                            generatedAccessPass = try HourlyEmployeeMaintenancePass(firstName: firstName, lastName: lastName, streetAddress: streetAddress, city: city, state: state, zipcode: zipcode, dateOfBirth: getDate(fromString: dateOfBirth))
                        default: break
                        }
                    }
                case .manager:
                    var mTier: ManagementTier?
                    if let tier = managementTier {
                        mTier = ManagementTier(rawValue: tier)
                    }
                    generatedAccessPass =  try ManagerPass(firstName: firstName, lastName: lastName, streetAddress: streetAddress, city: city, state: state, zipcode: zipcode, dateOfBirth: getDate(fromString: dateOfBirth), tier: mTier)
                case .vendor:
                    generatedAccessPass = try VendorPass(firstName: firstName, lastName: lastName, vendorCompany: company, dateOfBirth: getDate(fromString: dateOfBirth), dateOfVisit: getDate(fromString: dateOfVisit))
                case .contractor:
                    generatedAccessPass = try ContractEmployeePass(projectNumber: projectNumber, firstName: firstName, lastName: lastName, streetAddress: streetAddress, city: city, state: state, zipcode: zipcode, dateOfBirth: getDate(fromString: dateOfBirth))
                }
            } catch MissingInformationError.inSufficientData(let error) {
                notifyUserWithPopUpAlertHaving(title: "Incomplete Data", message: error)
            } catch PassEligibilityError.notChild(let error) {
                notifyUserWithPopUpAlertHaving(title: "Not a child", message: error)
            } catch PassEligibilityError.notSenior(let error) {
                notifyUserWithPopUpAlertHaving(title: "Not a senior", message: error)
            } catch let error {
                notifyUserWithPopUpAlertHaving(title: "Unknown error", message: "\(error.localizedDescription)")
            }
        }
    }
    
    func validateFormDataAndGeneratePass() {
        var firstName = firstNameTextField.text
        var lastName = lastNameTextField.text
        var streetAddress = streetAddressTextField.text
        var city = cityTextField.text
        var state = stateTextField.text
        var zipcode = zipcodeTextField.text
        var tier = managementTierTextField.text
        var projectNo = projectNumberTextField.text
        var dateOfVisit = dateOfVisitTextField.text
        var dateOfBirth = dateOfBirthTextField.text
        var company = companyTextField.text
        do {
            try dataValidator.validateDate(with: &dateOfBirth)
            try dataValidator.validateDate(with: &dateOfVisit)
            try dataValidator.validateProject(with: &projectNo)
            try dataValidator.validateManagementTier(with: &tier)
            try dataValidator.validateFirstNameField(with: &firstName)
            try dataValidator.validateLastNameField(with: &lastName)
            try dataValidator.validateStreetAddressField(with: &streetAddress)
            try dataValidator.validateCompany(with: &company)
            try dataValidator.validateCityField(with: &city)
            try dataValidator.validateStateField(with: &state)
            try dataValidator.validateZipcodeField(with: &zipcode)
            
            generateAccessPassUsing(dateOfBirth: dateOfBirth, dateOfVisit: dateOfVisit, projectNumber: projectNo, managementTier: tier,
                                    firstName: firstName, lastName: lastName, streetAddress: streetAddress, city: city, state: state,
                                    zipcode: zipcode, company: company, forPassCategory: chosenAccessPass, forPassSubType: chosenAccessPassSubType)
            performSegue(withIdentifier: "checkGeneratedPass", sender: self)
        } catch ValidationError.invalidData(let errorMessage) {
            notifyUserWithPopUpAlertHaving(title: "Invalid Data", message: errorMessage)
        } catch ValidationError.invalidDataLength(let errorMessage) {
            notifyUserWithPopUpAlertHaving(title: "Invalid Data Length", message: errorMessage)
        } catch ValidationError.invalidDate(let errorMessage) {
            notifyUserWithPopUpAlertHaving(title: "Invalid Date", message: errorMessage)
        } catch ValidationError.invalidManagementTier(let errorMessage) {
            notifyUserWithPopUpAlertHaving(title: "Invalid Data", message: errorMessage)
        } catch ValidationError.invalidProjectNumber(let errorMessage) {
            notifyUserWithPopUpAlertHaving(title: "Invalid Data", message: errorMessage)
        } catch ValidationError.invalidVendorCompany(let errorMessage) {
            notifyUserWithPopUpAlertHaving(title: "Invalid Data", message: errorMessage)
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }
    
    func configureRelevantTextFieldsWithUIPickerViews() {
        projectNumberTextField.inputView = projectPicker
        companyTextField.inputView = companyPicker
        managementTierTextField.inputView = managementTierPicker
    }
    
    func configureRelevantTextFieldsWithDatePickerViews() {
        dateOfBirthTextField.inputView = dateOfBirthPicker
        dateOfBirthTextField.inputAccessoryView = getToolBar(for: .dateOfBirth)
        dateOfVisitTextField.inputView = dateOfVisitPicker
        dateOfVisitTextField.inputAccessoryView = getToolBar(for: .dateOfVisit)
    }
    
    func testAllParkAccessPasses() {
        let testBot = AccessPassGeneratorAppTester()
        testBot.testAllMainParkPasses()
        testBot.testAllVendorPasses()
        testBot.testAllContractEmployeePasses()
        testBot.testSwipeOnBirthDay()
    }
    
    func activateForm(for passType: PassCategory) {
        deactivateForm()
        switch passType {
        case .vendor:
            dateOfVisitLabel.textColor = enabledLabelTextColor
            companyLabel.textColor = enabledLabelTextColor
            dateOfVisitTextField.isEnabled = true
            companyTextField.isEnabled = true
        case .contractor:
            projectNumberLabel.textColor = enabledLabelTextColor
            projectNumberTextField.isEnabled = true
        case .manager:
            managementTierLabel.textColor = enabledLabelTextColor
            managementTierTextField.isEnabled = true
        default: break
        }
        activateGeneralFormFields()
        activateButtons()
    }
    
    func populateFormData() {
        if let passType = chosenAccessPassSubType {
            switch passType {
            case .freeChildGuestPass:
                dateOfBirthTextField.text = dataProvider.childDateOfBirthData
            case .seniorGuestPass:
                dateOfBirthTextField.text = dataProvider.seniorDateOfBirthData
            default:
                dateOfBirthTextField.text = dataProvider.dateOfBirth
            }
        }
        firstNameTextField.text = dataProvider.firstNameData
        lastNameTextField.text = dataProvider.lastNameData
        streetAddressTextField.text = dataProvider.streetAddressData
        
        let cityStateZipCodeData = dataProvider.cityStateZipcodeData
        cityTextField.text = cityStateZipCodeData.city
        stateTextField.text = cityStateZipCodeData.state
        zipcodeTextField.text = cityStateZipCodeData.zipcode
        
        if dateOfVisitTextField.isEnabled {
            dateOfVisitTextField.text = dataProvider.dateOfVisit
        }
        if managementTierTextField.isEnabled {
            managementTierTextField.text = dataProvider.tierData
        }
        if projectNumberTextField.isEnabled {
            projectNumberTextField.text = dataProvider.projectData
        }
        if companyTextField.isEnabled {
            companyTextField.text = dataProvider.companyData
        }
    }
    
    // MARK: - Helper methods
    func notifyUserWithPopUpAlertHaving(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func getDate(fromString string: String?) -> Date? {
        guard let dateString = string else {
            return nil
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        return dateFormatter.date(from: dateString)
    }
    
    func getToolBar(for datePicker: AccessPassFormDatePicker) -> UIToolbar {
        let toolBar = UIToolbar();
        toolBar.sizeToFit()
        let doneButton: UIBarButtonItem
        switch datePicker {
        case .dateOfBirth:
            doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: #selector(AccessPassFormVC.doneSelectingDateOfBirth))
        case .dateOfVisit:
            doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: #selector(AccessPassFormVC.doneSelectingDateOfVisit))
        }
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItem.Style.plain, target: self, action: #selector(AccessPassFormVC.dismissDatePicker))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        return toolBar
    }
    
    func deactivateForm() {
        disableLabels()
        disableTextFields()
        emptyOutFormTextFields()
        disableButtons()
    }
    
    func activateGeneralFormFields() {
        firstNameLabel.textColor = enabledLabelTextColor
        lastNameLabel.textColor = enabledLabelTextColor
        streetAddressLabel.textColor = enabledLabelTextColor
        cityLabel.textColor = enabledLabelTextColor
        stateLabel.textColor = enabledLabelTextColor
        zipcodeLabel.textColor = enabledLabelTextColor
        dateOfBirthLabel.textColor = enabledLabelTextColor
        dateOfBirthTextField.isEnabled = true
        firstNameTextField.isEnabled = true
        lastNameTextField.isEnabled = true
        streetAddressTextField.isEnabled = true
        cityTextField.isEnabled = true
        stateTextField.isEnabled = true
        zipcodeTextField.isEnabled = true
    }
    
    func disableLabels() {
        firstNameLabel.textColor = disabledLabelTextColor
        lastNameLabel.textColor = disabledLabelTextColor
        streetAddressLabel.textColor = disabledLabelTextColor
        cityLabel.textColor = disabledLabelTextColor
        stateLabel.textColor = disabledLabelTextColor
        zipcodeLabel.textColor = disabledLabelTextColor
        dateOfBirthLabel.textColor = disabledLabelTextColor
        dateOfVisitLabel.textColor = disabledLabelTextColor
        companyLabel.textColor = disabledLabelTextColor
        projectNumberLabel.textColor = disabledLabelTextColor
        managementTierLabel.textColor = disabledLabelTextColor
    }
    
    func disableTextFields() {
        dateOfBirthTextField.isEnabled = false
        dateOfVisitTextField.isEnabled = false
        projectNumberTextField.isEnabled = false
        managementTierTextField.isEnabled = false
        firstNameTextField.isEnabled = false
        lastNameTextField.isEnabled = false
        companyTextField.isEnabled = false
        streetAddressTextField.isEnabled = false
        cityTextField.isEnabled = false
        stateTextField.isEnabled = false
        zipcodeTextField.isEnabled = false
    }
    
    func disableButtons() {
        generatePassButton.isEnabled = false
        populateDataButton.isEnabled = false
    }
    
    func activateButtons() {
        generatePassButton.isEnabled = true
        populateDataButton.isEnabled = true
    }
    
    func emptyOutFormTextFields() {
        dateOfBirthTextField.text = ""
        dateOfVisitTextField.text = ""
        projectNumberTextField.text = ""
        managementTierTextField.text = ""
        firstNameTextField.text = ""
        lastNameTextField.text = ""
        streetAddressTextField.text = ""
        cityTextField.text = ""
        stateTextField.text = ""
        zipcodeTextField.text = ""
        companyTextField.text = ""
    }
    
    // MARK: - Target Actions
    @objc func classicGuestFormSelected() {
        activateForm(for: .guest)
        chosenAccessPassSubType = PassSubType.classicGuestPass
    }
    
    @objc func vipGuestFormSelected() {
        activateForm(for: .guest)
        chosenAccessPassSubType = PassSubType.vipGuestPass
    }
    
    @objc func freeChildGuestFormSelected() {
        activateForm(for: .guest)
        chosenAccessPassSubType = PassSubType.freeChildGuestPass
    }
    
    @objc func seniorGuestFormSelected() {
        activateForm(for: .guest)
        chosenAccessPassSubType = PassSubType.seniorGuestPass
    }
    
    @objc func seasonPassGuestFormSelected() {
        activateForm(for: .guest)
        chosenAccessPassSubType = PassSubType.seasonGuestPass
    }
    
    @objc func foodServiceEmployeeFormSelected() {
        activateForm(for: .employee)
        chosenAccessPassSubType = PassSubType.hourlyEmployeeFoodServicePass
    }
    
    @objc func rideServiceEmployeeFormSelected() {
        activateForm(for: .employee)
        chosenAccessPassSubType = PassSubType.hourlyEmployeeRideServicePass
    }
    
    @objc func maintenanceEmployeeFormSelected() {
        activateForm(for: .employee)
        chosenAccessPassSubType = PassSubType.hourlyEmployeeMaintenancePass
    }
    
    @objc func doneSelectingDateOfBirth() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        dateOfBirthTextField.text = dateFormatter.string(from: dateOfBirthPicker.date)
        view.endEditing(true)
    }
    
    @objc func doneSelectingDateOfVisit() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        dateOfVisitTextField.text = dateFormatter.string(from: dateOfVisitPicker.date)
        view.endEditing(true)
    }
    
    @objc func dismissDatePicker() {
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let userInfo = notification.userInfo, let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            
            let frame = keyboardFrame.cgRectValue
            containerViewTopConstraint.constant = frame.size.height * -1
            containerViewBottomConstraint.constant = frame.size.height

            UIView.animate(withDuration: 0.8) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func keyBoardWillHide(_ notification: Notification) {
        containerViewTopConstraint.constant = 0
        containerViewBottomConstraint.constant = 0
        UIView.animate(withDuration: 0.8) {
            self.view.layoutIfNeeded()
        }

    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}


extension AccessPassFormVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch AccessPassFormPickerView(rawValue: pickerView.tag)! {
        case AccessPassFormPickerView.company: return dataProvider.companyPickerViewData.count
        case AccessPassFormPickerView.project: return dataProvider.projectPickerViewData.count
        case AccessPassFormPickerView.managementTier: return dataProvider.managementTierPickerViewData.count
        }
    }
    
    func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch AccessPassFormPickerView(rawValue: pickerView.tag)! {
        case AccessPassFormPickerView.company: return dataProvider.companyPickerViewData[row]
        case AccessPassFormPickerView.project: return dataProvider.projectPickerViewData[row]
        case AccessPassFormPickerView.managementTier: return dataProvider.managementTierPickerViewData[row]
        }
    }
    
    func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch AccessPassFormPickerView(rawValue: pickerView.tag)! {
        case AccessPassFormPickerView.company: companyTextField.text = dataProvider.companyPickerViewData[row]
        case AccessPassFormPickerView.project: projectNumberTextField.text = dataProvider.projectPickerViewData[row]
        case AccessPassFormPickerView.managementTier: managementTierTextField.text = dataProvider.managementTierPickerViewData[row]
        }
        view.endEditing(true)
    }
}

