//
//  SVGiOS_Tests.m
//  SVGiOS Tests
//
//  Created by Kurt Arnlund on 11/3/13.
//
//

#import <XCTest/XCTest.h>
#import "SVG.h"

@interface SVGiOS_Tests : XCTestCase
@property (strong, nonatomic) NSString *twitterBirdFilename;
@end

@implementation SVGiOS_Tests

- (void)setUp
{
    [super setUp];

    // Put setup code here. This method is called before the invocation of each test method in the class.
	self.twitterBirdFilename = [[NSBundle bundleForClass:[self class]] pathForResource:@"TwitterBird" ofType:@".svg"];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testTwitterBirdAsset
{
	XCTAssertNotNil(self.twitterBirdFilename, @"cannot find twitter bird test svg asset.");
}

- (void)testTwitterParse
{
	SVGView *svgView = [SVGView new];
	[svgView loadFilename:self.twitterBirdFilename];
	
	XCTAssertNotNil(svgView.elements, @"no elements parsed from twitter bird svg.");
	XCTAssertNil(svgView.containerStack, @"container stack still contains items.");
	XCTAssertTrue(svgView.elements.count == 2, @"svg does not contain 2 elements.");
	
	id <NSObject> elementOne = [svgView.elements objectAtIndex:0];
	id <NSObject> elementTwo = [svgView.elements objectAtIndex:1];
	
	XCTAssertEqualObjects(elementOne.class, SVGGroup.class, @"first element must be a group.");
	XCTAssertEqualObjects(elementTwo.class, SVGPath.class, @"second element must be a path.");
	
	SVGGroup *groupOne = (SVGGroup *)elementOne;
	XCTAssertNotNil(groupOne.elements, @"no elements in group.");
	XCTAssertTrue(groupOne.elements.count == 1, @"first group does not contain 1 elements.");
	
	id <NSObject> groupOneElementOne = [groupOne.elements objectAtIndex:0];
	XCTAssertEqualObjects(groupOneElementOne.class, SVGGroup.class, @"fist element in first group must be a group.");
	SVGGroup *groupTwo = (SVGGroup *)groupOneElementOne;
	id <NSObject> groupTwoElementOne = [groupTwo.elements objectAtIndex:0];
	XCTAssertEqualObjects(groupTwoElementOne.class, SVGGroup.class, @"fist element in second group must be a group.");
	SVGGroup *groupThree = (SVGGroup *)groupTwoElementOne;
	id <NSObject> groupThreeElementOne = [groupThree.elements objectAtIndex:0];
	XCTAssertEqualObjects(groupThreeElementOne.class, SVGGroup.class, @"fist element in third group must be a group.");
	SVGGroup *groupFour = (SVGGroup *)groupThreeElementOne;
	id <NSObject> groupFourElementOne = [groupFour.elements objectAtIndex:0];
	XCTAssertEqualObjects(groupFourElementOne.class, SVGRect.class, @"fist element in fourth group must be a RECT.");
	
	SVGPath *path = (SVGPath *)elementTwo;
	XCTAssertFalse(CGPathIsEmpty(path.path), @"path is empty.");
	CGRect bounds = CGPathGetBoundingBox(path.path);
	
	XCTAssertEqualWithAccuracy(bounds.origin.x, 0.0, 0.0, @"path bounds origin X not zero.");
	XCTAssertEqualWithAccuracy(bounds.origin.y, 0.0, 0.0, @"path bounds origin Y not zero.");
	XCTAssertEqualWithAccuracy(bounds.size.width, 512.0, 0.0, @"path bounds width not zero.");
	XCTAssertEqualWithAccuracy(bounds.size.height, 512.0, 0.0, @"path bounds height not zero.");
}

@end

