# ButterfieldToFreeAgent

A Swift command-line application that converts a CSV of transactions exported from Butterfield Online banking to a CSV format that is accepted by FreeAgent.com.

This is a port of a [Ruby version I wrote a few years ago](https://github.com/paulofierro/ButterfieldToFreeAgent).

The format is explained here: http://www.freeagent.com/support/kb/banking/file-format-for-bank-upload-csv/

## Running the app

You can run the script from the command line, by [downloading the binary in the `bin` folder](https://github.com/paulofierro/B2FA/blob/master/bin/b2fa) (built on macOS 10.15.5 (Catalina) with Swift 5.3) and running it via:

```
b2fa /path/to/my/file.csv
```

This will export the converted file to `/path/to/my/file-converted.csv`
