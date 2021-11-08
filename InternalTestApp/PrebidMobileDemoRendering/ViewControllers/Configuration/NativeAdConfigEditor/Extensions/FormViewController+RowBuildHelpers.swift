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

import Foundation
import UIKit
import Eureka

import PrebidMobile

protocol RowBuildHelpConsumer: FormViewController {
    associatedtype DataContainer
    var dataContainer: DataContainer? { get }
    
    var requiredPropertiesSection: Section { get }
    var optionalPropertiesListSection: Section { get }
    var optionalPropertiesValuesSection: Section { get }
    
    var onExit: ()->() { get set }
}

extension RowBuildHelpConsumer {
    func include_tag(field: String) -> String {
        return "\(field)_include"
    }
    func value_tag(field: String) -> String {
        return "\(field)_value"
    }
    
    private func makeIncudeRow<T>(_ field: String,
                          keyPath: ReferenceWritableKeyPath<DataContainer, T?>,
                          defVal: T,
                          onChange: ((CheckRow)->())? = nil) -> CheckRow
    {
        return CheckRow(include_tag(field: field)) { [weak self] row in
            row.title = field
            row.value = self?.dataContainer?[keyPath: keyPath] != nil
        }
        .cellSetup { [weak self] cell, row in
            cell.accessibilityIdentifier = self?.include_tag(field: field)
        }
        .onChange { [weak self] row in
            self?.dataContainer?[keyPath: keyPath] = (row.value == true) ? defVal : nil
            onChange?(row)
        }
    }
    
    private func makeValueRow<T, C:Cell<T>, U:RowType&FieldRow<C>>(_ field: String,
                                                                   rowGen: (String, (U)->()) -> U,
                                                                   src: @escaping ()->T?,
                                                                   dst: @escaping (T?)->()) -> U
    {
        return rowGen(value_tag(field: field)) { row in
            row.title = field
            row.value = src()
            row.hidden = Condition.function([include_tag(field: field)]) { _ in src() == nil }
        }
        .cellSetup { [weak self] cell, row in
            row.value = src()
            cell.textField.accessibilityIdentifier = self?.value_tag(field: field)
        }
        .onChange { (row: U) in
            dst(row.value)
        }
    }
    private func makeOptionalValueRow<V, T, C:Cell<T>, U:RowType&FieldRow<C>>(_ field: String,
                                                                              keyPath: ReferenceWritableKeyPath<DataContainer, V?>,
                                                                              rowGen: (String, (U)->()) -> U,
                                                                              rawValGen: @escaping (V)->T,
                                                                              valGen: @escaping (T)->V) -> U
    {
        let boxVal: (T?)->V? = { ($0 == nil) ? nil : valGen($0!) }
        let unboxVal: (V?)->(T?) = { ($0 == nil) ? nil : rawValGen($0!) }
        return makeValueRow(field, rowGen: rowGen, src: { [weak self] in
            unboxVal(self?.dataContainer?[keyPath: keyPath])
        }, dst: { [weak self] in
            self?.dataContainer?[keyPath: keyPath] = boxVal($0)
        })
    }
    private func makeRequiredValueRow<T, C:Cell<T>, U:RowType&FieldRow<C>>(_ field: String,
                                                                           keyPath: ReferenceWritableKeyPath<DataContainer, T>,
                                                                           rowGen: (String, (U)->()) -> U,
                                                                           defVal: T) -> U
    {
        return makeValueRow(field, rowGen: rowGen, src: { [weak self] in
            self?.dataContainer?[keyPath: keyPath]
        }, dst: { [weak self] in
            self?.dataContainer?[keyPath: keyPath] = $0 ?? defVal
        })
    }
    
    func makeRequiredIntRow(_ field: String, keyPath: ReferenceWritableKeyPath<DataContainer, Int>) -> IntRow {
        return makeRequiredValueRow(field, keyPath: keyPath, rowGen: IntRow.init, defVal: 0)
    }
    func makeRequiredEnumRow<T: RawRepresentable>(_ field: String, keyPath: ReferenceWritableKeyPath<DataContainer, T>, defVal: T) -> IntRow where T.RawValue == Int {
        return makeValueRow(field, rowGen: IntRow.init, src: { [weak self] in
            self?.dataContainer?[keyPath: keyPath].rawValue
        }, dst: { [weak self] in
            if let intVal = $0, let enumVal = T(rawValue: intVal) {
                self?.dataContainer?[keyPath: keyPath] = enumVal
            }
        })
    }
    func makeOptionalIntRow(_ field: String, keyPath: ReferenceWritableKeyPath<DataContainer, NSNumber?>) -> IntRow {
        return makeOptionalValueRow(field, keyPath: keyPath, rowGen: IntRow.init, rawValGen: { $0.intValue }, valGen: NSNumber.init)
    }
    func makeOptionalStringRow(_ field: String, keyPath: ReferenceWritableKeyPath<DataContainer, String?>) -> TextRow {
        return makeOptionalValueRow(field, keyPath: keyPath, rowGen: TextRow.init, rawValGen: { $0 }, valGen: { $0 })
    }
    
    func makeArrayEditorRow<T>(_ field:String,
                               getter: ()->[T]?,
                               setter: ([T]?)->(),
                               hidden: Condition? = nil,
                               onSelect: @escaping ()->()) -> LabelRow
    {
        LabelRow(value_tag(field: field)) { row in
            row.title = field
            row.hidden = hidden
        }
        .cellSetup { [weak self] cell, row in
            cell.accessibilityIdentifier = self?.include_tag(field: field)
            cell.accessoryType = .disclosureIndicator
        }
        .onCellSelection { cell, row in
            cell.isSelected = false
            onSelect()
        }
    }
    
    func makeArrayEditorRow<T>(_ field:String,
                               keyPath: ReferenceWritableKeyPath<DataContainer, [T]>,s
                               hidden: Condition? = nil,
                               onSelect: @escaping ()->()) -> LabelRow
    {
        return makeArrayEditorRow(field,
                                  getter: { [weak self] in self?.dataContainer?[keyPath: keyPath] },
                                  setter: { [weak self] in self?.dataContainer?[keyPath: keyPath] = $0 ?? [] },
                                  hidden: hidden,
                                  onSelect: onSelect)
    }
    
    func addOptionalString(_ field:String, keyPath: ReferenceWritableKeyPath<DataContainer, String?>) {
        let valueRow = makeOptionalStringRow(field, keyPath: keyPath)
        optionalPropertiesValuesSection <<< valueRow
        optionalPropertiesListSection
            <<< makeIncudeRow(field, keyPath: keyPath, defVal: "") { [weak self] row in
                if row.value == true {
                    valueRow.value = self?.dataContainer?[keyPath: keyPath]
                    valueRow.updateCell()
                }
            }
    }
    func addOptionalInt(_ field:String, keyPath: ReferenceWritableKeyPath<DataContainer, NSNumber?>) {
        let valueRow = makeOptionalIntRow(field, keyPath: keyPath)
        optionalPropertiesValuesSection <<< valueRow
        optionalPropertiesListSection
            <<< makeIncudeRow(field, keyPath: keyPath, defVal: 0) { [weak self] row in
                if row.value == true {
                    valueRow.value = self?.dataContainer?[keyPath: keyPath]?.intValue ?? 0
                    valueRow.updateCell()
                }
            }
    }
    
    func addInt(_ field:String, keyPath: ReferenceWritableKeyPath<DataContainer, Int>) {
        let valueRow = makeRequiredIntRow(field, keyPath: keyPath)
        requiredPropertiesSection <<< valueRow
    }
    
    func addEnum<T: RawRepresentable>(_ field:String, keyPath: ReferenceWritableKeyPath<DataContainer, T>, defVal: T) where T.RawValue == Int {
        let valueRow = makeRequiredEnumRow(field, keyPath: keyPath, defVal: defVal)
        optionalPropertiesValuesSection <<< valueRow
    }
    
    func addOptionalArray<T>(_ field:String, keyPath: ReferenceWritableKeyPath<DataContainer, [T]?>,
                             onSelect: @escaping ()->()) {
        optionalPropertiesListSection <<< makeIncudeRow(field, keyPath: keyPath, defVal: []) { [weak self] row in
            self?.updateArrayCount(field: field, count: self?.dataContainer?[keyPath: keyPath]?.count ?? 0)
        }
        let hidden = Condition.function([include_tag(field: field)]) { [weak self] _ in
            self?.dataContainer?[keyPath: keyPath] == nil
        }
        optionalPropertiesValuesSection
            <<< makeArrayEditorRow(field,
                                   getter: { [weak self] in self?.dataContainer?[keyPath: keyPath] },
                                   setter: { [weak self] in self?.dataContainer?[keyPath: keyPath] = $0 ?? [] },
                                   hidden: hidden,
                                   onSelect: onSelect)
    }
    
    func updateArrayCount(field: String, count: Int) {
        if let arrayButtonRow = form.rowBy(tag: value_tag(field: field)) as? LabelRow {
            arrayButtonRow.value = "\(count)"
            arrayButtonRow.updateCell()
        }
    }
    
    func makeMultiValuesSection<T, C:Cell<T>, U:RowType&FieldRow<C>>(field: String,
                                                                     getter: @escaping ()->[T]?,
                                                                     setter: @escaping ([T]?)->(),
                                                                     rowGen: @escaping (String?, (U)->()) -> U,
                                                                     defVal: T? = nil,
                                                                     hidden: Condition? = nil) -> MultivaluedSection
    {
        let valuesSection = MultivaluedSection(multivaluedOptions: [.Insert, .Reorder, .Delete],
                                  header: field,
                                  footer: nil) { section in
            func makeValRow(value: T?) -> U {
                return rowGen(nil) { row in
                    row.title = field
                    row.value = value
                }
            }
            section.addButtonProvider = { _ in
                ButtonRow() { row in
                    row.title = "Add \(field.capitalized)"
                }
            }
            section.multivaluedRowToInsertAt = { _ in makeValRow(value: defVal) }
            getter()?.map(makeValRow).forEach(section.append)
            section.hidden = hidden
        }
        let oldOnExit = onExit
        onExit = {
            oldOnExit()
            setter(valuesSection.values().compactMap { $0 as? T })
        }
        return valuesSection
    }
    
    func addOptionalMultiValuesSection<T, V, C:Cell<V>, U:RowType&FieldRow<C>>(field: String,
                                                                               keyPath: ReferenceWritableKeyPath<DataContainer, [T]?>,
                                                                               rowGen: @escaping (String?, (U)->()) -> U,
                                                                               rawValGen: @escaping (V)->T,
                                                                               valGen: @escaping (T)->V,
                                                                               defVal: V? = nil)
    {
        let boxVal: (T?)->V? = { ($0 == nil) ? nil : valGen($0!) }
        let unboxVal: (V?)->(T?) = { ($0 == nil) ? nil : rawValGen($0!) }
        
        var valuesSection = makeMultiValuesSection(field: field,
                                                   getter: { [weak self] in self?.dataContainer?[keyPath: keyPath]?.compactMap(boxVal) },
                                                   setter: { [weak self] in self?.dataContainer?[keyPath: keyPath] = $0?.compactMap(unboxVal) },
                                                   rowGen: rowGen,
                                                   defVal: defVal,
                                                   hidden: Condition.function([include_tag(field: field)]) { [weak self] _ in
                                                    self?.dataContainer?[keyPath: keyPath] == nil
                                                   })
        
        optionalPropertiesListSection
            <<< makeIncudeRow(field, keyPath: keyPath, defVal: []) { row in
                if row.value == true {
                    valuesSection.removeSubrange(0..<(valuesSection.count-1))
                }
            }
        
        form
            +++ valuesSection
    }
    
    func addRequiredIntArrayField(field: String, keyPath: ReferenceWritableKeyPath<DataContainer, [NSNumber]>) {
        form
            +++ makeMultiValuesSection(field: field,
                                       getter: { [weak self] in self?.dataContainer?[keyPath: keyPath].map { $0.intValue } },
                                       setter: { [weak self] in self?.dataContainer?[keyPath: keyPath] = ($0 ?? []).map(NSNumber.init) },
                                       rowGen: IntRow.init,
                                       defVal: 0)
    }
    
    func addRequiredIntArrayField(field: String, keyPath: ReferenceWritableKeyPath<DataContainer, [Int]>) {
        form
            +++ makeMultiValuesSection(field: field,
                                       getter: { [weak self] in self?.dataContainer?[keyPath: keyPath].map { $0 } },
                                       setter: { [weak self] in self?.dataContainer?[keyPath: keyPath] = ($0 ?? []) },
                                       rowGen: IntRow.init,
                                       defVal: 0)
    }
    
    func addRequiredStringArrayField(field: String, keyPath: ReferenceWritableKeyPath<DataContainer, [String]>) {
        form
            +++ makeMultiValuesSection(field: field,
                                       getter: { [weak self] in self?.dataContainer?[keyPath: keyPath] },
                                       setter: { [weak self] in self?.dataContainer?[keyPath: keyPath] = $0 ?? [] },
                                       rowGen: TextRow.init,
                                       defVal: "")
    }
    
    func addOptionalStringArrayField(field: String, keyPath: ReferenceWritableKeyPath<DataContainer, [String]?>) {
        addOptionalMultiValuesSection(field: field,
                                      keyPath: keyPath,
                                      rowGen: TextRow.init,
                                      rawValGen: { $0 },
                                      valGen: { $0 },
                                      defVal: "")
    }
    
    func addExtRow(field: String,
                           src: KeyPath<DataContainer, [String: Any]?>,
                           dst: @escaping (DataContainer) -> ([String: Any]?) throws -> ())
    {
        optionalPropertiesListSection
            <<< CheckRow(include_tag(field: field)) { [weak self] row in
                row.title = field
                row.value = self?.dataContainer?[keyPath: src] != nil
            }
            .onChange { [weak self] row in
                guard let self = self,
                      let dataContainer = self.dataContainer,
                      let valueRow = self.form.rowBy(tag: self.value_tag(field: field)) as? TextRow
                else {
                    return
                }
                if row.value == true {
                    try? dst(dataContainer)([:])
                    valueRow.value = "{}"
                } else {
                    try? dst(dataContainer)([:])
                    valueRow.value = nil
                }
                valueRow.updateCell()
            }
        
        optionalPropertiesValuesSection
            <<< TextRow(value_tag(field: field)) { row in
                row.title = field
                row.value = {
                    if let dic = dataContainer?[keyPath: src],
                       let data = try? JSONSerialization.data(withJSONObject: dic, options: []),
                       let str = String(data: data, encoding: .utf8)
                    {
                        return str
                    } else {
                        return nil
                    }
                }()
                row.hidden = Condition.function([include_tag(field: field)]) { [weak self] _ in
                    self?.dataContainer?[keyPath: src] == nil
                }
            }
            .onChange { [weak self] row in
                if let self = self,
                   let dataContainer = self.dataContainer,
                   let data = row.value?.data(using: .utf8),
                   let obj = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                {
                    try? dst(dataContainer)(obj)
                }
            }
    }
}
