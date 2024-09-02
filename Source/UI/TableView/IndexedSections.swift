// Copyright © 2018-2023 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation

struct IndexedSections<Index, Row> where Index: Comparable {

    struct Section {
        let index: Index
        var rows: [Row]
    }

    private let sections: [Section]

    var indexes: [Index] {
        sections.map(\.index)
    }

    var allRows: [Row] {
        sections.flatMap({ $0.rows })
    }

    var numberOfSections: Int {
        sections.count
    }

    init(sections: [Section] = []) {
        self.sections = sections
    }

    func numberOfRowsIn(section: Int) -> Int {
        guard section < sections.count else { return 0 }

        return sections[section].rows.count
    }

    func row(at indexPath: IndexPath) -> Row? {
        guard indexPath.section < sections.count else { return nil }
        let section = sections[indexPath.section]
        guard indexPath.row < section.rows.count else { return nil }

        return sections[indexPath.section].rows[indexPath.row]
    }

    func indexFor(section: Int) -> Index? {
        guard section < numberOfSections else { return nil }

        return sections[section].index
    }
}

extension IndexedSections where Index == String {

    func sectionForSectionIndex(title: String, index: Int) -> Int {
        indexes.firstIndex(where: { $0 >= title }) ?? 0
    }
}

extension IndexedSections where Index == String, Row == Contact {

    init(contacts: [Contact]) {
        let indexes = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ#")
        var sections = indexes.map({ Section(index: String($0), rows: []) })
        contacts.forEach {
            let firstLetter = $0.alias.first?.uppercased() ?? ""
            if let index = indexes.firstIndex(of: Character(firstLetter)) {
                sections[index].rows.append($0)
            } else {
                sections[sections.endIndex - 1].rows.append($0)
            }
        }

        self.init(sections: sections.filter({ !$0.rows.isEmpty }))
    }
}
