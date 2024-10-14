import UIKit

class CustomTableViewCell: UITableViewCell {
 
    // MARK: - Static Constants

    static let ButtonSize = 24.0
    static let Spacing8 = 8.0
    static let Spacing16 = 16.0

    // MARK: - UI Elements

    let checkboxButton: UIButton = {
        let button = UIButton(type: .custom)
        let uncheckedIcon = UIImage(named: "checkbox_unchecked")
        let checkedIcon = UIImage(named: "checkbox_checked")
        button.setImage(uncheckedIcon?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.setImage(checkedIcon?.withRenderingMode(.alwaysTemplate), for: .selected)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .black
        return button
    }()

    let itemLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()

    let deleteButton: UIButton = {
        let button = UIButton(type: .custom)
        let deleteIcon = UIImage(named: "delete")
        button.setImage(deleteIcon?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .black
        return button
    }()

    let editButton: UIButton = {
        let button = UIButton(type: .custom)
        let editIcon = UIImage(named: "edit")
        button.setImage(editIcon?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .black
        return button
    }()

    // MARK: - Inits

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViewHierarchy()
        setupConstraints()
        stylizeView()
    }

    // MARK: - Private Helpers

    func setupViewHierarchy() {
        contentView.addSubview(checkboxButton)
        contentView.addSubview(itemLabel)
        contentView.addSubview(deleteButton)
        contentView.addSubview(editButton)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            // Checkbox Button
            checkboxButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: CustomTableViewCell.Spacing8),
            checkboxButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkboxButton.widthAnchor.constraint(equalToConstant: CustomTableViewCell.ButtonSize),
            checkboxButton.heightAnchor.constraint(equalToConstant: CustomTableViewCell.ButtonSize),

            // Item Label
            itemLabel.leadingAnchor.constraint(equalTo: checkboxButton.trailingAnchor, constant: CustomTableViewCell.Spacing8),
            itemLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: CustomTableViewCell.Spacing8),
            itemLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -CustomTableViewCell.Spacing8),
            itemLabel.trailingAnchor.constraint(equalTo: editButton.leadingAnchor, constant: -CustomTableViewCell.Spacing8),

            // Delete Button
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -CustomTableViewCell.Spacing8),
            deleteButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            deleteButton.widthAnchor.constraint(equalToConstant: CustomTableViewCell.ButtonSize),
            deleteButton.heightAnchor.constraint(equalToConstant: CustomTableViewCell.ButtonSize),

            // Edit Button
            editButton.trailingAnchor.constraint(equalTo: deleteButton.leadingAnchor, constant: -CustomTableViewCell.Spacing16),
            editButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            editButton.widthAnchor.constraint(equalToConstant: CustomTableViewCell.ButtonSize),
            editButton.heightAnchor.constraint(equalToConstant: CustomTableViewCell.ButtonSize),
        ])
    }

    func stylizeView() {
        backgroundColor = .white
    }
}
