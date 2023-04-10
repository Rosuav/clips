Clip logging
============

To fetch new clips for a channel, go to StilleBot and run:

    $ pike poll channelname/clips

This will create the .json files with metadata, and list any that have been
deleted (but will NOT remove them).

The directory here must already exist before poll.pike will do its work.

Note that this code isn't in poll.pike any more, but is nonfunctional and in
fetch.pike right here. So to use this, first make it work. Good luck. Have fun.