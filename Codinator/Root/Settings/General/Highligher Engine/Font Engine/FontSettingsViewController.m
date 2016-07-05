//
//  FontSettingsViewController.m
//  Codinator
//
//  Created by Vladimir Danila on 19/06/15.
//  Copyright © 2015 Vladimir Danila. All rights reserved.
//

#import "FontSettingsViewController.h"
#import "NSUserDefaults+Additions.h"
#import "SettingsEngine.h"

#import "Codinator-Swift.h"

@interface FontSettingsViewController ()


///size
@property (weak, nonatomic) IBOutlet UILabel *currentSizeLabel;
@property (weak, nonatomic) IBOutlet UIStepper *changeSizeStepper;

///preview
@property (weak, nonatomic) IBOutlet UILabel *previewLabel;
@property (weak, nonatomic) IBOutlet UILabel *overviewLabel;

///font object
@property (strong, nonatomic) UIFont *font;

@end



@implementation FontSettingsViewController


BOOL madeChanges;



- (void)viewDidLoad {
    [super viewDidLoad];    

    [self loadFont];
    [self updateLabel];

}



#pragma mark - private API


- (void)loadFont{
    
    NSString *key = [NSString stringWithFormat:@"Font: %li", (long)self.selectedType];
   
    self.font = [[NSUserDefaults standardUserDefaults] fontWithKey:key];
    self.previewLabel.font = self.font;
    self.previewLabel.text = @"<h1>Lorem ipsum</h1>";

    
    switch (self.selectedType) {
        case 0:
            self.navigationItem.title = @"Default Font";
            break;
            
        case 1:
            self.navigationItem.title = @"Italic Font";
            break;
            
        case 2:
            self.navigationItem.title = @"Bold Font";
            break;
            
        default:
            break;
    }
    

    self.changeSizeStepper.value = self.font.pointSize;
}


- (void)saveFont{
    
    switch (self.selectedType) {
        case 0:
            self.font = [UIFont systemFontOfSize:self.changeSizeStepper.value];
            break;
        case 1:
            self.font = [UIFont italicSystemFontOfSize:self.changeSizeStepper.value];
            break;
        case 2:
            self.font = [UIFont boldSystemFontOfSize:self.changeSizeStepper.value];
            break;
        default:
            break;
    }
    
    
    NSString *key = [NSString stringWithFormat:@"Font: %li", (long)self.selectedType];
    
    [[NSUserDefaults standardUserDefaults] setWithFont:self.font key:key];
    self.previewLabel.font = self.font;
}


#pragma mark - delegate


- (IBAction)stepperDidChanged:(id)sender {
    
    madeChanges = YES;
    
    [self updateLabel];
    [self saveFont];
    
}


- (void)updateLabel{
    NSInteger value = self.changeSizeStepper.value;
    
    self.currentSizeLabel.text = [NSString stringWithFormat:@"%li",(long)value];
}




- (IBAction)closeButton:(id)sender {
    
    
    if (madeChanges) {
        [SettingsEngine reloadSyntaxLayers];
    }
    
    
    [self dismissViewControllerAnimated:true completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
