//
//  MetalCell.m
//  Gen
//
//  Created by Andrey Korikov on 19.04.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "MetalCell.h"

@implementation MetalCell

@synthesize pin;

- (id)initWithWorld:(b2World*)theWorld position:(CGPoint)pos name:(NSString*)name withPinAtPos:(CGPoint)pinPos
{
    if ((self = [super initWithType:kMetalType withWorld:theWorld position:pos name:name])) {
        
        body->SetType(b2_dynamicBody);
        body->SetUserData(self);
        
        // make pin for the MetalCell body. Need for the revolute joint
        pin = [[[MetalCellPin alloc] initWithWorld:theWorld atLocation:pinPos] autorelease];
        // Rev Joint creation
        b2RevoluteJointDef revJointDef;
        revJointDef.bodyA = body;
        revJointDef.bodyB = pin.body;
        revJointDef.localAnchorA = body->GetLocalPoint(pin.body->GetPosition());
        revJointDef.localAnchorB.SetZero();
        pinJoint = (b2RevoluteJoint*) world->CreateJoint(&revJointDef);
    }
    return self;
}

- (id)initWithWorld:(b2World*)theWorld position:(CGPoint)pos name:(NSString*)name
{
    if ((self = [super initWithType:kMetalType withWorld:theWorld position:pos name:name])) {
        
        body->SetType(b2_dynamicBody);
        body->SetUserData(self);
    }
    return self;
}

- (void)setMotorSpeed:(float32)motorSpeed
{
    if (pinJoint != NULL) {
        if (pinJoint->IsMotorEnabled()) {
            pinJoint->SetMotorSpeed(motorSpeed);
        }
        else {
            pinJoint->SetMaxMotorTorque(1000);
            pinJoint->SetMotorSpeed(motorSpeed);
            pinJoint->EnableMotor(YES);
        }
    }
}

+ (id) metalCellInWorld:(b2World *)theWorld position:(CGPoint)pos name:(NSString *)name
{
    return [[[self alloc] initWithWorld:theWorld position:pos name:name] autorelease];
}

+ (id) metalCellInWorld:(b2World *)theWorld position:(CGPoint)pos name:(NSString *)name withPinAtPos:(CGPoint)pinPos
{
    return [[[self alloc] initWithWorld:theWorld position:pos name:name withPinAtPos:pinPos] autorelease];
}

- (void) dealloc
{
    pin = nil;
    [super dealloc];
}

@end
