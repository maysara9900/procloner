# Procloner

Procloner collects information about a running process.

**Collected information:**

* Command used to run the process
* Process state "Running, Sleeping .. etc"
* Process current working directory
* Process start time
* Process owner
* Thread count
* A copy of the process executable
* MD5 and SHA1 hashes of the executable
* Loaded libraries by the process
* Current network connections
* Current opened file descriptors
* Process environment variables
* Current kernel stack
* Tree of children processes

**Usage**
```
You must run as root
Usage: sudo ./procloner.sh -p process ID
  -p, --process   Target process ID
Example: ./procloner.sh -p 4444
```

**Sample output** "reduced to fit in a screenshot :D"

![](https://i.imgur.com/xpzqKwd.png)

