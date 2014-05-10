#!/usr/bin/python

print "content-type: text/html;charset=utf-8"
print
print

import urllib2
results = urllib2.urlopen("http://nydel.sdf.org:9903/").read()

print results
