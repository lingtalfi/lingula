Lingula
=============
2015-10-30


Simple backup utility for unix systems



Audience
------------

Lingula might be helpful if you have a production server containing applications that you want to backup.


What does it do?
------------

Lingula:

- dumps your database (if you use one)
- creates a tarball file (tar.gz) containing both your application files and your database dump 
- put the tarball file in a directory of your choice, and handles backup rotation on this directory 


Amongst the benefits of using lingula, we can name the following:

- lingula centralizes all your projects, so it's easy to add a new project
- lingula is simple to use and easy to customize 
- lingula is cron friendly




How to use?
--------------

First, make the lingula command [available system wide](https://github.com/lingtalfi/webmaster-tricks/blob/master/tricks/bash.make-command-system-wide-available.md). 

Then, configure a project you want to backup.
You should be able to figure out how to do so by reading the "Lingula tasks" and "A default config file" sections below.
You can configure as many projects as you like.

The last thing you need to do is call the lingula command.
Just specify the config file you are using (if you have many), and the project you want to use.

```bash
lingula -c me.txt -p martin
```

More info in the bash manager documentation.

You could set a cron job if you wanted to, or call the lingula program manually.



### Permissions

Since your config files will contain database passwords, I would recommend that the config.d directory and 
its content is owned by root and that the config files are only accessible by the root user (chmod 700).
Then to execute lingula command, you should naturally use the root user.





	 
How does it work internally?
------------------------------

The core script of lingula is actually the [bash manager](https://github.com/lingtalfi/bashmanager) core script version 1.08.
This basically means that if you read the bash manager's documentation, you know all there is to know about lingula.

As for any bash manager software, lingula has its own tasks that make it so special.
In the next section, we will review the lingula tasks.


Lingula Tasks
----------------
 
 
- chrono_start.sh

- tmp_depository_path.sh
- depository_path.sh

- mysql_db.sh
- tarballs.sh
- rotate.sh

- chrono_stop.sh



If you don't know how to configure tasks, please refer to the bash manager documentation.


### chrono_start

This task starts the virtual chronometer.
This task is optional but using the virtual chronometer allows us to know how much seconds it took to execute the lingula script.
With this knowledge, we can better choose the moment of the day when we want to execute the task (useful if you use a cron script for instance).
The task value is the location of the timer file, which is used by lingula to write the "time report" of the session.



### tmp_depository_path


The goal of this task is to set the location of the temporary depository directory.
The expected value for this task is the temporary depository directory.
The temporary depository directory is used by the tarballs tasks (described in an other section).
It's a temporary location where the backup files are stored before they are moved to their 
final destination: the depository directory.

Note that the default value for the tmp_depository_path is /tmp/lingula/temporary_depository; it's defined 
in the [home]/config.defaults file.


### depository_path


The goal of this task is to set the location of the depository directory.
The expected value for this task is the depository directory.
The depository directory is used by the tarballs tasks (described in an other section).
It's the directory where the backup files are stored in the end.

Note that the default value for the depository_path is /tmp/lingula/depository; it's defined 
in the [home]/config.defaults file.




### mysql_db

The goal of this task is to backup the database.
The value of this task must contain 3 components separated with the colon separator.
The components are the database name, the user, and the password.

It looks like this:

    <databaseName> <:> <userName> <:> <password>
    
    my_database:my_db_user:D870sdfeZ



### tarballs


The tarballs task performs multiple actions:

- it creates the archive (.tar) in the tmp_depository_path (temporary depository directory)
- it compresses the archive to a tarball (tar.gz)
- it moves the tarball to the depository_path (depository directory)
- it creates a symbolic link to that tarball. 
        That's because the symbolic link name is more concise than the full backup file name (which contains the date and other things)   



The expected task value is the location of the application to backup (the directory that you want to backup).



### rotate

To lingula, rotation is the action of scanning the backup tarballs (depository_path) and removing old backups depending on certain criterion.
It helps having a backups directory that doesn't grow indefinitely in size.

The way the rotate task removes old backup files is called the mode.
There are two modes available:

- number based mode:
    we specify a number x which represent the maximum number of tarballs allowed in the depository
    
- mtime based mode:
    we specify a max age threshold.
    Files older than that threshold are removed.
    
    
The notation for number based mode is the following:
    
    <n=>  <number>
    n=10    
    
    
The notation for the mtime based mode is the following:
    
    (<number> <unit>)+
    1y          
    2m          
    1m3d
              
The possible unit values are:
              
- y: year              
- m: month              
- d: day             
- h: hours           
- i: minutes              
              
              
### chrono_end

This task ends the virtual chronometer, and display the time statistics: when the chronomoter
was started, when it stopped, and the number of seconds in between.
         
    
    
    
    

	 
A default config file
------------------------------    
    
The default config file is [home]/config.d/me.txt
It's content configures two imaginary projects: martin and miles.

```


chrono_start:
martin=/tmp/lingula/timers/martin.txt
miles=/tmp/lingula/timers/miles.txt



tmp_depository_path:
martin=/tmp/lingula/tmp_depository



depository_path:
martin=/tmp/lingula/other_depository


mysql_db:
martin=martin:root:root
miles=miles:root:root


tarballs:
martin=/path/to/myapps/martin/application
miles=/path/to/myapps/miles/www



rotate:
martin=+1y


chrono_stop:
martin=
miles=

```
    
    
Notice that:
    
    
- the miles project doesn't define the tmp_depository_path and depository_path values.
        Those task have default values, and so the miles project will implicitely inherit the default values (defined in [home]/config.defaults)
- the miles project did not register to the rotate task, which means that the depository for the miles projects
        will accumulate the backups forever.
- martin and miles projects subscribes to the chrono_stop, even if they don't specify a value.
        This is required, otherwise the virtual chronometer won't stop.
        
    
    
    
    
    
History Log
------------------
    
- 1.0.0 -- 2015-10-31

    - initial commit
    
        



        
    













