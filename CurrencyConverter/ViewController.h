//
//  ViewController.h
//  CurrencyConverter
//
//  Created by NAVEEN  on 7/13/13.
//  Copyright (c) 2013 NAVEEN . All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
<UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate>
{
    NSArray *currencies;
    NSMutableDictionary *conversionDict;
}

@property (strong, nonatomic) IBOutlet UIPickerView *pickerView;
@property (strong, nonatomic) IBOutlet UITextField *inputText;
@property (strong, nonatomic) IBOutlet UILabel *outputAmount;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@end
