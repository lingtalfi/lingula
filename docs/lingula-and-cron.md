Lingula and cron
====================
2015-10-31





Create a backup of project miles every day at 4:00am.


```bash
crontab -e
# Add the following line to your cron table
* 4 * * * /path/to/lingula.sh -c myconf  -p miles
```




Create a backup once at 2015-10-31 4:00am

Create a file **/path/to/script** with the following content in it:

```
/path/to/lingula.sh -c myconf  -p miles
```

Then type the following command in your terminal:

```bash
at -t 201510310400 < /path/to/script 
```


