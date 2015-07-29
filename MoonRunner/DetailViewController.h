//
//  DetailViewController.h
//  MoonRunner
//
//  Created by cbz on 7/29/15.
//  Copyright (c) 2015 zgpeace. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

