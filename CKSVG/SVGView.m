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


#import "SVG.h"


@implementation SVGView

@synthesize elements;
@synthesize containerStack;
@synthesize scale;
@synthesize normalFrame;

- (id)initWithData:(NSData *)data {
	self = [super init];
	if (!self)
		return nil;
	
	scale = 1.0;
	
	elements = [[NSMutableArray alloc] init];
	
	NSXMLParser *xml = [[NSXMLParser alloc] initWithData:data];
	[xml setDelegate:self];
	[xml parse];
	
	return self;
}

- (void)drawRect:(CGRect)dirtyRect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);
	CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
	CGContextFillRect(context, dirtyRect);
	CGContextScaleCTM(context, 1.0, 1.0);

	// AppKit uses a different CTM configuration
	CGContextScaleCTM(context, scale, scale);
	for (SVGElement *element in elements)
		[element drawRect:dirtyRect];
	CGContextRestoreGState(context);
}

- (id)initWithAttributes:(NSDictionary *)attributeDict {
	return nil;
}

- (void)dealloc {
	elements = nil;
	containerStack = nil;
}

- (void)setScale:(CGFloat)newScale {
	scale = newScale;
	[self setFrame:CGRectMake(normalFrame.origin.x*scale, normalFrame.origin.y*scale, normalFrame.size.width*scale, normalFrame.size.height*scale)];
}

- (void)configureWithAttributes:(NSDictionary *)attributeDict {
	if ([attributeDict objectForKey:@"viewBox"]) {
		int count = 4;
		float floats[] = {0,0,0,0}; // To appease the Clang gods
		int index = 0;
		NSScanner *scanner = [NSScanner scannerWithString:[attributeDict objectForKey:@"viewBox"]];
		while (![scanner isAtEnd]) {
			if (index < count) {
				if (![scanner scanFloat:&floats[index]])
					[scanner setScanLocation:[scanner scanLocation]+1];
				else ++index;
			}
			else break;
		}
		normalFrame = CGRectMake(floats[0], floats[1], floats[2], floats[3]);
	}
	else {
		normalFrame = CGRectMake(0, 0, [[attributeDict objectForKey:@"width"] floatValue], [[attributeDict objectForKey:@"height"] floatValue]);
	}
	
	self.scale = 1.0;
}

#pragma mark NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser didEndMappingPrefix:(NSString *)prefix {
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
	if ([elementName isEqualToString:@"svg"]) {
		[containerStack addObject:self];
		[self configureWithAttributes:attributeDict];
		return;
	}
	if ([elementName isEqualToString:@"g"]) {
		SVGElement<SVGContainerProtocol> *container = [containerStack lastObject];
		SVGGroup *group = [[SVGGroup alloc] initWithAttributes:attributeDict];
		group.parentContainer = container;
		[container.elements addObject:group];
		[containerStack addObject:group];
		return;
	}
	if ([elementName isEqualToString:@"path"]) {
		SVGElement<SVGContainerProtocol> *container = [containerStack lastObject];
		SVGPath *path = [[SVGPath alloc] initWithAttributes:attributeDict];
		path.parentContainer = container;
		[container.elements addObject:path];
		return;
	}
	if ([elementName isEqualToString:@"rect"]) {
		SVGElement<SVGContainerProtocol> *container = [containerStack lastObject];
		SVGRect *rect = [[SVGRect alloc] initWithAttributes:attributeDict];
		rect.parentContainer = container;
		[container.elements addObject:rect];
		return;
	}
	if ([elementName isEqualToString:@"polygon"]) {
		SVGElement<SVGContainerProtocol> *container = [containerStack lastObject];
		SVGPolygon *rect = [[SVGPolygon alloc] initWithAttributes:attributeDict];
		rect.parentContainer = container;
		[container.elements addObject:rect];
		return;
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	if ([elementName isEqualToString:@"svg"]) {
		if ([containerStack lastObject] == self) {
			[containerStack removeLastObject];
		}
		else {
		}
		return;
	}
	if ([elementName isEqualToString:@"g"]) {
		[containerStack removeLastObject];
		return;
	}
}

- (void)parser:(NSXMLParser *)parser didStartMappingPrefix:(NSString *)prefix toURI:(NSString *)namespaceURI {
}

- (void)parser:(NSXMLParser *)parser foundAttributeDeclarationWithName:(NSString *)attributeName forElement:(NSString *)elementName type:(NSString *)type defaultValue:(NSString *)defaultValue {
}

- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock {
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
}

- (void)parser:(NSXMLParser *)parser foundComment:(NSString *)comment {
}

- (void)parser:(NSXMLParser *)parser foundElementDeclarationWithName:(NSString *)elementName model:(NSString *)model {
}

- (void)parser:(NSXMLParser *)parser foundExternalEntityDeclarationWithName:(NSString *)entityName publicID:(NSString *)publicID systemID:(NSString *)systemID {
}

- (void)parser:(NSXMLParser *)parser foundIgnorableWhitespace:(NSString *)whitespaceString {
}

- (void)parser:(NSXMLParser *)parser foundInternalEntityDeclarationWithName:(NSString *)name value:(NSString *)value {
}

- (void)parser:(NSXMLParser *)parser foundNotationDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID {
}

- (void)parser:(NSXMLParser *)parser foundProcessingInstructionWithTarget:(NSString *)target data:(NSString *)data {
}

- (void)parser:(NSXMLParser *)parser foundUnparsedEntityDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID notationName:(NSString *)notationName {
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
}

- (NSData *)parser:(NSXMLParser *)parser resolveExternalEntityName:(NSString *)entityName systemID:(NSString *)systemID {
	return nil;
}

- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validError {
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
	containerStack = nil;
}

- (void)parserDidStartDocument:(NSXMLParser *)parser {
	containerStack = [[NSMutableArray alloc] init];
}

@end
