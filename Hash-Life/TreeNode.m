//
//  TreeNode.m
//  HashLife
//
//  Copyright © 2017 nspool. All rights reserved.
//

#import "TreeNode.h"

@implementation TreeNode

@synthesize level, population, ne, nw, se, sw, alive;

TreeNode *result = nil; // for memoising the results
static NSMapTable *mapTable = nil;

// MARK: Hashing functions

+ (NSMapTable *)mapTable {
  if (mapTable == nil) {
    mapTable = [[NSMapTable alloc]
                initWithKeyOptions:NSMapTableStrongMemory
                valueOptions:NSMapTableStrongMemory
                capacity:1000];
  }
  return mapTable;
}

-(NSNumber*)hashCode {
  if(level == 0){
    return @(population);
  }
  unsigned long long has = [[ne hashCode] intValue] + 11*[[nw hashCode] intValue] + 101*[[se hashCode] intValue] + 1007*[[sw hashCode] intValue] + 10007*level;
//  NSLog(@"has %d", has);
  return [[NSNumber alloc]initWithUnsignedLongLong:has];
}

// MARK: Utility functions

// nextGeneration
-(TreeNode*) nextGeneration {
//  if (result != nil){
//    return result;
//  }
  if (population == 0){
    result = nw;
    return result;
  }
  NSLog(@"level %d",level);
  if (level == 2){
    result = [self slowSimulation];
    return result;
  }
  TreeNode *n00 = [nw nextGeneration],
  *n01 = [self horizontalForward:nw e:ne],
  *n02 = [ne nextGeneration],
  *n10 = [self verticalForward:nw e:sw],
  *n11 = [self centerForward],
  *n12 = [self verticalForward:ne e:se],
  *n20 = [sw nextGeneration],
  *n21 = [self horizontalForward:sw e:se],
  *n22 = [se nextGeneration];
  id a = [[TreeNode createAt:n00 ne:n01 sw:n10 se:n11] nextGeneration];
  id b = [[TreeNode createAt:n01 ne:n02 sw:n11 se:n12] nextGeneration];
  id c = [[TreeNode createAt:n10 ne:n11 sw:n20 se:n21] nextGeneration];
  id d = [[TreeNode createAt:n11 ne:n12 sw:n21 se:n22] nextGeneration];
  return [TreeNode createAt:a ne:b sw:c se:d];
}

// slowSimulation
-(TreeNode*)slowSimulation {
  int allbits = 0;
  for (int y=-2; y<2; y++) {
    for (int x=-2; x<2; x++) {
      allbits = (allbits << 1) + [self getBitAtX:x Y:y];
    }
  }
  
  return [TreeNode createAt:[self oneGen:allbits>>5]
                     ne:[self oneGen:allbits>>4]
                     sw:[self oneGen:allbits>>1]
                     se:[self oneGen:allbits]];
}

-(TreeNode*)oneGen:(int)bitmask {
  if (bitmask == 0){
    return [TreeNode createLiving:false];
  }
  //  NSLog(@"bitmask %d",bitmask);

  int selfmask = (bitmask >> 5) & 1 ;
//    NSLog(@"selfmask %d",selfmask);

  bitmask &= 0x757; // mask out bits we don't care about
  int neighborCount = 0;
  while (bitmask != 0) {
    neighborCount++ ;
    bitmask &= bitmask - 1 ; // clear least significant bit
  }
  if (neighborCount == 3 || (neighborCount == 2 && selfmask != 0)){
    return [TreeNode createLiving:true];
  }else{
    return [TreeNode createLiving:false];
  }
}

// horizontalForward

-(TreeNode*) horizontalForward:(TreeNode*)w e:(TreeNode*)e {
  return [[TreeNode createAt:w.ne ne:e.nw sw:w.se se:e.sw] nextGeneration];
}
// verticalForward
-(TreeNode*) verticalForward:(TreeNode*)n e:(TreeNode*)s {
  return [[TreeNode createAt:n.sw ne:n.se sw:s.nw se:s.ne] nextGeneration];
}

// centerForward
-(TreeNode*) centerForward {
  return [[TreeNode createAt:nw.se ne:ne.sw sw:sw.ne se:se.nw] nextGeneration];
}


// MARK: Quadtree data structure

/**
 *   Construct a leaf cell.
 */
- (id)initLeaf:(bool)living {
  self = [super init];
  if(self) {
    nw = ne = sw = se = nil ;
    level = 0 ;
    alive = living ;
    population = alive ? 1 : 0 ;
  }
  return self;
}

/**
 *   Construct a node given four children.
 */
-(id)initWithChildren:(TreeNode*)nw_ ne:(TreeNode*)ne_ sw:(TreeNode*)sw_ se:(TreeNode*)se_ {
  self = [super init];
  if(self) {
    nw = nw_;
    ne = ne_;
    sw = sw_;
    se = se_;
    level = nw_.level + 1;
    population = nw.population + ne.population + sw.population + se.population;
    alive = population > 0 ;
  }
  return self;
}

+(TreeNode*)createRoot {
  NSLog(@"Creating Root");
  return [[[TreeNode alloc] initLeaf:false] emptyTree:3];
}
          
+(TreeNode*)createAt:(TreeNode*)nw_ ne:(TreeNode*)ne_ sw:(TreeNode*)sw_ se:(TreeNode*)se_  {
  TreeNode* o = [[TreeNode alloc] initWithChildren:nw_ ne:ne_ sw:sw_ se:se_];
//  NSLog(@"Creating quad level %d", o.level);

  id hashCode = [o hashCode];
//  NSLog(@"hashcode %@", hashCode);
  TreeNode* canon = [[TreeNode mapTable] objectForKey:hashCode];
  if(canon != nil){
    return canon;
  } else {
    [[TreeNode mapTable] setObject:o forKey:[o hashCode]];
    return o;
  }
}

+(TreeNode*)createLiving:(bool)living {
  TreeNode* o = [[TreeNode alloc] initLeaf:living];
  TreeNode* canon = nil; //[[TreeNode mapTable] objectForKey:[o hashCode]];
//  NSLog(@"Creating leaf level %d (%d)", o.level, canon.level);
  
  if(canon != nil){
    return canon;
  } else {
    [[TreeNode mapTable] setObject:o forKey:[o hashCode]];
    return o;
  }
}

-(TreeNode*)emptyTree:(int)lev {
//  NSLog(@"level %d", lev);
  if (lev == 0) {
    id o =  [TreeNode createLiving:false];
    return o;
  }
  TreeNode *n = [self emptyTree:lev-1];
  return [TreeNode createAt:n ne:n sw:n se:n];
}

-(TreeNode*)expandUniverse {
  TreeNode* border = [self emptyTree:level-1];
    NSLog(@"Expanding border at level %d", border.level);

  id a = [TreeNode createAt:border ne:border sw:border se:nw];
  id b = [TreeNode createAt:border ne:border sw:ne se:border];
  id c = [TreeNode createAt:border ne:sw sw:border se:border];
  id d = [TreeNode createAt:se ne:border sw:border se:border];
  return [TreeNode createAt:a ne:b sw:c se:d];
}

-(int)getBitAtX:(int)x Y:(int)y {
  
  if (level == 0) {
    return alive ? 1 : 0 ;
  }
  
  int offset = pow(2,level - 2);
  if (x < 0){
    if (y < 0){
      return [nw getBitAtX:x+offset Y:y+offset];
    }else{
      return [sw getBitAtX:x+offset Y:y-offset];
    }
  }else{
    if (y < 0) {
      return [ne getBitAtX:x-offset Y:y+offset];
    }else{
      return [se getBitAtX:x-offset Y:y-offset];
    }
  }
}

-(TreeNode*)setBitAtX:(int)x Y:(int)y{
//  NSLog(@"setBitAtX %d %d", x, y);
  if (level == 0) {
    return [[TreeNode alloc] initLeaf:true];
  }
  // distance from center of this node to center of subnode is
  // one fourth the size of this node.
  
  int offset = pow(2,level - 2);
  NSLog(@"level %d offset %d", level, offset);

  if (x < 0){
    if (y < 0){
      return [TreeNode createAt:[nw setBitAtX:x+offset Y:y+offset] ne:ne sw:sw se:se];
    }else{
      return [TreeNode createAt:nw ne:ne sw:[sw setBitAtX:x+offset Y:y-offset] se:se];
    }
  } else {
    if (y < 0){
      return [TreeNode createAt:nw ne:[ne setBitAtX:x-offset Y:y+offset] sw:sw se:se];
    }else{
      return [TreeNode createAt:nw ne:ne sw:sw se:[se setBitAtX:x-offset Y:y-offset]];
    }
  }
}


@end
