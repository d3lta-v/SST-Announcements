**THIS PROJECT HAS BEEN MOVED TO https://github.com/sammy0025/SST-Announcer, and this repository is NO LONGER BEING UPDATED**
**SST Announcer**
==========================
Made by StatiX Industries  

##Name:
* SST Announcer

##Synopsis:
The Application is used for fetching RSS feeds over the Internet  
Also, the app can push notifications to the user's iDevice (automatically registers with StatiX Push servers)
Feed source: http://studentsblog.sst.edu.sg/feeds/posts/default?alt=rss
  
1. Has inbuilt table that displays RSS feeds.
2. Has loading indicator.
3. Is able to display multiple categories of the blog (fetches data)
4. Pushes notifications to the user when the feed is updated (via StatiX Push, our own in-house push system)
  

##Availability:
The App is only usable on the UNIX Darwin ARMv7 iOS 7.0+ platform
Devices compatible include the iPhone 4 and up, iPad 2 and up as well as iPod Touch 4rd Gen and up
Compiles on iOS SDK 8.0, downwards compatible to iOS 7.0


##Description:
The Application is made for fetching RSS feeds from the abovementioned URL. Other than that, it also pushes notifications to the user's iDevice via UrbanAirship's push notification function.
  
##Author(s):
StatiX Industries:
* Lead Developer and Debugger: Pan Ziyue
* Graphics Designer: Christopher Kok
* Beta Tester: Liaw Xiao Tao
  

##Caveats:
* The Xcode Project file must be opened in Xcode 6 for iOS 8 SDK
* You need to import the DTCoreText library manually or it will NOT compile!

##Dependencies:
* SVProgressHUD
* DTCoreText


##License:
* GNU Public License v2


##Final Note:
Yes I wrote it in the format of a UNIX command manual page
  
Copyright (C) StatiX Industries 2013-2014
