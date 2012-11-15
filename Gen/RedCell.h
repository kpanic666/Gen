//
//  RedCell.h
//  Gen
//
//  Created by Andrey Korikov on 18.04.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "BlockCell.h"
#import "MetalCellPin.h"

@interface RedCell : BlockCell
{
    MetalCellPin *_pin;
    b2RevoluteJoint *pinJoint;
}

@property (readonly) MetalCellPin *pin;

+ (id) redCellInWorld:(b2World*)theWorld position:(CGPoint)pos name:(NSString*)name;
+ (id) redCellInWorld:(b2World*)theWorld position:(CGPoint)pos name:(NSString*)name withPinAtPos:(CGPoint)pinPos;
- (void) setMotorSpeed:(float32)motorSpeed;

@end
