#!/usr/bin/env python


if __name__ == '__main__':
    import re, os, math, argparse, sys
    from time import gmtime, strftime 

    parser = argparse.ArgumentParser(description = \
        'This script parses the xml output from MS Sysinternals Autoruns. ' \
        'The Autoruns output should contain file hashes and verifification ' \
        'of digital signatures should be enabled. Using the command line ' \
        'version of Autoruns, Autorunsc, and running it as follows: ' \
        '\'autorunsc -a -v -f -x * > autoruns.xml\' ' \
        'will produce an output file called autoruns.xml that will contain ' \
        'all the desired elements.')
    parser.add_argument('filename', help = 'The XML output file from Autoruns.')
    if len(sys.argv) == 1:
        parser.print_help()
        quit()
    args = parser.parse_args()

    check_args(args)
