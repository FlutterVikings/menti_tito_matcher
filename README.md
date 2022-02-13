# Tito Matcher

This is a simple script to match Menti winners with Ti.to tickets.

## How to run

- first, add CSV files for each quiz
- go to `main.dart` and modify example with proper file name and path under `main` function
- then run `dart run main.dart --define=ACCOUNT_SLUG=??? --define=EVENT_SLUG=??? --define=TOKEN=???`
- finally, generated CSV files will be created in the root of project.

## CSV format

The CSV is extracted from "Export results" in Menti

```shell
position;name;score
1;EUWD-1;7522
2;FGLR-1;6550
3;:tropical_fish:;6500
4;N6QX-1;5742
5;4Y8F-1;5732
```
