//
//  UITableTableViewController.swift
//  Journal
//
//  Created by Alex Arovas on 12/21/15.
//
//

import UIKit

class UITableTableViewController: UITableViewController {
    var json_data_url = "http://www.kaleidosblog.com/tutorial/json_table_view_images.json"
    var image_base_url = "http://www.kaleidosblog.com/tutorial/"
    var TableData:Array< datastruct > = Array < datastruct >()
    struct datastruct
    {
        var imageurl:String?
        var description:String?
        var image:UIImage? = nil
        
        init(add: NSDictionary)
        {
            imageurl = add["url"] as? String
            description = add["description"] as? String
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        
        var data = TableData[indexPath.row]
        
        
        cell.textLabel?.text = data.description
        
        if (data.image == nil)
        {
            cell.imageView?.image = UIImage(named:"image.jpg")
            load_image(image_base_url + data.imageurl!, imageview: cell.imageView!, index: indexPath.row)
        }
        else
        {
            cell.imageView?.image = TableData[indexPath.row].image
        }
        
        
        return cell
    }

    func load_image(urlString:String, imageview:UIImageView, index:NSInteger)
    {
        
        var imgURL: NSURL = NSURL(string: urlString)!
        let request: NSURLRequest = NSURLRequest(URL: imgURL)
        NSURLConnection.sendAsynchronousRequest(
            request, queue: NSOperationQueue.mainQueue(),
            completionHandler: {(response: NSURLResponse?,data: NSData?,error: NSError?) -> Void in
                if error == nil {
                    self.TableData[index].image = UIImage(data: data!)
                    self.save(index,image: self.TableData[index].image!)
                    
                    imageview.image = self.TableData[index].image
                    
                }
        })
        
    }

func get_data_from_url(url:String)
    {
        let httpMethod = "GET"
        let timeout = 15
        let url = NSURL(string: url)
        let urlRequest = NSMutableURLRequest(URL: url!,
            cachePolicy: .ReloadIgnoringLocalAndRemoteCacheData,
            timeoutInterval: 15.0)
        let queue = NSOperationQueue()
        NSURLConnection.sendAsynchronousRequest(
            urlRequest,
            queue: queue,
            completionHandler: {(response: NSURLResponse?,
                data: NSData?,
                error: NSError?) in
                if data!.length > 0 && error == nil{
                    let json = NSString(data: data!, encoding: NSASCIIStringEncoding)
                    self.extract_json(json!)
                }else if data!.length == 0 && error == nil{
                    print("Nothing was downloaded")
                } else if error != nil{
                    print("Error happened = \(error)")
                }
            }
        )
    }
    func read()
    {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        let fetchRequest = NSFetchRequest(entityName: "Images")
        
        var error: NSError?
        let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error)
            as! [NSManagedObject]?
        
        if let results = fetchedResults
        {
            for (var i=0; i < results.count; i++)
            {
                let single_result = results[i]
                let index = single_result.valueForKey("index") as! NSInteger
                let img: NSData? = single_result.valueForKey("image") as? NSData
                
                TableData[index].image = UIImage(data: img!)
                
            }
        }
        
    }
    
    func save(id:Int,image:UIImage)
    {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        let entity = NSEntityDescription.entityForName("Images",
            inManagedObjectContext: managedContext)
        let options = NSManagedObject(entity: entity!,
            insertIntoManagedObjectContext:managedContext)
        
        var newImageData = UIImageJPEGRepresentation(image,1)
        
        options.setValue(id, forKey: "index")
        options.setValue(newImageData, forKey: "image")
        
        var error: NSError?
        managedContext.save(&error)
        
    }
    
    func extract_json(data:NSString)
    {
        var parseError: NSError?
        let jsonData:NSData = data.dataUsingEncoding(NSASCIIStringEncoding)!
        let json: AnyObject? = NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.AllowFragments)
        if (parseError == nil)
        {
            if let list = json as? NSArray
            {
                for (var i = 0; i < list.count ; i++ )
                {
                    if let data_block = list[i] as? NSDictionary
                    {
                        
                        TableData.append(datastruct(add: data_block))
                    }
                }
                read()
                do_table_refresh()
                
            }
            
        }
    }
    
    
    
    
    func do_table_refresh()
    {
        dispatch_async(dispatch_get_main_queue(), {
            self.tableview.reloadData()
            return
        })
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
