//
//  MenuListViewController.m
//  youtube-ios-player-helper
//
//  Created by Ono Masashi on 2016/03/22.
//  Copyright © 2016年 akisute. All rights reserved.
//

#import "MenuListViewController.h"

#import "Sample_Basic_Code_ViewController.h"

@implementation MenuListViewController

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.section) {
        case 0:
        {
            switch (indexPath.row) {
                case 0:
                {
                    // Instantiate using Interface Builder
                    break;
                }
                case 1:
                {
                    // Instantiate using Code
                    UIViewController *viewController = [[Sample_Basic_Code_ViewController alloc] initWithNibName:nil bundle:nil];
                    [self.splitViewController showDetailViewController:viewController sender:nil];
                    break;
                }
                default:
                {
                    break;
                }
            }
            break;
        }
        default:
        {
            break;
        }
    }
}

@end
