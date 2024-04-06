//
//  XMLParserErrorTests.swift
//  DrypotGPXTests
//
//  Created by drypot on 2024-04-07.
//

import XCTest

final class XMLParserErrorTests: XCTestCase {
  
  func testNoContent() throws {
    let data = Data(gpxSampleNoContent.utf8)
    let result = BasicXMLParser().parse(data: data)
    
    switch result {
    case .success(_):
      XCTFail()
    case .failure(.parsingError(_, let lineNumber)):
      XCTAssertEqual(lineNumber, 0)
    }
  }
  
  func testBadFormat() throws {
    let data = Data(gpxSampleBad.utf8)
    let result = BasicXMLParser().parse(data: data)
    
    switch result {
    case .success(_):
      XCTFail()
    case .failure(.parsingError(_, let lineNumber)):
      XCTAssertEqual(lineNumber, 9)
    }
  }
  
  func testNoTrack() throws {
    let data = Data(gpxSampleNoTrack.utf8)
    let result = BasicXMLParser().parse(data: data)
    
    switch result {
    case .success(let root):
      XCTAssertEqual(root.name, "gpx")
      XCTAssertEqual(root.children.first?.name, nil)
    case .failure(.parsingError(_, let lineNumber)):
      XCTFail()
    }
  }
  
  
}
