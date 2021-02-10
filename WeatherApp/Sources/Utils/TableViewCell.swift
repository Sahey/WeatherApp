//
//  UITableView+Extension.swift
//  WeatherApp
//
//  Created by sahey on 11.02.2021.
//

import UIKit

extension UITableView {
    func register(_ type: UITableViewCell.Type) {
        let identifier = String(describing: type)
        register(type, forCellReuseIdentifier: identifier)
    }

    func dequeue<Cell: UITableViewCell>(_ type: Cell.Type, for indexPath: IndexPath) -> Cell {
        let identifier = String(describing: type)
        guard let cell = dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? Cell else {
            fatalError("Couldn't dequeue UITableViewCell for \(identifier)")
        }
        return cell
    }
}

open class TableViewCell<Wrapped: UIView>: UITableViewCell {
    var wrappedView: Wrapped!

    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func createView() -> Wrapped {
        let bundle = Bundle(for: Self.self)
        let resource = String(describing: Wrapped.self)
        guard bundle.path(forResource: resource, ofType: "nib") != nil,
              let view = UINib(nibName: resource, bundle: bundle).instantiate(withOwner: Wrapped.self, options: nil).first as? Wrapped
        else {
            return Wrapped()
        }
        return view
    }

    private func setup() {
        wrappedView = createView()
        contentView.addSubview(wrappedView)
        wrappedView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            wrappedView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            wrappedView.topAnchor.constraint(equalTo: contentView.topAnchor),
            wrappedView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            wrappedView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}
