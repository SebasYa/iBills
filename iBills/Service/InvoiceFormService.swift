//
//  InvoiceFormService.swift
//  iBills
//
//  Created by Sebastian Yanni.
//

import Foundation

struct InvoiceDraft {
    let razonSocial: String
    let numeroFactura: String
    let amountText: String
    let vatRate: Double
    let category: InvoiceCategory
    let date: Date
}

enum InvoiceDraftError: LocalizedError {
    case missingRazonSocial
    case missingInvoiceNumber
    case invalidAmount
    case invalidVATRate

    var errorDescription: String? {
        switch self {
        case .missingRazonSocial:
            "Ingresa una razón social válida."
        case .missingInvoiceNumber:
            "Ingresa un número de factura válido."
        case .invalidAmount:
            "El monto total debe ser un número positivo."
        case .invalidVATRate:
            "Selecciona un porcentaje de IVA válido."
        }
    }
}

protocol InvoiceCreating {
    func makeInvoice(from draft: InvoiceDraft) throws -> Invoice
}

struct InvoiceFormService: InvoiceCreating {
    private let locale: Locale

    init(locale: Locale = .current) {
        self.locale = locale
    }

    func makeInvoice(from draft: InvoiceDraft) throws -> Invoice {
        let razonSocial = draft.razonSocial.trimmed
        guard !razonSocial.isEmpty else {
            throw InvoiceDraftError.missingRazonSocial
        }

        let numeroFactura = draft.numeroFactura.trimmed
        guard !numeroFactura.isEmpty else {
            throw InvoiceDraftError.missingInvoiceNumber
        }

        guard draft.vatRate > 0, draft.vatRate < 100 else {
            throw InvoiceDraftError.invalidVATRate
        }

        let amount = try parseAmount(from: draft.amountText)

        return Invoice(
            amount: amount.doubleValue,
            vatRate: InvoiceDecimal.rate(from: draft.vatRate).doubleValue,
            isCredit: draft.category.isCredit,
            date: draft.date,
            razonSocial: razonSocial,
            numeroFactura: numeroFactura
        )
    }

    private func parseAmount(from rawValue: String) throws -> Decimal {
        let sanitized = rawValue
            .trimmed
            .replacingOccurrences(of: " ", with: "")

        guard !sanitized.isEmpty else {
            throw InvoiceDraftError.invalidAmount
        }

        if let formatterValue = decimalFormatter.number(from: sanitized)?.decimalValue {
            let amount = InvoiceDecimal.money(from: formatterValue)
            guard amount > 0 else {
                throw InvoiceDraftError.invalidAmount
            }
            return amount
        }

        let canonicalValue = canonicalDecimalString(from: sanitized)
        if
            let amount = Decimal(string: canonicalValue, locale: Locale(identifier: "en_US_POSIX")),
            amount > 0
        {
            return InvoiceDecimal.money(from: amount)
        }

        throw InvoiceDraftError.invalidAmount
    }

    private var decimalFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = locale
        formatter.generatesDecimalNumbers = true
        return formatter
    }

    private func canonicalDecimalString(from rawValue: String) -> String {
        let filtered = rawValue.filter { $0.isNumber || $0 == "," || $0 == "." || $0 == "-" }

        guard !filtered.isEmpty else {
            return rawValue
        }

        let lastDotIndex = filtered.lastIndex(of: ".")
        let lastCommaIndex = filtered.lastIndex(of: ",")

        let decimalSeparatorIndex: String.Index? = {
            switch (lastDotIndex, lastCommaIndex) {
            case let (dot?, comma?):
                return dot > comma ? dot : comma
            case let (dot?, nil):
                return dot
            case let (nil, comma?):
                return comma
            case (nil, nil):
                return nil
            }
        }()

        var normalizedValue = ""

        for index in filtered.indices {
            let character = filtered[index]

            if character.isNumber {
                normalizedValue.append(character)
                continue
            }

            if character == "-", normalizedValue.isEmpty {
                normalizedValue.append(character)
                continue
            }

            if let decimalSeparatorIndex, index == decimalSeparatorIndex {
                normalizedValue.append(".")
            }
        }

        return normalizedValue
    }
}

private extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
