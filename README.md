vagrant-xe11g
=============

Motivation:

There are times you need an Oracle database, but you don't want to go into all of the effort and cruft of creating one.

This creates an Oracle XE 11g database which is fully functional to use with the HR schema unlocked in about 5 minutes.

It is very lean and mean.  It boots, via the Vagrantfile, with 512mb RAM allocated to the VM and has the bare minimum of files on the Vagrant box.
It also has 1GB of swap.

I added some niceties for this box.

1) vagrant user is a member of the dba group.
2) I have added the oracle_env.sh script to the .bashrc so you can use sqlplus in the command line
3) Password are "oracle" for system and sys.  You can see those in the response file in the root.
4) Password for root is vagrant (like..like all vagrant boxes) database.
5) Related to (2) above, I have a really basic shell script that can be used to incorporate your owne schemas when you do the vagrant up or sun seperately.

Enjoy...

/Matt

