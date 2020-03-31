# handling-zipped-source-and-config
Pushing content of zipped source to github and storing on artifactory using batch script.

## Description
Grabbing contents of zipped source and pushing to a repository using git, as well as storing the zip itself on artifactory.

### The script
The script itself is a batch script, written specifically for Windows use. It is purposefully trying to minimize the prerequisites needed from the system running it, hence using portable git and mostly pure batch, except for a singular powershell command. The script makes use of `curl`, which was introduced in Windows 10, version 1909, but older versions have built-in alternatives.