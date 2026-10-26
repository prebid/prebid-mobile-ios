/*   Copyright 2018-2021 Prebid.org, Inc.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import UIKit

// The internal app needs only these five row types; keep its forms in UIKit.
final class FormRow {
    enum Kind { case text, toggle, checkmark, label, action }

    let title: String
    let kind: Kind
    var value: String?
    var isOn: Bool
    var identifier: String?
    var controlIdentifier: String?
    var detailIdentifier: String?
    var accessoryType: UITableViewCell.AccessoryType = .none
    var onTextChange: ((String) -> Void)?
    var onToggle: ((Bool) -> Void)?
    var onSelect: (() -> Void)?

    init(_ title: String, kind: Kind, value: String? = nil, isOn: Bool = false) {
        self.title = title
        self.kind = kind
        self.value = value
        self.isOn = isOn
    }
}

final class FormSection {
    var title: String?
    var rows: [FormRow]
    var footer: UIButton?

    init(_ title: String? = nil, rows: [FormRow] = [], footer: UIButton? = nil) {
        self.title = title
        self.rows = rows
        self.footer = footer
    }
}

class FormTableViewController: UITableViewController {
    private static let textCellIdentifier = "FormTextCell"
    private static let toggleCellIdentifier = "FormToggleCell"
    private static let displayCellIdentifier = "FormDisplayCell"
    var sections: [FormSection] = []

    init() {
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(FormTextCell.self, forCellReuseIdentifier: Self.textCellIdentifier)
        tableView.register(FormToggleCell.self, forCellReuseIdentifier: Self.toggleCellIdentifier)
        tableView.register(FormTableViewCell.self, forCellReuseIdentifier: Self.displayCellIdentifier)
        tableView.keyboardDismissMode = .interactive
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 50
    }

    override func numberOfSections(in tableView: UITableView) -> Int { sections.count }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].rows.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section].title
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        sections[section].footer
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        sections[section].footer == nil ? UITableView.automaticDimension : 44
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = sections[indexPath.section].rows[indexPath.row]
        let identifier: String
        switch row.kind {
        case .text: identifier = Self.textCellIdentifier
        case .toggle: identifier = Self.toggleCellIdentifier
        default: identifier = Self.displayCellIdentifier
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! FormTableViewCell
        cell.configure(row)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let row = sections[indexPath.section].rows[indexPath.row]
        if row.kind == .checkmark {
            row.isOn.toggle()
            tableView.cellForRow(at: indexPath)?.accessoryType = row.isOn ? .checkmark : .none
            row.onToggle?(row.isOn)
        }
        row.onSelect?()
    }

    func focusTextRow(identifier: String) {
        for (section, model) in sections.enumerated() {
            guard let row = model.rows.firstIndex(where: { $0.identifier == identifier }) else { continue }
            let indexPath = IndexPath(row: row, section: section)
            tableView.scrollToRow(at: indexPath, at: .none, animated: false)
            tableView.layoutIfNeeded()
            tableView.cellForRow(at: indexPath)?.contentView.subviews.compactMap { $0 as? UITextField }.first?.becomeFirstResponder()
        }
    }

    func refreshVisibleValues() {
        for indexPath in tableView.indexPathsForVisibleRows ?? [] {
            guard let cell = tableView.cellForRow(at: indexPath) else { continue }
            let row = sections[indexPath.section].rows[indexPath.row]
            for field in cell.contentView.subviews.compactMap({ $0 as? UITextField }) where !field.isFirstResponder {
                field.text = row.value
            }
            (cell.accessoryView as? UISwitch)?.isOn = row.isOn
        }
    }
}

// Cells build their controls once and bind them to the current row on every reuse.
class FormTableViewCell: UITableViewCell {
    fileprivate weak var row: FormRow?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        textLabel?.numberOfLines = 0
    }

    required init?(coder: NSCoder) {
        fatalError("Form cells are created programmatically")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        row = nil
    }

    func configure(_ row: FormRow) {
        self.row = row
        textLabel?.text = row.title
        textLabel?.textColor = row.kind == .action ? .systemBlue : .label
        detailTextLabel?.text = row.kind == .label ? row.value : nil
        detailTextLabel?.accessibilityIdentifier = row.kind == .label ? row.detailIdentifier : nil
        accessibilityIdentifier = row.identifier
        selectionStyle = .none
        accessoryType = .none
        switch row.kind {
        case .checkmark:
            accessoryType = row.isOn ? .checkmark : .none
            selectionStyle = .default
        case .action:
            accessoryType = row.accessoryType
            selectionStyle = .default
        default:
            break
        }
    }
}

private final class FormTextCell: FormTableViewCell {
    private let titleLabel = UILabel()
    private let field = UITextField()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        titleLabel.font = .preferredFont(forTextStyle: .body)
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        field.textAlignment = .right
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.clearButtonMode = .whileEditing
        field.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(field)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.45),
            titleLabel.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 8),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8),
            field.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 12),
            field.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            field.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            field.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            field.heightAnchor.constraint(greaterThanOrEqualToConstant: 24)
        ])
        field.addTarget(self, action: #selector(textChanged), for: .editingChanged)
    }

    required init?(coder: NSCoder) {
        fatalError("Form cells are created programmatically")
    }

    override func configure(_ row: FormRow) {
        super.configure(row)
        textLabel?.text = nil
        titleLabel.text = row.title
        field.text = row.value
        field.accessibilityLabel = row.title
        field.accessibilityIdentifier = row.controlIdentifier
    }

    @objc private func textChanged() {
        guard let row else { return }
        let value = field.text ?? ""
        row.value = value
        row.onTextChange?(value)
    }
}

private final class FormToggleCell: FormTableViewCell {
    private let control = UISwitch()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        accessoryView = control
        control.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
    }

    required init?(coder: NSCoder) {
        fatalError("Form cells are created programmatically")
    }

    override func configure(_ row: FormRow) {
        super.configure(row)
        control.isOn = row.isOn
        control.accessibilityLabel = row.title
        control.accessibilityIdentifier = row.controlIdentifier
    }

    @objc private func valueChanged() {
        guard let row else { return }
        row.isOn = control.isOn
        row.onToggle?(row.isOn)
    }
}
