//
//  ViewController.m
//  meepo
//
//  Created by Mikael Melander on 2018-02-02.
//  Copyright © 2018 Mikael Melander. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    notesArray = [[NSArray alloc] init];
    httpData *dataFetch = [[httpData alloc]init];
    dataFetch.delegate = self;
    [dataFetch getData];
    
    
    self.view.backgroundColor = [Colors whiteColor];
    
    // Setting up Navbar
    [self setTitle:@"Meepo"];
    UIBarButtonItem *newback = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [[self navigationItem] setBackBarButtonItem:newback];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setBarTintColor:[Colors mainColor]];
    [self.navigationController.navigationBar setTranslucent:NO];
    
    // Add button
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNote)];
    [self.navigationItem setRightBarButtonItem:rightBarButton animated:NO];
    
    // Setting up tableView
    self.table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStyleGrouped];
    self.table.backgroundColor = [Colors lightGray];
    self.table.delegate = self;
    self.table.dataSource = self;
    self.table.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    [self.table setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    self.table.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_table];
    [notesCell setTableViewWidth:self.view.frame.size.width];
    
    refresh = [[UIRefreshControl alloc]init];
    [self.table addSubview:refresh];
    [refresh addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    
    // If database has been updated by user, refresh table
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshTable)
                                                 name:@"update"
                                               object:nil];

}


#pragma TableView

- (void)refreshTable {
    httpData *dataFetch = [[httpData alloc]init];
    dataFetch.delegate = self;
    [dataFetch getData];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    switch (section)
    { case 0:
        {
            return notesArray.count;
        }
            
        default: return 0;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    switch (indexPath.section)
    {
        case 0:
        {
            UITableViewCell * cell = [self cellForIndex:indexPath];
            NSDictionary *currentDict = [notesArray objectAtIndex:indexPath.row];
            [(notesCell *)cell  configureCellForText:currentDict];
            
            return cell;
        }
        default: return nil;
    }
    
}

// Setting up custom tableViewCell
- (UITableViewCell *)cellForIndex:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    NSString *cellId = kCellIdentifier;
    cell = [self.table dequeueReusableCellWithIdentifier:cellId];
    if (!cell)
    {
        cell = [notesCell cellForTableWidth:self.table.frame.size.width];
        cell.accessoryType =  UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 110;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        detailedNote *viewController = [[detailedNote alloc] init];
        viewController.note = [notesArray objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:viewController animated:YES];
    }
}


-(void)addNote {
    addNote *viewController = [[addNote alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma Other
// Recive GET data
-(void)didFininshRequestWithJson:(NSArray *)responseJson
{
    NSLog(@"%@", responseJson);
    NSLog(@"count: %lu", (unsigned long)responseJson.count);
    notesArray = [NSArray arrayWithArray:responseJson];
    
    // Sorting array by ID descending
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"id"
                                                 ascending:NO];
    notesArray = [notesArray sortedArrayUsingDescriptors:@[sortDescriptor]];
    dispatch_sync(dispatch_get_main_queue(), ^{
        
        [refresh endRefreshing];
        [self.table reloadData];
    });
}

// Recive GET Failed.
-(void)didFailWithRequest:(NSString *)err {
    NSLog(@"%@", err);
}

// Setting the style of navigationbar Title
- (void)setTitle:(NSString *)title {
    [super setTitle:title];
    UILabel *titleView = (UILabel *)self.navigationItem.titleView;
    if (!titleView) {
        titleView = [[UILabel alloc] initWithFrame:CGRectZero];
        titleView.backgroundColor = [UIColor clearColor];
        [titleView setFont:[Fonts navBar]];
        titleView.textColor = [UIColor whiteColor];
        self.navigationItem.titleView = titleView;
    }
    titleView.text = title;
    [titleView sizeToFit];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


@end
