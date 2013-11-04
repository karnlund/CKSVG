/*	Created by Cory Kilger on 10/22/09.
 *	
 *	Copyright (c) 2010, Cory Kilger.
 *	All rights reserved.
 *	
 *	Redistribution and use in source and binary forms, with or without
 *	modification, are permitted provided that the following conditions are met:
 *	
 *	 * Redistributions of source code must retain the above copyright
 *	   notice, this list of conditions and the following disclaimer.
 *	 * Redistributions in binary form must reproduce the above copyright
 *	   notice, this list of conditions and the following disclaimer in the
 *	   documentation and/or other materials provided with the distribution.
 *	 * Neither the name of the <organization> nor the
 *	   names of its contributors may be used to endorse or promote products
 *	   derived from this software without specific prior written permission.
 *	
 *	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 *	ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 *	WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 *	DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
 *	DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 *	(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 *	LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 *	ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 *	(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 *	SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
/*
 *  Modified my Kurt Arnlund : Ingenious Arts and Technologies LLC on 3/22/12
 *	Ported to support iOS and ARC
 */

#import "SVGPath.h"
#import "SVG.h"

@implementation SVGPath

@synthesize path;

- (id)initWithAttributes:(NSDictionary *)attributeDict {
	self = [super init];
	if (!self)
		return nil;

	CGMutablePathRef temp = path;
	path = [SVGHelpers newSVGPathForPathData:[attributeDict objectForKey:@"d"]];
	CGPathRelease(temp);
	
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
	self.strokeWidth = 1.0f;
	NSString *strokeWidthStr = [attributeDict objectForKey:@"stroke-width"];
	if (strokeWidthStr && ![strokeWidthStr isEqualToString:@"inherit"])
		self.strokeWidth = [SVGHelpers SVGFloatWithLength:strokeWidthStr];
	else
		self.strokeWidth = self.parentContainer.strokeWidth;
	
	// Use specified stroke-linejoin or inherit
	self.strokeLineJoin = kCGLineJoinMiter;
	NSString *strokeLineJoinStr = [attributeDict objectForKey:@"stroke-linejoin"];
	if (strokeLineJoinStr && ![strokeLineJoinStr isEqualToString:@"inherit"])
		self.strokeLineJoin = [SVGHelpers SVGLineJoinWithLineJoin:strokeLineJoinStr];
	else
		self.strokeLineJoin = self.parentContainer.strokeLineJoin;
	
	return self;
}

- (void)makeMutablePath
{
	CGMutablePathRef temp = path;
	path = CGPathCreateMutable();

	if (temp)
		CGPathRelease(temp);
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

- (void)dealloc {
	CGPathRelease(path);
	path = nil;
}

@end
