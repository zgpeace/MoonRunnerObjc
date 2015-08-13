//
//  BadgesTableViewController.m
//  MoonRunner
//
//  Created by cbz on 8/12/15.
//  Copyright (c) 2015 zgpeace. All rights reserved.
//

#import "BadgesTableViewController.h"
#import "BadgeEarnStatus.h"
#import "BadgeCell.h"
#import "Badge.h"
#import "MathController.h"
#import "Run.h"
#import "BadgeDetailsViewController.h"


@interface BadgesTableViewController ()

@property (strong, nonatomic) UIColor *redColor;
@property (strong, nonatomic) UIColor *greenColor;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (assign, nonatomic) CGAffineTransform transform;

@end

@implementation BadgesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.redColor = [UIColor colorWithRed:1.0f green:20/255.0 blue:44/255.0 alpha:1.0f];
    self.greenColor = [UIColor colorWithRed:0.0f green:146/255.0 blue:78/255.0 alpha:1.0f];
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.transform = CGAffineTransformMakeRotation(M_PI/8);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.earnStatusArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BadgeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BadgeCell" forIndexPath:indexPath];
    BadgeEarnStatus *earnStatus = [self.earnStatusArray objectAtIndex:indexPath.row];
    
    cell.silverImageView.hidden = !earnStatus.silverRun;
    cell.goldImageView.hidden = !earnStatus.goldRun;
    
    if (earnStatus.earnRun) {
        cell.nameLabel.textColor = self.greenColor;
        cell.nameLabel.text = earnStatus.badge.name;
        cell.descLabel.textColor = self.greenColor;
        cell.descLabel.text = [NSString stringWithFormat:@"Earned: %@", [self.dateFormatter stringFromDate:earnStatus.earnRun.timestamp]];
        cell.badgeImageView.image = [UIImage imageNamed:earnStatus.badge.imageName];
        cell.silverImageView.transform = self.transform;
        cell.goldImageView.transform = self.transform;
        cell.userInteractionEnabled = YES;
        
    } else {
        cell.nameLabel.textColor = self.redColor;
        cell.nameLabel.text = @"?????";
        cell.descLabel.textColor = self.redColor;
        cell.descLabel.text = [NSString stringWithFormat:@"Run %@ to Earn", [MathController stringifyDistance:earnStatus.badge.distance]];
        cell.badgeImageView.image = [UIImage imageNamed:@"question_badge.png"];
        cell.userInteractionEnabled = NO;
    }
    
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0f;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue destinationViewController] isKindOfClass:[BadgeDetailsViewController class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        BadgeEarnStatus *earnStatus = [self.earnStatusArray objectAtIndex:indexPath.row];
        [(BadgeDetailsViewController *)[segue destinationViewController] setEarnStatus:earnStatus];
    }
}

@end







