//
//  RedCell.h
//  Gen
//
//  Created by Andrey Korikov on 18.04.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "Block.h"

@interface RedCell : Block

+ (id) redCellInWorld:(b2World*)theWorld position:(CGPoint)pos name:(NSString*)name;

@end
