//
//  TreeNode.h
//  HashLife
//
//  Copyright © 2017 nspool. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TreeNode : NSObject

+(TreeNode*) createRoot;
-(TreeNode*) expandUniverse;
-(TreeNode*) nextGeneration;
-(TreeNode*) setBitAtX:(int)x Y:(int)y;

// FIXME: int is probably too small and may overflow!
@property int level;
@property int population;
@property TreeNode *nw, *ne, *sw, *se;
@property bool alive;

+ (NSMapTable *)mapTable;

@end
