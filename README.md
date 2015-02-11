# README #

### Abstract ###
Campus Flora maps the locations of more than 2000 individual plants from over 70 families on campus grounds and provides a botanical description of each plant and information on its distribution. Campus Flora not only extends the teaching of botany from the classroom into the University of Sydney campus grounds but it enables us to share our learning resources with the broader community.

“Trails” highlight the important aspects of select plant groups and we have initially developed these to align with the current botanical curriculum. We encourage those using Campus Flora to provide us with feedback: each species page allows users to offer feedback, and we will use this to shape future versions and develop additional trails.
 
The project team acknowledges the support of the School of Biological Sciences and University grounds staff.
 
Project team:  Rosanne Quinnell, Lachlan Pettit, Matthew Pye, Angela Pursey, Xiaolong Wang, Nic Barker (bitbucket / github username nicbarker), Caroline Cheung, Grant Zeng.
  
This web repository was built and maintained by Nic Barker and as a result all tech related questions should be directed to him.

This README aims to document the design process behind the app, as well provide instructions on branching and installing your own copy of the app for your institution or just for personal interest.  

## Stack
### Backend ###
* rbenv -> ruby 2.2.0
* Rails 4
* Passenger
* Nginx
* MySQL via mysql2 gem

### Frontend ###
* CoffeeScript
* SCSS
* Backbone.js
* Google maps Javascript API

### Deployment ###
* Capistrano 3

## Install Requirements ##
Campus Flora runs on Ruby On Rails - and while you can certainly run this on a simplified service provider like Heroku, it's recommended that you run this on a plain old Linux VPS.  
The University of Sydney is using Digital Ocean for this project, but there are many others such as Linode or even Amazon AWS that are all great.

## Install Guide ##
### Local modifications ###
Before you start trying to deploy campus flora you're going to want to make some local modifications to the rails app:
* Change the ip address listed in config/deploy/production.rb to point to your server
* Change the github url in config/deploy.rb to point to your repository if you've forked the repo
* Change the URL in config/sitemap.rb to point to the domain you'll be using for the production version of the site
* Create the file config/application.yml and set the variables DATABASE_USER, DATABASE_PASSWORD, SECRET_KEY_BASE and DEVISE_SECRET.

### Server setup (Blank server) ###
* Log into your VPS __as root (important!)__
* Download and run the Rbenv + Rails + Nginx + Passenger + MySQL installer from installscripts.io - [http://installscripts.io/rails-passenger-nginx-mysql-rbenv](http://installscripts.io/rails-passenger-nginx-mysql-rbenv)
```
#!bash
wget -O /tmp/rails-passenger-nginx-mysql-rbenv.sh http://installscripts.io/scripts/rails-passenger-nginx-mysql-rbenv.sh
sh /tmp/rails-passenger-nginx-mysql-rbenv.sh
```
* Note this script will take some time (20+ minutes on smaller VPS's) so grab a cup of coffee. The script will prompt you right at the end to set up your nginx config in a way that is relatively simple, then ask you to set your mysql root password.
* There is also a script available for installing this stack using the [unicorn server instead of passenger.](http://www.installscripts.io/scripts/rails-unicorn-nginx-mysql-rbenv)
* Install imagemagick (used for image uploads):
```
#!bash
sudo apt-get install imagemagick --fix-missing
```
* Create a linux user called deploy, and give it permissions to the /srv/ directory where you'll be serving campus flora from:
```
#!bash

adduser deploy
chown -R deploy /srv
chgrp -R www-data /srv

```
* Log out of the VPS
* Copy your ssh key to the /home/deploy/.ssh/authorized_keys
```
#!bash
scp ~/.ssh/id_rsa.pub root@server_ip_address:
ssh root@server_ip_address
cat id_rsa.pub >> /home/deploy/.ssh/authorized_keys
```
* Try deploying with cap production deploy:migrations
* If it was succesful, your app should be running at your.ip:80, or whatever domain name you've specified.