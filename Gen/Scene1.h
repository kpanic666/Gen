//
//  Scene1.h
//  Gen
//
//  Created by Andrey Korikov on 11.03.12.
//  Copyright 2012 Atom Games. All rights reserved.
//

#import "Box2DLayer.h"

@class ChildCell;
@class ParentCell;
@class ExitCell;
@class MagneticCell;

@interface Scene1 : Box2DLayer {
    CCArray *childCellsArray;
    ParentCell *parentCell;
    ExitCell *exitCell;
    MagneticCell *magneticCell1;
    MagneticCell *magneticCell2;
}

@end

