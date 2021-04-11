#!/usr/local/bin/python

# batches untranslated indexes from json
# to be copied into translators in bulk
# and then matches up the results and
# adds them to the json

import argparse, json, pprint, re, pyperclip #, os, re, sys;
#import unicodedata

argparser = argparse.ArgumentParser(description='parse scenario to mplayer list');
argparser.add_argument("-s", "--source", required=True, dest="source", help="source file")
argparser.add_argument("-o", "--output", required=True, dest="output", help="output file")
argparser.add_argument("-b", "--batchsize", required=False, type=int, default=20, dest="batchsize", help="batch size")
argparser.add_argument("-u", "--untranslatedindex", required=False, type=int, default=0, dest="uidx", help="untranslated index")
argparser.add_argument("-t", "--translatedindex", required=False, type=int, default=1, dest="tidx", help="translated index")
args = argparser.parse_args();



# gathers a batch of strings to convert, and pairs them with indexes for later reference
def gatherbatch():
    global count;
    batchcount = 0;
    batch = '';
    batchindex = {};

    for n in transindex:

        # check if its already translated, skip it
        if(str(args.tidx) in n):
            continue;

        batch += "[%u]\n" % count;
        batch += cleanupraw(n[str(args.uidx)]) + "\n\n"
        batchindex["[%u]" % count] = n;

        count += 1;
        batchcount += 1;
        if(batchcount >= args.batchsize):
            break;
    if(batchcount == 0):
        raise EOFError;

    print batch
    pyperclip.copy(batch);
    return batchindex;

# cleans up raw translations
def cleanupraw(raw):
    return raw.strip('0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ');

# matches translations back up with the raw using the indexes
def matchbatch(batchindex):
    batch = pyperclip.paste();
    batch = batch.split('\n');
    found = 0;
    matched = 0;
    for n in range(len(batch)):
        if(len(batch[n]) > 2 and batch[n][0] == '['):
            found += 1;

            if(batch[n] in batchindex):
                matched += 1;
                batchindex[batch[n]][str(args.tidx)] = batch[n + 1];
                print "Original:   " + batchindex[batch[n]][str(args.uidx)]
                print "Translated: " + batchindex[batch[n]][str(args.tidx)]

    if(matched == 0):
        raise LookupError;

    return "Found %u, Matched %u" % (found, matched);

# main
srcf = open(args.source, 'r');
transindex = json.load(srcf);
count = 0;

try:
    # main loop
    while(True):
        batchindex = gatherbatch();
        raw_input("Press Enter when translations are copied...");
        status = matchbatch(batchindex);
        raw_input(status + ", Press Enter to continue...");

        with open(args.output, 'w') as outf:
            json.dump(transindex, outf, sort_keys=True, indent=1, ensure_ascii=False);

except EOFError as e:
    print "Finished Translation.";

except LookupError as e:
    print "Found zero matches, bad buffer";

except KeyboardInterrupt as e:
    print "Quitting.";


