//
//  UserViewController.m
//  FreesoundSampleApp
//
//  Created by Frederic Font Corbera on 30/05/14.
//  Copyright (c) 2014 Frederic Font Corbera. All rights reserved.
//

#import "UserViewController.h"
#import "Freesound-iOS.h"

@interface UserViewController ()
@property (weak, nonatomic) NSDictionary *user_info;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *userAvatarView;
@property (weak, nonatomic) IBOutlet UILabel *numberOfSoundsLabel;
@property (weak, nonatomic) IBOutlet UITextView *userDescription;
@end

@implementation UserViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.userDescription.text = @"";
    self.numberOfSoundsLabel.text = @"";
    [self.activityIndicator setHidden:NO];
    NSURL *url = [FreesoundFetcher URLforUserWithUsername:self.username];
    [FreesoundFetcher fetchURL:url withCompletionHandler:^(NSDictionary *results){
        if (results){
            self.user_info = results;
            NSLog(@"%@", [results description]);
            [self.activityIndicator setHidden:YES];
            [self displayUserInfo];
        }
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.tabBarController setTitle:self.username];
}

# pragma mark - Display user info helper

- (void)displayUserInfo
{
    NSString *about_text = [self.user_info objectForKey:@"about"];
    if (about_text != (id)[NSNull null]){
        NSString *aboutString = [self.user_info objectForKey:@"about"];
        NSAttributedString *aboutAttributedString = [[NSAttributedString alloc] initWithData:[aboutString dataUsingEncoding:NSUTF8StringEncoding]
                                                                                     options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                                                                                               NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)}
                                                                          documentAttributes:nil error:nil];
        self.userDescription.attributedText = aboutAttributedString;
    }
    self.numberOfSoundsLabel.text = [NSString stringWithFormat:@"Number of sounds: %@", [self.user_info objectForKey:@"num_sounds"]];
    dispatch_queue_t fetchQ = dispatch_queue_create("user avatar", NULL);
    dispatch_async(fetchQ, ^{
        [self loadImage];
    });
}

# pragma mark - Image stuff

-(void)loadImage
{
    NSString *avatar_url = [self.user_info valueForKeyPath:@"avatar.large"];
    if (avatar_url != (id)[NSNull null]){
        NSURL *imgURL=[NSURL URLWithString:avatar_url];
        NSData *imgData=[NSData dataWithContentsOfURL:imgURL];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (imgData){
                self.userAvatarView.image = [UIImage imageWithData:imgData];
            }
        });
    }
}



@end
