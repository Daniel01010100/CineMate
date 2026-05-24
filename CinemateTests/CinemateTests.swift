//
//  CinemateTests.swift
//  CinemateTests
//
//  Created by YUDONG LU on 14/9/2025.
//

import XCTest
@testable import Cinemate

final class CinemateTests: XCTestCase {
    var cmvm: CineMateViewModel!

    override func setUpWithError() throws {
        cmvm = CineMateViewModel()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testShouldUpdateMoviesData() throws {
        let key = "lastFetchDate"
        UserDefaults.standard.removeObject(forKey: key)
        XCTAssertTrue(cmvm.shouldUpdateMoviesData())
        XCTAssertFalse(cmvm.shouldUpdateMoviesData())
    }
    
    func testAddMovieRecord() throws {
        let originalCount = cmvm.movieRecords.count
        cmvm.addMovieRecord(100, "/poster.jpg", "Spider-Man")
        
        XCTAssertEqual(cmvm.movieRecords.count, originalCount + 1)
    }
    
    func testDeleteMovieRecord() throws {
        cmvm.addMovieRecord(100, "/poster.jpg", "Spider-Man")
        cmvm.addMovieRecord(101, "/poster.jpg", "Your Name.")
        cmvm.addMovieRecord(102, "/poster.jpg", "Kungfu")
        let firstRecord = cmvm.movieRecords[0]
        let originalCount = cmvm.movieRecords.count
        
        XCTAssertTrue(cmvm.delMovieRecord(firstRecord.id))
        XCTAssertEqual(cmvm.movieRecords.count, originalCount - 1)
    }
    
    
    func testGetFavouriteRecords() throws {
        cmvm.addMovieRecord(100, "/poster.jpg", "Spider-Man")
        cmvm.addMovieRecord(101, "/poster.jpg", "Your Name.")
        cmvm.addMovieRecord(102, "/poster.jpg", "Kungfu")
        cmvm.movieRecords[0].isFavourite = true
        
        let favourites = cmvm.getFavouriteRecords()
        
        XCTAssertEqual(favourites.count, 1)
        XCTAssertTrue(favourites[0].isFavourite)
        XCTAssertEqual(favourites[0].movieTitle, "Spider-Man")
    }
    
    func testUpdateRecordRating() throws {
        cmvm.addMovieRecord(100, "/poster.jpg", "Spider-Man")
        let recordId = cmvm.movieRecords[0].id
        
        cmvm.updateRecordRating(recordId, 4.4)
        XCTAssertEqual(cmvm.movieRecords[0].userRating, 4.4)
    }
        
    func testGetMostWatchDate() throws {
        let Date1 = Calendar.current.date(from: DateComponents(year: 2026, month: 3, day: 1))!
        let Date2 = Calendar.current.date(from: DateComponents(year: 2026, month: 4, day: 1))!
        
        cmvm.addMovieRecord(100, "/poster.jpg", "Spider-Man", [], nil, Date1)
        cmvm.addMovieRecord(101, "/poster.jpg", "Your Name.", [], nil, Date1)
        cmvm.addMovieRecord(102, "/poster.jpg", "Kungfu", [], nil, Date2)
        
        let result = cmvm.getMostWatchedDate()
        
        XCTAssertNotNil(result)
        XCTAssertTrue(result!.contains("03/2026"))
    }
    
    func testGetMostFrequentCompanion() throws {
        let ashley = CompanionModel("Ashley", "Friend", UUID(), true)
        let jimmy = CompanionModel("Jimmy", "Friend", UUID(), true)
        cmvm.addMovieRecord(100, "/poster.jpg", "Spider-Man", [], nil, Date(), [], 4.5, nil, [ashley])
        cmvm.addMovieRecord(101, "/poster.jpg", "Your Name.", [], nil, Date(), [], 5.0, nil, [ashley])
        cmvm.addMovieRecord(102, "/poster.jpg", "Kungfu", [], nil, Date(), [], 4.5, nil, [jimmy])
        
        let result = cmvm.getMostFrequentCompanion()
        
        XCTAssertEqual(result, "Ashley")
    }
}
