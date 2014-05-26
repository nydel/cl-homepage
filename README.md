:cl-homepage package

[simple commonlisp w3 home fetched via py/pl](http://nydel.sdf.org)

this is a simple :hunchentoot accessor running on some trivial unprivileged port
with something other than lisp running a simple cgi get on the lisp page itself
so you can run yourself a webserver on (e.g.) port 9903 then instruct a simple
python or perl etc script to simply fetch your lisp page's source then format it
to the stdout.  why this is necessary:

1) we don't always have access to our apache/httpd/nginx's config
2) sometimes proxy-passing and forwarding doesn't work neatly as we hope
3) even if you run mod_lisp you'll need a lisp cgi script to read from the lisp
   webserver's index on its unique port and
4) mod_lisp is not as common as mod_python or mod_perl etcetera
5) lisp scripting is not ideal; while we'd like to use only cl, it's sometimes
   unrealistic - here we need no more than a #!/shebang and a quick html fetch
   from our scripting language in order to work otherwise in pure lisp

this project was started by nydel for a new home on a shared server at sdf.org
and will develop at nydel's page developes; the project/system's theory and need
are very real and we hope people will either directly modify this repository or
feel encouraged to fork it to their own customization.

there is a lot we can do besides spit out a simple static homepage. that is the
true goal of this and many of my other projects - to utilize common lisp for
everyday w3 development.  here follow some desired features:

-- a series of simple applications, the first being homepage, another could be
-- weblog application, requesting creation and retrieval of weblog objects
-- some simple language for implementing these lisp widgets. also we need a name
   for the widgest associated with this project and projects like it (do see my
   ongoing development system :cl-psara which is a less stripped version of this
   in essence.

watch/follow and/or write to nydel at ma dot sdf dot org if you've any interest
in this project or projects like it, i will appreciate to hear from you.
