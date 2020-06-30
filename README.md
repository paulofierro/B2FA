# ButterfieldToFreeAgent

A Swift command-line application that converts a CSV of transactions exported from [Butterfield Online](http://www.butterfieldgroup.com/) banking to a CSV format that is accepted by FreeAgent.com.

This is a port of a [Ruby version I wrote a few years ago](https://github.com/paulofierro/ButterfieldToFreeAgent).

The format is explained here: http://www.freeagent.com/support/kb/banking/file-format-for-bank-upload-csv/

## Running the app

You can run the script from the command line, by [downloading the latest release](https://github.com/paulofierro/B2FA/releases) and running it via:

```
b2fa /path/to/my/file.csv
```

This will export the converted file to `/path/to/my/file-converted.csv`
