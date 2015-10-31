Studying permissions 
=============================
2015-10-30


In this document, I explore how permissions work on MacOsX, assuming it will work the same on Linux.


My goal is to backup an application's files and see what permissions problems may occur.
 
 
 
I start by creating the app tree:
 
``` 
- app 
----- config.txt
- cache
----- cache1.txt 
``` 

config.txt and cache1.txt contains a line of text, just to be able to check that the file's content is really
copied (and not just the file as a container).


This will be my basic setup.




 
The tar command
-------------------


### with different owner

Now I apply some permissions to the app tree, as follow:


```bash
tmp > tree -up
.
├── [drwxr-xr-x pierrelafitte]  app
│   └── [-rw-r--r-- pierrelafitte]  config.txt
└── [drwxr-xr-x _www    ]  cache
    └── [-rw-r--r-- _www    ]  cache1.txt
```


I made the cache directory owned by _www:_www.


Applying the tar -zcf command:

```bash
tmp > tar -zcf "boom.tar.gz" *
```

It seems that the copy could be performed without problems (I checked the files content too...).
Probably because all files in the original app tree had the read permissions for the "other" (world) permission group.
 
 
```bash
tmp > tree -up
.
├── [drwxr-xr-x pierrelafitte]  app
│   └── [-rw-r--r-- pierrelafitte]  config.txt
├── [drwx------ pierrelafitte]  boom
│   ├── [drwxr-xr-x pierrelafitte]  app
│   │   └── [-rw-r--r-- pierrelafitte]  config.txt
│   └── [drwxr-xr-x pierrelafitte]  cache
│       └── [-rw-r--r-- pierrelafitte]  cache1.txt
├── [-rw-r--r-- pierrelafitte]  boom.tar.gz
└── [drwxr-xr-x _www    ]  cache
    └── [-rw-r--r-- _www    ]  cache1.txt
```

### no read permission


Let's try that again, but with some files that have non readable permissions on them.

```bash
tmp > sudo tree -up
.
├── [drwxr-xr-x pierrelafitte]  app
│   └── [-rw-r--r-- pierrelafitte]  config.txt
└── [drwx------ _www    ]  cache
    └── [-rwx------ _www    ]  cache1.txt 
```
    

Applying the tar -zcf command:

```bash
tmp > tar -zcf "boom.tar.gz" *
tar: cache: Couldn't visit directory: Permission denied
tar: Error exit delayed from previous errors.
```    

The boom.tar.gz file was created, but we had some errors.
If we extract the boom.tar.gz file we see that the cache directory's content couldn't be copied.

```bash
tmp > sudo tree -up
.
├── [drwxr-xr-x pierrelafitte]  app
│   └── [-rw-r--r-- pierrelafitte]  config.txt
├── [drwx------ pierrelafitte]  boom
│   ├── [drwxr-xr-x pierrelafitte]  app
│   │   └── [-rw-r--r-- pierrelafitte]  config.txt
│   └── [drwx------ pierrelafitte]  cache
├── [-rw-r--r-- pierrelafitte]  boom.tar.gz
└── [drwx------ _www    ]  cache
    └── [-rwx------ _www    ]  cache1.txt
```


This might sound very obvious, but it doesn't hurt to double check.



Now what happens if we start over, but this time, use the super user to execute the tar command: 

```bash
tmp > sudo tar -zcf "boom.tar.gz" *
```    

This time, we have no permissions problems.
This is confirmed by printing the tree structure.

```bash
tmp > sudo tree -up
.
├── [drwxr-xr-x pierrelafitte]  app
│   └── [-rw-r--r-- pierrelafitte]  config.txt
├── [drwx------ pierrelafitte]  boom
│   ├── [drwxr-xr-x pierrelafitte]  app
│   │   └── [-rw-r--r-- pierrelafitte]  config.txt
│   └── [drwx------ pierrelafitte]  cache
│       └── [-rwx------ pierrelafitte]  cache1.txt
├── [-rw-r--r-- root    ]  boom.tar.gz
└── [drwx------ _www    ]  cache
    └── [-rwx------ _www    ]  cache1.txt
```






Conclusion
---------------

As far as lingula is concerned, the point here is that for some reasons,
an application could have permissions that make it impossible for a normal user to create a backup.
 
One possible workaround to create a backup is to execute the tar command as root.













