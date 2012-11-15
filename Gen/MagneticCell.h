//
//  MagneticCell.h
//  Gen
//  Отталкивает ChildCell от себя.
//  Created by Andrey Korikov on 02.04.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "Box2DSprite.h"

@interface MagneticCell : Box2DSprite

@property (nonatomic, retain) CCSprite *topSwirl;
@property (nonatomic, retain) CCSprite *middleSwirl;

- (void)drawMagnetForces;

@end
