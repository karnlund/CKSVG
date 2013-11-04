/*	Created by Cory Kilger on 10/23/09.
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

#import "SVGElement.h"
#import "SVGContainerProtocol.h"

@implementation SVGElement

@synthesize parentContainer;

@synthesize fillColor;
@synthesize strokeColor;
@synthesize strokeWidth;
@synthesize strokeLineJoin;

- (id)init
{
    self = [super init];
    if (self) {
		strokeWidth = 1.0f;
		strokeLineJoin = kCGLineJoinMiter;
    }
    return self;
}


- (id)initWithAttributes:(NSDictionary *)attributeDict parent:(SVGElement<SVGContainerProtocol> *)parent {
	return nil;
}

- (void)drawRect:(CGRect)dirtyRect {
}

- (void)setFillFromParent
{
	if (!self.parentContainer) {
		[self setFillColor:[UIColor blackColor]];			
		return;
	}
	
	fillColor = [self.parentContainer fillColor];
}

- (void)setStrokeFromParent
{
	if (!self.parentContainer) {
		[self setStrokeColor:[UIColor blackColor]];
		return;
	}

	strokeColor = [self.parentContainer strokeColor];
}


- (void)dealloc
{
	fillColor = nil;
	strokeColor = nil;
	strokeWidth = 0.0f;
	strokeLineJoin = kCGLineJoinMiter;
}

@end
