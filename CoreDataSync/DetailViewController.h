//
//  DetailViewController.h
//  CoreDataSync
//
//  Created by IRSHAD PC on 24/05/16.
//  Copyright © 2016 IRSHAD PC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
