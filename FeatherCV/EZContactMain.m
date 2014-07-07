//
//  EZViewController.m
//  FeatherCV
//
//  Created by xietian on 14-6-25.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZContactMain.h"
#import "EZContactMainCell.h"
#import "EZPerson.h"
#import "EZLineDrawingView.h"

@interface EZContactMain ()

@end

@implementation EZContactMain

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 84;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EZContactMainCell* cell = [_tableView dequeueReusableCellWithIdentifier:@"contactCell"];
    
    EZPerson* person = [_persons objectAtIndex:indexPath.row];
    EZDEBUG(@"person name:%@", person.name);
    cell.name.text = person.name;
    cell.contentView.backgroundColor = randBack(nil);
    cell.paintTouchView.collectBlock = ^(NSArray* points){
        
    };
    
    return cell;
}

- (void) setPersons:(NSMutableArray *)persons
{
    _persons = persons;
    [_tableView reloadData];
    EZDEBUG(@"tableView pointer:%i", (int)_tableView);
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    EZDEBUG(@"person count:%i", _persons.count);
    return _persons.count;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    EZDEBUG(@"View did load get called");
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CurrentScreenWidth, CurrentScreenHeight) style:UITableViewStylePlain];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableView registerClass:[EZContactMainCell class] forCellReuseIdentifier:@"contactCell"];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
