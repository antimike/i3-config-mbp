#!/bin/zsh
# Adds text in system clipboard to a static queue
# Intended for use with URLs

# @TODO Implement archive and bookmarking services to act on queue

queue=${URL_QUEUE:-/home/archivebox/inbox/urls.txt}

print -l $(xclip -sel clip) >>$queue
