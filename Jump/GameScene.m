//
//  GameScene.m
//  Jump
//
//  Created by Jack on 1/19/15.
//  Copyright (c) 2015 Jump Applications. All rights reserved.
//

#import "GameScene.h"

#define SCREEN_WIDTH 568.0
#define SCREEN_HEIGHT 320.0
#define BLOCK_HEIGHT 30
#define X_OFFSET 50
#define IPAD_X_OFFSET 0
#define IPAD_Y_OFFSET 0

#define START_SPEED 100
#define MAX_SPEED 2500
#define SPEED_INCREASE .3

#define PLAYER_WIDTH 46.2
#define PLAYER_HEIGHT 63.2

@implementation GameScene {
    float ScreenMultWidth;
    float ScreenMultHeight;
    
    SKSpriteNode *player;
    
    float currentHeight;
    float currentX;
    float nextDifference;
    
    float currentSpeed;
    
    int score;
    
    NSArray *types;
}

@synthesize scoreNode;

/*
 
 SIZES:
 
 iPhone 5  = 568  320
 iPhone 6P = 736  414
 iPhone 6  = 667  375
 
 iPad      = 1024 768
 iPad R    = 1024 768
 
 */

-(void)didMoveToView:(SKView *)view {
    /* Setup your scene here */
    /*SKLabelNode *myLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    
    myLabel.text = @"Hello, World!";
    myLabel.fontSize = 65;
    myLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                   CGRectGetMidY(self.frame));
    
     [self addChild:myLabel];*/
    
    types = @[@"ground", @"groundGold"];
    
    
    ScreenMultWidth = self.size.width / SCREEN_WIDTH;
    ScreenMultHeight = self.size.height / SCREEN_HEIGHT;
    
    NSLog(@"%f, %f", ScreenMultWidth, ScreenMultHeight);
    
    self.backgroundColor = [UIColor colorWithRed:0.29 green:0.565 blue:0.996 alpha:1]; /*#4a90fe*/
    
     self.physicsWorld.gravity = CGVectorMake(0.0f, [self convertHeight:-9.8f]);
    
    [self convertPoint:CGPointZero];
    
    [self addPlayer];
    
    [self addGroundWithInitialX:0 length:250 y:0 : NO];
    [self addGroundWithInitialX:300 length:250 y:100 : NO];
    [self addGroundWithInitialX:600 length:175 y:120 : NO];
    nextDifference = 50;
    
    score = 0;
    
    self.scoreNode = [SKLabelNode labelNodeWithText:@"0"];
    scoreNode.position = [self convertPoint:CGPointMake(40, 270)];
    scoreNode.fontSize = [self convertWidth:scoreNode.fontSize];
    [self addChild:scoreNode];
    
    //self.view.showsPhysics = YES;
    
    currentSpeed = 100;
    
    [self scrollGrounds];
    
}

-(void) updateScore : (int) newScore {
    score = newScore;
    scoreNode.text = [NSString stringWithFormat:@"%i", score];
}

- (CGPoint)convertPoint:(CGPoint)point
{
    CGSize result = [[UIScreen mainScreen] bounds].size;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && result.width == 1024 && result.height == 768) {
        return CGPointMake(IPAD_X_OFFSET + point.x*2, IPAD_Y_OFFSET + point.y*2);
    } else {
        return CGPointMake(point.x*ScreenMultWidth, point.y*ScreenMultHeight);
    }
}

-(CGPoint) convertPointBack : (CGPoint) point {
    CGSize result = [[UIScreen mainScreen] bounds].size;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && result.width == 1024 && result.height == 768) {
        return CGPointMake((point.x/2) - IPAD_X_OFFSET, (point.y/2) - IPAD_Y_OFFSET);
    } else {
        return CGPointMake(point.x/ScreenMultWidth, point.y/ScreenMultHeight);
    }
}

-(float) convertWidth : (float) size {
    CGSize result = [[UIScreen mainScreen] bounds].size;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && result.width == 1024 && result.height == 768) {
        return size*2;
    } else {
        return size*ScreenMultWidth;
    }
}

-(float) convertHeight: (float) size {
    CGSize result = [[UIScreen mainScreen] bounds].size;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && result.width == 1024 && result.height == 768) {
        return size*2;
    } else {
        return size*ScreenMultHeight;
    }
}

-(CGSize) convertSize : (CGSize) size {
    CGSize result = [[UIScreen mainScreen] bounds].size;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && result.width == 1024 && result.height == 768) {
        return CGSizeMake(size.width*2, size.height*2);
    } else {
        return CGSizeMake(size.width*ScreenMultWidth, size.height*ScreenMultHeight);
    }
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    for (NSString *type in types) {
        [self enumerateChildNodesWithName:type usingBlock:^(SKNode *node, BOOL *stop) {
            
            SKCropNode *croppedNode = (SKCropNode *) node;
            
            if(fabsf(player.position.y - (node.position.y + [croppedNode maskNode].frame.size.height)) <= 1 && player.position.x + player.size.width >= node.position.x && player.position.x <= node.position.x + [croppedNode maskNode].frame.size.width) {
                if([type isEqualToString:@"groundGold"]) {
                    //[player.physicsBody applyImpulse:CGVectorMake(0.f, [self convertHeight:120.f])];
                    [player.physicsBody setVelocity:CGVectorMake(0.f, [self convertHeight:900.f])];
                }
                else {
                    //[player.physicsBody applyImpulse:CGVectorMake(0.f, [self convertHeight:80.f])];
                    [player.physicsBody setVelocity:CGVectorMake(0.f, [self convertHeight:600.f])];
                }
            }
        }];
    }
    
    /*for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
     
    }*/
}

-(void) addPlayer {
    player = [SKSpriteNode spriteNodeWithImageNamed:@"Character"];
    player.anchorPoint = CGPointZero;
    player.position = [self convertPoint:CGPointMake(X_OFFSET, BLOCK_HEIGHT)];
    player.name = @"player";
    
    player.size = [self convertSize : CGSizeMake(PLAYER_WIDTH, PLAYER_HEIGHT)];

    player.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:player.size center:[self convertPoint:CGPointMake(PLAYER_WIDTH/2, PLAYER_HEIGHT/2)]];
    player.physicsBody.dynamic = YES;
    player.physicsBody.allowsRotation = NO;
    player.physicsBody.restitution = 0.0f;
    player.physicsBody.friction = 0.0f;
    player.physicsBody.angularDamping = 0.0f;
    player.physicsBody.linearDamping = 0.0f;
    
    [self addChild:player];
}

-(void) addGroundWithInitialX : (float) initialX length : (float) length y : (float) y : (BOOL) gold {
    
    NSString *type = gold ? @"MegaJump" : @"Ground";
    
    SKSpriteNode *ground = [SKSpriteNode spriteNodeWithImageNamed:type];
    ground.anchorPoint = CGPointZero;
    //ground.position = CGPointZero;
    //ground.position = [self convertPoint:CGPointMake(initialX, y)];
    ground.size = [self convertSize:CGSizeMake(ground.size.width*BLOCK_HEIGHT/ground.size.height, BLOCK_HEIGHT)];
    //ground.name = @"ground";
    
    SKSpriteNode *mask = [SKSpriteNode spriteNodeWithColor:[SKColor blackColor] size: [self convertSize: CGSizeMake(length, BLOCK_HEIGHT)]]; //100 by 100 is the size of the mask
    SKCropNode *trimmedGround = [SKCropNode node];
    
    mask.anchorPoint = CGPointZero;
    
    [trimmedGround addChild: ground];
    [trimmedGround setMaskNode: mask];
    
    trimmedGround.position = [self convertPoint:CGPointMake(initialX, y)];
    trimmedGround.name = @"ground";
    if(gold) trimmedGround.name = @"groundGold";
    
    CGRect size = mask.frame;
    
    trimmedGround.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:[self convertSize:CGSizeMake(length, 30)] center:[self convertPoint:CGPointMake(length/2, 15)]];
    //trimmedGround.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:mask.frame];
    //trimmedGround.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:mask.position toPoint:CGPointMake(mask.position.x + mask.size.width, mask.position.y + mask.size.height)];
    //trimmedGround.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:CGPointZero toPoint:CGPointMake(mask.size.width, mask.size.height)];
    trimmedGround.physicsBody.dynamic = false;
    trimmedGround.physicsBody.restitution = 0;
    
    [self addChild: trimmedGround];
    
    //ground.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:ground.size center:CGPointMake(initialX + length/2, -15 + y)];
    //ground.physicsBody.dynamic = false;
}

-(void) scrollGrounds {
    
    __block float lastX = 0;
    
    for (NSString *type in types) {
        
        [self enumerateChildNodesWithName:type usingBlock:^(SKNode *node, BOOL *stop) {
            
            SKCropNode *croppedNode = (SKCropNode *) node;
            
            CGRect size = [croppedNode maskNode].frame;
            
            if(node.position.x + size.size.width > lastX) lastX = node.position.x + size.size.width;
            
            if([self convertPointBack: CGPointMake(node.position.x + size.size.width, node.position.y)].x < 0) {
                [node removeFromParent];
                [self updateScore:score+1];
                //[self addNewGround];
            }
            
            SKAction *move = [SKAction moveByX:[self convertWidth:-(currentSpeed / START_SPEED)] y:0 duration:1/ (float) START_SPEED];
            [node runAction:move];
        }];
    }
    
    if(lastX + nextDifference <= [self convertWidth:568]) {
        nextDifference = [self convertWidth:[self randomFloatBetween:currentSpeed/3 and:currentSpeed/1.5]];
        
        [self addNewGround];
    }
    
    if(player.position.y <= 0) {
        player.position = [self convertPoint:CGPointMake(X_OFFSET, 320)];
        [self updateScore:0];
        currentSpeed = START_SPEED;
    }
    
    //if(player.position.x != X_OFFSET) player.position = [self convertPoint:CGPointMake(X_OFFSET, [self convertPointBack:player.position].y)];
    
    if(currentSpeed < MAX_SPEED) currentSpeed += SPEED_INCREASE;
    
    [self performSelector:@selector(scrollGrounds) withObject:nil afterDelay:1/ (float) START_SPEED];
}

-(void) addNewGround {
    float length = [self randomFloatBetween:50 and:250];
    currentHeight += [self randomFloatBetween:-100 and:100];
    if(currentHeight >= 250) currentHeight = [self randomFloatBetween:150 and:250];
    if(currentHeight < 0) currentHeight = [self randomFloatBetween:0 and:100];
    
    BOOL isGold = floorf([self randomFloatBetween:0 and:2]) == 0 && length <= 170/2;
    
    [self addGroundWithInitialX:568 length:length y:currentHeight : isGold];
}

- (float)randomFloatBetween:(float)smallNumber and:(float)bigNumber {
    float diff = bigNumber - smallNumber;
    return (((float) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * diff) + smallNumber;
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
