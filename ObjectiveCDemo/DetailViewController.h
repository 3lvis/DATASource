//
//  DetailViewController.h
//  ObjectiveCDemo
//
//  Created by Elvis Nuñez on 10/19/16.
//
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) NSDate *detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

