//
//  MetalCell.h
//  Gen
//
//  Created by Andrey Korikov on 19.04.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "BlockCell.h"
#import "MetalCellPin.h"

@interface MetalCell : BlockCell

@property (retain) MetalCellPin *pin;
@property b2RevoluteJoint *pinJoint;

+ (id) metalCellInWorld:(b2World*)theWorld position:(CGPoint)pos name:(NSString*)name;
+ (id) metalCellInWorld:(b2World*)theWorld position:(CGPoint)pos name:(NSString*)name withPinAtPos:(CGPoint)pinPos;
- (void) setMotorSpeed:(float32)motorSpeed;

@end
