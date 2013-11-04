//
//  SVGPolygon.m
//  IATKit
//
//  Created by Kurt Arnlund - Ingenious Arts and Technologies LLC on 3/26/12.
//  Copyright (c) 2012 Ingenious Arts and Technologies LLC. All rights reserved.
//

//#import "SVGPolygon.h"
#import "SVG.h"

/*
 <polygon fill="none" stroke="#000000" stroke-width="0.5" points="36.25,95.489 36.25,687.34 575.25,687.34 575.25,95.489 36.25,95.489 "/>
 */

DDLogVarWarn;


@interface SVGPolygon ()
- (void)parsePoints:(NSString*)pathstr;
@end


@implementation SVGPolygon


- (id)initWithAttributes:(NSDictionary *)attributeDict {
	self = [super init];
	if (!self)
		return nil;

	DDLogVerbose(@"%p   %@:%@", self, THIS_FILE, THIS_METHOD);
	
	NSString *pathStr = [attributeDict objectForKey:@"points"];
	if (pathStr)
		[self parsePoints:pathStr];
	
	// Use specified fill or inherit
	NSString *fillStr = [attributeDict objectForKey:@"fill"];
	if (fillStr && ![fillStr isEqualToString:@"inherit"])
		[self setFillColor:[SVGHelpers newSVGColorWithPaint:fillStr]];
	else
		[self setFillFromParent];
	
	// Use specified stroke or inherit
	NSString *strokeStr = [attributeDict objectForKey:@"stroke"];
	if (strokeStr && ![strokeStr isEqualToString:@"inherit"])
		[self setStrokeColor:[SVGHelpers newSVGColorWithPaint:strokeStr]];
	else
		[self setStrokeFromParent];
	
	// Use specified stroke-width or inherit
	NSString *strokeWidthStr = [attributeDict objectForKey:@"stroke-width"];
	if (strokeWidthStr && ![strokeWidthStr isEqualToString:@"inherit"])
		self.strokeWidth = [SVGHelpers SVGFloatWithLength:strokeWidthStr];
	else
		self.strokeWidth = self.parentContainer.strokeWidth;
	
	// Use specified stroke-linejoin or inherit
	NSString *strokeLineJoinStr = [attributeDict objectForKey:@"stroke-linejoin"];
	if (strokeLineJoinStr && ![strokeLineJoinStr isEqualToString:@"inherit"])
		self.strokeLineJoin = [SVGHelpers SVGLineJoinWithLineJoin:strokeLineJoinStr]	;
	else
		self.strokeLineJoin = self.parentContainer.strokeLineJoin;
	
	return self;
}

- (void)parsePoints:(NSString*)pathstr
{
	NSScanner *pathScanner = [NSScanner scannerWithString:pathstr];
	NSCharacterSet *pointSeparators = [NSCharacterSet whitespaceAndNewlineCharacterSet];
	NSCharacterSet *coordSeparators = [NSCharacterSet characterSetWithCharactersInString:@","];

	NSString *point_str;
	NSArray *pointComponents;
	float x, y;

	[self makeMutablePath];
	
	BOOL start = YES;
	
	while ([pathScanner scanUpToCharactersFromSet:pointSeparators intoString:&point_str]) {
		pointComponents = [point_str componentsSeparatedByCharactersInSet:coordSeparators];
		
		x = 0, y = 0;
		
		if (pointComponents.count > 0)
			x = [[pointComponents objectAtIndex:0] floatValue];
		if (pointComponents.count > 1)
			y = [[pointComponents objectAtIndex:1] floatValue];

		if (start) {
			CGPathMoveToPoint(self.path, NULL, x, y);
			start = NO;
		}
		else 
			CGPathAddLineToPoint(self.path, NULL, x, y);
	}
	
	CGPathCloseSubpath(self.path);
}

- (void)drawRect:(CGRect)dirtyRect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetLineWidth(context, self.strokeWidth);
	CGContextSetLineJoin(context, self.strokeLineJoin);
	CGContextSetStrokeColorWithColor(context, self.strokeColor.CGColor);
	CGContextSetFillColorWithColor(context, self.fillColor.CGColor);
	CGContextAddPath(context, self.path);
	CGContextFillPath(context);
	CGContextAddPath(context, self.path);
	CGContextStrokePath(context);
}

- (void)dealloc
{
	DDLogVerbose(@"%p   %@:%@", self, THIS_FILE, THIS_METHOD);
}


@end
