# sh2probe

This is a bash script to query a BT Smart Hub 2 from the command line. For example to poll
the assigned IPv6 address range, usage data, etc.

The required step are
1. Get session cookie
2. Call login script with the hash of the hub manager password
3. Call whichever .js script returns to desired information

The data is returned as javascript with values in variables. Parsing the output is an 
exercise for the reader...
