#!/usr/bin/env python3

from src.ShowdownLog import ShowdownLog
import glob

def main():
    test_files = glob.glob("example_logs/*.txt")[:10]
    for logfile in test_files:
        print("\nParsing Logfile: {}".format(logfile))
        dummy_log = ShowdownLog(logfile)
        dummy_log.get_initialteams()


if __name__ == "__main__":
    main()
