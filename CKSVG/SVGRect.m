//
//  SVGRect.m
//  IATKit
//
//  Created by Kurt Arnlund on 3/23/12.
//  Copyright (c) 2012 Ingenious Arts and Technologies LLC. All rights reserved.
//
//	This file was not originally part of CKSVG.
//

#import "SVGRect.h"
#import "SVG.h"

@implementation SVGRect

// Now implemented in CoreGraphics
//void CGPathAddRoundedRect (CGMutablePathRef path, CGRect rect, CGFloat rx, CGFloat ry) {
//	CGRect innerRect = CGRectInset(rect, rx, ry);
//	
//	CGFloat innerRight = innerRect.origin.x + innerRect.size.width;
//	CGFloat right = rect.origin.x + rect.size.width;
//	CGFloat innerBottom = innerRect.origin.y + innerRect.size.height;
//	CGFloat bottom = rect.origin.y + rect.size.height;
//	
//	CGFloat innerTop = innerRect.origin.y;
//	CGFloat top = rect.origin.y;
//	CGFloat innerLeft = innerRect.origin.x;
//	CGFloat left = rect.origin.x;
//	
//	CGPathMoveToPoint(path, NULL, innerLeft, top);
//	
//	CGPathAddLineToPoint(path, NULL, innerRight, top);
//	CGPathAddArcToPoint(path, NULL, right, top, right, innerTop, (rx > ry) ? rx : ry);
//	CGPathAddLineToPoint(path, NULL, right, innerBottom);
//	CGPathAddArcToPoint(path, NULL,  right, bottom, innerRight, bottom, (rx > ry) ? rx : ry);
//	
//	CGPathAddLineToPoint(path, NULL, innerLeft, bottom);
//	CGPathAddArcToPoint(path, NULL,  left, bottom, left, innerBottom, (rx > ry) ? rx : ry);
//	CGPathAddLineToPoint(path, NULL, left, innerTop);
//	CGPathAddArcToPoint(path, NULL,  left, top, innerLeft, top, (rx > ry) ? rx : ry);
//	
//	CGPathCloseSubpath(path);
//}

- (id)initWithAttributes:(NSDictionary *)attributeDict {
	self = [super init];
	if (!self)
		return nil;

	rect = CGRectZero;
	rx = 0.0f; ry = 0.0f;
	
	// Use the specified width and height
	NSString *widthStr = [attributeDict objectForKey:@"width"];
	if (widthStr)
		rect.size.width = [widthStr floatValue];

	NSString *heightStr = [attributeDict objectForKey:@"height"];
	if (heightStr)
		rect.size.height = [heightStr floatValue];

	NSString *xposStr = [attributeDict objectForKey:@"x"];
	if (xposStr)
		rect.origin.x = [xposStr floatValue];

	NSString *yposStr = [attributeDict objectForKey:@"y"];
	if (yposStr)
		rect.origin.y = [yposStr floatValue];

	NSString *rxStr = [attributeDict objectForKey:@"rx"];
	if (rxStr)
		rx = [rxStr floatValue];

	NSString *ryStr = [attributeDict objectForKey:@"ry"];
	if (ryStr)
		ry = [ryStr floatValue];
	
	[self makeMutablePath];
	
	if ((rx == 0.0f) && (ry == 0.0f)) {
		CGPathAddRect(self.path, NULL, rect);
		CGPathCloseSubpath(self.path);
	}
	else
		CGPathAddRoundedRect(self.path, NULL, rect, rx, ry);

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
		self.strokeLineJoin = [SVGHelpers SVGLineJoinWithLineJoin:strokeLineJoinStr];
	else
		self.strokeLineJoin = self.parentContainer.strokeLineJoin;
	
	return self;
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
}

@end
