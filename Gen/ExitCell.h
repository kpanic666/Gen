//
//  ExitCell.h
//  Gen
//
//  Created by Andrey Korikov on 22.03.12.
//  Copyright 2012 Atom Games. All rights reserved.
//

#import "Box2DSprite.h"

@interface ExitCell : Box2DSprite
{
    CGPoint leftEyeInitPos;
    CGPoint rightEyeInitPos;
    CGPoint tongueInitPos;
    
    float millisecondsStayingIdle;
    int foodInSensorCounter;
}

@property (nonatomic, retain) CCSprite *leftEye;
@property (nonatomic, retain) CCSprite *rightEye;
@property (nonatomic, retain) CCSprite *tongue;
@property (nonatomic, retain) CCSprite *blink;

// Animations
@property (nonatomic, retain) CCAnimation *tentaclesAnim;
@property (nonatomic, retain) CCAnimation *tongueAnim;
@property (nonatomic, retain) CCAnimation *blinkAnim;
@property (nonatomic, retain) CCAnimation *openMouthAnim;
@property (nonatomic, retain) CCAnimation *closeMouthAnim;
@property (nonatomic, retain) CCAnimation *eatingAnim;
@property (nonatomic, retain) CCAnimation *sadAnim;

@end
