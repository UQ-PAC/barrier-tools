#!/usr/bin/python3
import difflib
import sys
import json
import pprint
import re

pp = pprint.PrettyPrinter(indent=4)

left = ""
right = ""

usage = """format-veri-output

Usage: format-veri-output filename [--nobil] [regex] > file.html

Formats a bap-veri output file to html 

    regex   : param matches agains the instruction. 
    --nobil : only show those with no BIL output
    --bil   : only show those with BIL output
    --dedup : only show one instance of each instruction on the same registers
                (regardless of register values)
"""

if len(sys.argv) < 2:
    print(usage)
    exit()

fname = None
nobil = False
onlybil = False
dedup = False
match = ".*"

if len(sys.argv) >= 2:
    for i in range(1, len(sys.argv)):
        print(sys.argv[i])
        if sys.argv[i] == "--nobil":
            nobil = True
        elif sys.argv[i] == "--bil":
            onlybil = True
        elif sys.argv[i] == "--dedup":
            dedup = True
        else:
            if "--" in sys.argv[i]:
                print(usage)
                exit()

            if fname is not None:
                match = sys.argv[i]
            else:
                fname = sys.argv[i]


reg = re.compile(match)

with open(fname, "r") as f:
    lines = f.readlines()


UNK = 0
SEP = 1
BLOCK = 2
BIL = 3
SUMMARY = 4

state = 0

ins = {}
blocks = []
if dedup:
    blocks = {}

bil = ""
pcount = 0
summary = ""

for line in lines: 
    if "================================================================" in line:
        if state == BLOCK:
            ins['left'] = left
            ins['right'] = right
            left = ""
            right = ""
            if dedup:
                blocks[ins['isn']] = ins
            else:
                blocks.append(ins)
            ins = {}
        state = SEP 
        continue

    if state == SEP:
        ins["isn"] = line.strip()
        state = BLOCK
        continue

    if "{" in line:
        pcount += line.count("{")
        bil = ""
        if state == BLOCK:
            pcount = 1
            state = BIL
            continue

    if "}" in line:
        pcount -= line.count("}")
        if state == BIL and pcount == 0:
            state = BLOCK;
            ins['bil'] = bil
            bil = ""
            continue

    if state == BIL:
        bil += line
        continue

    if state == BLOCK:
        if "left" in line:
            left += line.replace("left:", "").strip() + "\n"
        elif "right" in line:
            right += line.replace("right: ","").strip() + "\n"
        else:
            left += line.strip() + "\n"
            right += line.strip()+ "\n"

    if 'misexecuted' in line:
        state = SUMMARY

    if state == SUMMARY:
        summary += line


print("""
        <head> 
        <style type="text/css">
        table.diff {font-family:Courier; border:medium;}
        .diff_header {background-color:#e0e0e0}
        td.diff_header {text-align:right}
        .diff_next {background-color:#c0c0c0}
        .diff_add {background-color:#aaffaa}
        .diff_chg {background-color:#ffff77}
        .diff_sub {background-color:#ffaaaa}
    </style>
        </head>
        """)
print("<body>")
print("<p> Left is qemu, right is BIL </p>")
print("<pre>")
print(summary)
print("</pre>")
b = blocks
if dedup:
    b = blocks.values()
for ins in b:
    if len (ins['bil'].strip()) == 0:
        if onlybil:
            continue
    else:
        if nobil:
            continue
    if (reg.match(ins['isn'])):
        ins['htmldiff'] = difflib.HtmlDiff().make_table(ins['left'].split("\n"),
                ins['right'].split("\n"))
        print (f"<h3><code> {ins['isn']} </code></h3>")
        print("<pre>")
        print(ins['bil'])
        print("</pre>")
        print(ins['htmldiff'])
        print("<hr>")


print("</body>")

