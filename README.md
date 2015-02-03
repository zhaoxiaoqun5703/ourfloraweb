# README #

### Abstract ###
CampusFlora is an application ecosystem and database that allows you to view and locate flora on Sydney Uni campus. It was built initially as an iOS app by a small team lead by Rosanne Quinnel at the University of Sydney, Australia in 2014.  
The web version of this project was built by Nic Barker (bitbucket username nicbarker) in early 2015, with the aim of separating the database from the front end implementation.
Sydney Uni's implementation of the site is always hosted live at [campusflora.sydneybiology.org](http://campusflora.sydneybiology.org), and the iOS app is available at [itunes.apple.com/au/app/campus-flora/id918408102?mt=8](https://itunes.apple.com/au/app/campus-flora/id918408102?mt=8)  
  
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

### Server setup (Blank server) ###
* Log into your VPS as root
* Download the Rbenv + Rails + Nginx + Passenger + MySQL installer from installscripts.io - [http://installscripts.io/rails-passenger-nginx-mysql-rbenv](http://installscripts.io/rails-passenger-nginx-mysql-rbenv)
* Run the script as root
* Download the sample passenger nginx config from installscripts.io
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
* Try deploying with cap production deploy:migrations
* If it was succesful, your app should be running at your.ip:80, or whatever domain name you've specified.