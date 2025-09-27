//
//  Languages.swift
//  Cinemate
//
//  Created by YUDONG LU on 17/9/2025.
//

import Foundation

/* ISO_639_1 */
enum Languages : String, Codable, Identifiable, CaseIterable {
    case NoLanguage = "xx"
    case Mandarin = "zh"
    case German = "de"
    case English = "en"
    case French = "fr"
    case Indonesian = "id"
    case Italian = "it"
    case Japanese = "ja"
    case Portuguese = "pt"
    case Russian = "ru"
    case Spanish = "es"
    case Thai = "th"
    case Turkish = "tr"
    case Vietnamese = "vi"
    case Arabic = "ar"
    case Korean = "ko"
    case Hindi = "hi"
    case Polish = "pl"
    case Dutch = "nl"
    case Swedish = "sv"
    case Norwegian = "no"
    case Malay = "ms"
    case Bengali = "bn"
    case Greek = "el"
    case Ukrainian = "uk"

    var id: String { self.rawValue }
    var label: String {
        switch self {
        case .NoLanguage:      return "Unknown"
        case .Mandarin:        return "中文"
        case .German:          return "Deutsch"
        case .English:         return "English"
        case .French:          return "Français"
        case .Indonesian:      return "Bahasa Indonesia"
        case .Italian:         return "Italiano"
        case .Japanese:        return "日本語"
        case .Portuguese:      return "Português"
        case .Russian:         return "Русский"
        case .Spanish:         return "Español"
        case .Thai:            return "ไทย"
        case .Turkish:         return "Türkçe"
        case .Vietnamese:      return "Tiếng Việt"
        case .Arabic:          return "العربية"
        case .Korean:          return "한국어"
        case .Hindi:           return "हिन्दी"
        case .Polish:          return "Polski"
        case .Dutch:           return "Nederlands"
        case .Swedish:         return "Svenska"
        case .Norwegian:       return "Norsk"
        case .Malay:           return "Bahasa Melayu"
        case .Bengali:         return "বাংলা"
        case .Greek:           return "Ελληνικά"
        case .Ukrainian:       return "Українська"
        }
    }
}
