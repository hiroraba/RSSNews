//
//  RSSParser.swift
//  RSSNews
//

import Foundation

protocol RSSParsing {
    func parse(data: Data) throws -> ParsedRSSFeed
}

final class RSSParser: NSObject, RSSParsing {
    private var currentElement = ""
    private var currentTitle = ""
    private var currentLink = ""
    private var currentSummary = ""
    private var currentPubDate = ""
    private var channelTitle = ""
    private var items: [ParsedRSSItem] = []
    private var insideItem = false

    func parse(data: Data) throws -> ParsedRSSFeed {
        reset()
        let parser = XMLParser(data: data)
        parser.delegate = self
        guard parser.parse() else {
            throw RSSServiceError.parsingFailed
        }
        return ParsedRSSFeed(
            title: channelTitle.isEmpty ? "Untitled Feed" : channelTitle,
            items: items
        )
    }

    private func reset() {
        currentElement = ""
        currentTitle = ""
        currentLink = ""
        currentSummary = ""
        currentPubDate = ""
        channelTitle = ""
        items = []
        insideItem = false
    }

    private func finishItem() {
        guard !currentLink.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let item = ParsedRSSItem(
            title: currentTitle.trimmingCharacters(in: .whitespacesAndNewlines),
            link: currentLink.trimmingCharacters(in: .whitespacesAndNewlines),
            summary: currentSummary.decodedHTML(),
            publishedAt: DateParser.parse(currentPubDate) ?? .now
        )
        items.append(item)
    }
}

extension RSSParser: XMLParserDelegate {
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName.lowercased()

        if currentElement == "item" || currentElement == "entry" {
            insideItem = true
            currentTitle = ""
            currentLink = ""
            currentSummary = ""
            currentPubDate = ""
        }

        if insideItem, currentElement == "link", let href = attributeDict["href"], !href.isEmpty {
            currentLink = href
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        switch currentElement {
        case "title":
            if insideItem {
                currentTitle += string
            } else {
                channelTitle += string
            }
        case "link":
            if insideItem, currentLink.isEmpty {
                currentLink += string
            }
        case "description", "summary", "content:encoded", "content":
            if insideItem {
                currentSummary += string
            }
        case "pubdate", "published", "updated", "dc:date":
            if insideItem {
                currentPubDate += string
            }
        default:
            break
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        let element = elementName.lowercased()
        if element == "item" || element == "entry" {
            finishItem()
            insideItem = false
        }
        currentElement = ""
    }
}
