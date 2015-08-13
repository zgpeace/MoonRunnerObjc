//
//  BadgeCellTableViewCell.h
//  MoonRunner
//
//  Created by cbz on 8/12/15.
//  Copyright (c) 2015 zgpeace. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BadgeCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *descLabel;
@property (nonatomic, weak) IBOutlet UIImageView *badgeImageView;
@property (nonatomic, weak) IBOutlet UIImageView *silverImageView;
@property (nonatomic, weak) IBOutlet UIImageView *goldImageView;

@end
