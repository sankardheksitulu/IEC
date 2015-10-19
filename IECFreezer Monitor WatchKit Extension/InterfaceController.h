//
//  InterfaceController.h
//  IECFreezer Monitor WatchKit Extension
//
//  Created by Satyen Vats on 08/10/15.
//  Copyright (c) 2015 Motifworks. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface InterfaceController : WKInterfaceController
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *hw;
@property (weak, nonatomic) IBOutlet WKInterfaceImage *myImage;
@property (weak, nonatomic) IBOutlet WKInterfaceImage *indicatorImage;

@end
