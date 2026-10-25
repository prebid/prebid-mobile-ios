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
    var sections: [FormSection] = []

    init() {
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
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
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.textLabel?.text = row.title
        cell.textLabel?.numberOfLines = 0
        cell.accessibilityIdentifier = row.identifier
        cell.selectionStyle = .none
        switch row.kind {
        case .text:
            let field = UITextField()
            field.text = row.value
            field.textAlignment = .right
            field.autocorrectionType = .no
            field.autocapitalizationType = .none
            field.clearButtonMode = .whileEditing
            field.accessibilityLabel = row.title
            field.accessibilityIdentifier = row.controlIdentifier
            field.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.addSubview(field)
            cell.textLabel?.text = nil
            let label = UILabel()
            label.text = row.title
            label.font = .preferredFont(forTextStyle: .body)
            label.numberOfLines = 0
            label.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.addSubview(label)
            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.leadingAnchor),
                label.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
                label.widthAnchor.constraint(lessThanOrEqualTo: cell.contentView.widthAnchor, multiplier: 0.45),
                label.topAnchor.constraint(greaterThanOrEqualTo: cell.contentView.topAnchor, constant: 8),
                label.bottomAnchor.constraint(lessThanOrEqualTo: cell.contentView.bottomAnchor, constant: -8),
                field.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 12),
                field.trailingAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.trailingAnchor),
                field.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 12),
                field.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -12),
                field.heightAnchor.constraint(greaterThanOrEqualToConstant: 24)
            ])
            field.addAction(UIAction { [weak field] _ in
                let value = field?.text ?? ""
                row.value = value
                row.onTextChange?(value)
            }, for: .editingChanged)
        case .toggle:
            let control = UISwitch()
            control.isOn = row.isOn
            control.accessibilityLabel = row.title
            control.accessibilityIdentifier = row.controlIdentifier
            control.addAction(UIAction { [weak control] _ in
                row.isOn = control?.isOn ?? false
                row.onToggle?(row.isOn)
            }, for: .valueChanged)
            cell.accessoryView = control
        case .checkmark:
            cell.accessoryType = row.isOn ? .checkmark : .none
            cell.selectionStyle = .default
        case .label:
            cell.detailTextLabel?.text = row.value
            cell.detailTextLabel?.accessibilityIdentifier = row.detailIdentifier
        case .action:
            cell.accessoryType = row.accessoryType
            cell.selectionStyle = .default
            cell.textLabel?.textColor = .systemBlue
        }
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
