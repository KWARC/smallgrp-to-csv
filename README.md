Code for generating the data for the mostly512.net website (or whatever we're
calling it!)

Called as follows (assuming you're in this directory, with GAP installed in a
directory next to it):

    $ ../gap/bin/gap.sh smallgrp_parallel.g
    gap> write_smallgrp_csv("out.csv", [1 .. 1023], 60);

to run it on all groups of order up to 1023, using 60 parallel threads, and
output the results in a file called `out.csv`.

On the *monster* server, I estimate this would take about 4 days, so this is
probably feasible.

We probably want to fix the output by running

    $ cat *.csv | sed ':a;N;$!ba;s/\\\n//g' | sort -Vu | sed '1h;1d;$!H;$!d;G' > all.csv

a pipeline which does the following:

    * concatenates all csv files in the directory
    * cleans up line breaks
    * sorts the results
    * moves the header line back to the start

This has now been run to completion for [1 .. 1023], resulting in a file of size
915 MB (or 49MB after gz compression).  That's probably too big to put in this
repository.

To get a json file out of this (in the format KB suggested) we can run

    $ sed '1s/^.*$/\[/;s/^\(\([0-9]*,\)\{2\}\(true,\|false,\)\{4\}\([0-9]*,\)\)\([0-9]*,[0-9]*\),\(.*\)$/  [\1[\5],"\6"],/g;$a\]' all.csv > all.json

and use `all.json` to create a server (I actually compressed this and committed
it to this repo anyway!)
