//
//  Scene1ActionLayer.h
//  Gen
//
//  Created by Andrey Korikov on 23.04.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "Box2DLayer.h"

@class ParentCell;
@class ExitCell;

@interface Scene1ActionLayer : Box2DLayer {
    ParentCell *parentCell;
    ExitCell *exitCell;
}

@end
