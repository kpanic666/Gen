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
    CCSprite *glowUndercover;
}

@property (nonatomic, readwrite, retain) CCSprite *glowUndercover;

@end
