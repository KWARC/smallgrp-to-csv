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
