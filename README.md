# ButterfieldToFreeAgent

A Swift command-line application that converts a CSV of transactions exported from Butterfield Online banking to a CSV format that is accepted by FreeAgent.com.

This is a port of a [Ruby version I wrote a few years ago](https://github.com/paulofierro/ButterfieldToFreeAgent).

The format is explained here: http://www.freeagent.com/support/kb/banking/file-format-for-bank-upload-csv/

## Running the app

### 1. Automator
The included `AutomatorWorkflow` needs to be modified to point to wherever you place the `Butterfield2FreeAgent` binary.

1. Open the Workflow
2. Modify the path to the script in the `Run Shell Script` section
3. On the menu, click on `File > Convert To...`
4. Choose Application
5. On the menu, click on `File > Save`
6. Ensure the `File Format` is set to `Application`
7. Give the app a name and save it somewhere
8. Drag the app on to your Dock
9. Drag the CSV you want to convert onto the app icon in the Dock
10. The converted file will be exported to the same folder as `file-swift-converted.csv`

### 2. Command line (binary)
You can run the script from the command line, by [downloading the binary in the `bin` folder]() (built on macOS Mojave) and running it via:

```
/path/to/Butterfield2FreeAgent /path/to/my/file.csv
```

This will export the converted file to `/path/to/my/file-swift-converted.csv`


### 3. Command line (Swift)
If you have Xcode 10+ (or Swift 5+) installed, you can compile and run the code from the command line via:

```
swift main.swift /path/to/my/file.csv
```

This will export the converted file to `/path/to/my/file-swift-converted.csv`
