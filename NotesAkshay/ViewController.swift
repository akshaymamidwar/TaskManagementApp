import UIKit
import CoreData

class ViewController: UIViewController {

    // MARK: - Static Constants

    static let Spacing8 = 8.0
    static let Spacing16 = 8.0
    static let AddButtonSize = 48.0


    // MARK: - Variables

    var highestId = -1
    var localData : [NSManagedObject] = []

    // MARK: - UI Elements

    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Bucket List"
        label.font = UIFont.boldSystemFont(ofSize: 34)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let addButton: UIButton = {
        let icon = UIImage(named: "PlusIcon")
        let button = UIButton(type: .system)
        button.setImage(icon, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(addButtonTapped(_:)), for: .touchUpInside)
        return button
    }()

    let tableView: UITableView = {
        var tableView = UITableView()
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "CustomCell")
        tableView.backgroundColor = .white
        return tableView
    }()

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        retrieveData()

        tableView.dataSource = self
        tableView.delegate = self

        setupViewHierarchy()
        setupConstraints()
        stylizeView()
    }

    // MARK: - Private Helpers

    func setupViewHierarchy() {
        view.addSubview(titleLabel)
        view.addSubview(addButton)
        view.addSubview(tableView)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: ViewController.Spacing8),
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,constant: ViewController.Spacing8),

            addButton.trailingAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -ViewController.Spacing8),
            addButton.heightAnchor.constraint(equalToConstant: ViewController.AddButtonSize),
            addButton.widthAnchor.constraint(equalToConstant: ViewController.AddButtonSize),
            addButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: ViewController.Spacing16),

            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: ViewController.Spacing8),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -ViewController.Spacing8),
            tableView.topAnchor.constraint(equalTo: addButton.bottomAnchor, constant: ViewController.Spacing8),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -ViewController.Spacing8)
        ])
    }

    func stylizeView() {
        view.backgroundColor = .white
    }
}

// MARK: - UITableViewDataSource

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return localData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! CustomTableViewCell
        let item = localData[indexPath.row]

        // Handle checkbox selection
        let isCheckboxSelected = item.value(forKey: "isCompleted") as? Bool ?? false
        cell.checkboxButton.isSelected = isCheckboxSelected
        cell.checkboxButton.addTarget(self, action: #selector(checkboxTapped(_:)), for: .touchUpInside)
        cell.checkboxButton.tag = indexPath.row

        cell.itemLabel.text = item.value(forKey: "text") as? String

        // Handle delete button tap
        cell.deleteButton.tag = indexPath.row
        cell.deleteButton.addTarget(self, action: #selector(deleteButtonTapped(_:)), for: .touchUpInside)

        // Handle edit button tap
        cell.editButton.addTarget(self, action: #selector(editButtonTapped(_:)), for: .touchUpInside)
        cell.editButton.tag = indexPath.row

        return cell
    }
}

// MARK: - UITableViewDelegate

extension ViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        // Disable highlighting for the delete and edit buttons
        return false
    }
}

// MARK: - Button Handleres

extension ViewController {

    // MARK: - Checkbox Button Tap Handler

    @objc
    func checkboxTapped(_ sender: UIButton) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        let managedContext = appDelegate.persistentContainer.viewContext
        let item = localData[sender.tag]
        let newValue = !(item.value(forKey: "isCompleted") as? Bool ?? false)
        item.setValue(newValue, forKey: "isCompleted")
        sender.isSelected = newValue

        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Error saving data to Core Data: \(error), \(error.userInfo)")
        }
    }

    // MARK: - Delete Button Tap Handler

    @objc
    func deleteButtonTapped(_ sender: UIButton) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        let item = localData[sender.tag]
        let managedContext = appDelegate.persistentContainer.viewContext
        managedContext.delete(item)
        do {
            try managedContext.save()
            localData.remove(at: sender.tag)
            tableView.reloadData()
        } catch let error as NSError {
            print("Error saving data to Core Data: \(error), \(error.userInfo)")
        }
    }

    // MARK: - Edit Button Tap Handler

    @objc
    func editButtonTapped(_ sender: UIButton) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let item = localData[sender.tag]
        let currentText = item.value(forKey: "text") as? String

        let alertController = UIAlertController(title: "Edit Item", message: nil, preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.text = currentText
        }

        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let self = self else {
                return
            }

            if let textField = alertController.textFields?.first,
               let newName = textField.text {
                item.setValue(newName, forKey: "text")
                let managedContext = appDelegate.persistentContainer.viewContext
                do {
                    try managedContext.save()
                    self.tableView.reloadData()
                } catch let error as NSError {
                    print("Error saving data to Core Data: \(error), \(error.userInfo)")
                }
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }

    // MARK: - Add Button Tap Handler

    @objc
    func addButtonTapped(_ sender: UIButton) {
        let alertController = UIAlertController(title: "New", message: "Hey save something here which I can remind you Later", preferredStyle: .alert)

        alertController.addTextField { (textField) in
            textField.placeholder = "Credit Card Bill Pay"
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in

            if let inputName = alertController.textFields?[0].text {
                self?.createToDoWithText(inputName)
            }
        }

        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)

        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - Core Data Operations

extension ViewController {

    // MARK: - Create ToDo

    func createToDoWithText(_ text: String){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        let managedContext = appDelegate.persistentContainer.viewContext

        let userEntity = NSEntityDescription.entity(forEntityName: "Entity", in: managedContext)!

        let user = NSManagedObject(entity: userEntity, insertInto: managedContext)
        user.setValue(text, forKey: "text")
        user.setValue(false, forKey: "isCompleted")
        user.setValue(highestId+1, forKey: "id")

        do {
            try managedContext.save()
            highestId = highestId + 1
            retrieveData()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }

    // MARK: - Retrieve ToDo

    func retrieveData() {
        localData.removeAll()
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        let managedContext = appDelegate.persistentContainer.viewContext

        //Prepare the request of type NSFetchRequest  for the entity
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Entity")

        do {
            let result = try managedContext.fetch(fetchRequest)
            for data in result as! [NSManagedObject] {
                localData.append(data)
                if let currentId = data.value(forKey: "id") as? Int {
                    if currentId > highestId {
                        highestId = currentId
                    }
                }
            }
            tableView.reloadData()
        } catch let error as NSError {
            print("Could not retrived Data. \(error), \(error.userInfo)")
        }
    }

    // MARK: - Delete ToDo

    @objc
    func deleteItemForId(_ id: NSInteger, indexPath: IndexPath) {

       guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
           return
       }

       let managedContext = appDelegate.persistentContainer.viewContext
       let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Entity")
       fetchRequest.predicate = NSPredicate(format: "id = %ld", id)
       do {
           let test = try managedContext.fetch(fetchRequest)
           let objectToDelete = test[0] as! NSManagedObject
           managedContext.delete(objectToDelete)

           do {
               try managedContext.save()
           } catch let error as NSError {
               print("\(error), \(error.userInfo)")
           }
       } catch let error as NSError {
           print("\(error), \(error.userInfo)")
       }
   }
}
