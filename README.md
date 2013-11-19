vagrant-xe11g
=============

Version 1.0.1 - Notes

Changed to smaller packer.io based box with VBox 4.3.2 VBGA
Turned off iptables in site_xe11g.pp script in the OS config section.



Motivation:

There are times you need an Oracle database, but you don't want to go into all of the effort and cruft of creating one.

This creates an Oracle XE 11g database which is fully functional to use with the HR schema unlocked in about 5 minutes.

It is very lean and mean.  It boots, via the Vagrantfile, with 512mb RAM allocated to the VM and has the bare minimum of files on the Vagrant box.
It also has 1GB of swap.

Kit Needed:

Oracle 11g XE R2

http://www.oracle.com/technetwork/products/express-edition/overview/index.html

These scripts use:

- oracle-xe-11.2.0-1.0.x86_64.rpm

I added some dba niceties for this box.

- The box now comes with the hostname xe11g.example.com.  I have removed the node information in the site_xe11g.pp file.
- vagrant user is a member of the dba group.
- I have added the oracle_env.sh script to the .bashrc for vagrant so you can use sqlplus in the command line
- Password are "oracle" for system and sys.  You can see those in the response file in the root of the project.
- Password for root is vagrant (all vagrant boxes).
- Related to (2) above, I have a really basic shell script that can be used to incorporate your own schemas when you do the vagrant up or run seperately.  It is a nice example that I found and hacked.
- You can access the database in either of the following ways from your host machine:

  - http://localhost:8080/apex
  - Via the normal tns listener port of 1521 from your host machine...for tools like JDeveloper or Eclipse.

~~The one area which I needed a little thought on is handling the swap file if you perform a halt.  I don't add the swap file which is created in the site pp to fstab.  If someone wants to help with that...I will welcome that.  Therefore, I would use a vagrant suspend command. Once running...why do you need to reboot now?  Just do a pause.~~

The fstab above has been resolved thanks to a repo that I found installing Oracle XE (great minds think alike)

https://github.com/rjdkolb/vagrant-ubuntu-oracle-xe/blob/master/modules/oracle/manifests/init.pp

I have added the solution to it to the OS2 class in the site_xe11g.pp

Also...oracle (the user and member of group dba), sounds like a movie doesn't it?  The user "oracle" doesn't have a password or a home directory.  Frankly, you don't need one since vagrant is in the dba group.  If you want to add a passowrd go ahead and su to root and run "passwd oracle" and then change the password.  If you want it persistant, then add a stanza to the site puppet file. 

I will be posting some more information on http://vbatik.wordpress.com so stay tuned. 

Enjoy...

/Matt

Twitter: @baldwinonline



