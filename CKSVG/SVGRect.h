//
//  SVGRect.h
//  IATKit
//
//  Created by Kurt Arnlund on 3/23/12.
//  Copyright (c) 2012 Ingenious Arts and Technologies LLC. All rights reserved.
//
//	This file was not originally part of CKSVG.
//

#import "SVGPath.h"

@interface SVGRect : SVGPath {
	CGRect rect;
	CGFloat rx, ry;
}

- (id)initWithAttributes:(NSDictionary *)attributeDict;

@end
