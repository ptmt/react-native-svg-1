/**
 * Copyright (c) 2015-present, Horcrux.
 * All rights reserved.
 *
 * This source code is licensed under the MIT-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "RNSVGGroup.h"

@implementation RNSVGGroup

- (void)renderLayerTo:(CGContextRef)context
{
    if (self.asClipPath == NULL) {
        RNSVGSvgView* svg = [self getSvgView];
        [self clip:context];
        
        for (RNSVGNode *node in self.subviews) {
            [node renderTo:context];
            
            if (node.touchable && !svg.touchable) {
                self.touchable = YES;
            }
        }
    } else {
        [self defineClipPath:[self getPath:context] clipPathId:self.asClipPath];
    }
}

- (CGPathRef)getPath:(CGContextRef)context
{
    CGMutablePathRef path = CGPathCreateMutable();
    for (RNSVGNode *node in self.subviews) {
        CGAffineTransform transform = node.transform;
        CGPathAddPath(path, &transform, [node getPath:context]);
    }
    return path;
}

// hitTest delagate

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    for (RNSVGNode *node in [self.subviews reverseObjectEnumerator]) {
        UIView *view = [node hitTest: point withEvent:event];
        if (view != NULL) {
            return view;
        }
    }
    return nil;
}

- (RNSVGSvgView *)getSvgView
{
    UIView *parent = self.superview;
    while ([parent class] != [RNSVGSvgView class]) {
        parent = parent.superview;
    }
    
    return (RNSVGSvgView *)parent;
}

@end