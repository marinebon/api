# api
custom application programming interface (API) to query marine biodiversity

## Run the API

### start

Run the API in the background from server's RStudio Terminal:

```bash
# run as root and send to background (&)
sudo Rscript /share/github/marinebon/api/run-api.R &
```

### stop

```bash
# get the process id of the running service
ps -eaf | grep run-api
# bebest     48394   43484  0 Aug17 pts/1    00:09:24 /usr/local/lib/R/bin/exec/R --no-save --no-restore --no-echo --no-restore --file=/share/github/api/run-api.R
# bebest     65066   43484  0 19:57 pts/1    00:00:00 grep --color=auto run-api
sudo kill -9 48394
# [1]+  Killed                  Rscript /share/github/api/run-api.R
```
