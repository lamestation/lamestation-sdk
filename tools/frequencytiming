#!/usr/bin/env python

import os, sys
import argparse


MIDINOTES = 128
ROOTNOTE = 16.35 # This is C0


def pitch (F0, n):
    return F0*pow(2,(n/12.0))






parser = argparse.ArgumentParser(description='Generate frequency tables for use with LameStation audio modules.')
parser.add_argument('-c','--clkfreq', type=int, default=80000000, help='Propeller clock speed')
parser.add_argument('-p','--period', type=int, default=2000, help='PWM period')
parser.add_argument('-s','--samples', type=int, default=512, help='Number of frames in a sample')


args = parser.parse_args()

print "Run this command with '--help' to see a full list of options"


CLKFREQ = args.clkfreq
PERIOD = args.period
SAMPLES = args.samples

print
print "    Clkfreq:", CLKFREQ
print "     Period:", PERIOD
print "    Samples:", SAMPLES

FS = CLKFREQ/PERIOD
FCmin = FS/SAMPLES

print "Sample Rate:", FS, "Hz"
print "      FCmin:", FCmin, "Hz"

print "\nGenerating frequency values..."



realFrequency = []
incrementFrequency = []

for i in range(0,MIDINOTES):
    realFrequency.append(pitch(ROOTNOTE, i))
    incrementFrequency.append(int(pow(2.0,12.0)*realFrequency[i]/FCmin))
#    print "%10i" % i, "%10.2f" % realFrequency[i], "%10i" % incrementFrequency[i]


dirname = "freqtable"

if not os.path.exists(dirname):
    os.mkdir(dirname)



print "Generating tables... "

print "   PASM table..."

f = open(os.path.join(dirname,"freqtable.spin"),'w')
f.write("freqTable")

for i in range(0,MIDINOTES):
    if i % 8 == 0: f.write("\nlong\t\t")
    f.write(str(incrementFrequency[i]))
    if not i % 8 == 7: f.write(", ")

f.write("\n")
f.close()





print "   C table..."

f = open(os.path.join(dirname,"freqtable.c"),'w')
f.write("int frequencytable[] = {")
f.write(str(incrementFrequency[0]))

for i in range(0,MIDINOTES):
    f.write(","+str(incrementFrequency[i]))
    if i % 10 == 9: f.write("\n            ")

f.write("};\n")
f.close()







print "   LaTeX table... "

f = open(os.path.join(dirname,"freqtable.tex"),'w')

f.write("\\begin{figure}[H]\n")
f.write("  \\begin{center}\n")
f.write("    \\small\n\n")
f.write("    \\begin{tabular}{ c | c c c c }\n")
f.write("Note & Frequency (Hz)")
f.write(" & Freq x 2\\textsuperscript{16} (Hz)")
f.write(" & F\\textsubscript{C}/F\\textsubscript{CSAMPLEMIN} &  \\\\\ \n\\hline\n")

linecounter = 0
for i in range(0,MIDINOTES):
    f.write(str(i))
    f.write(" & ")
    f.write(str(realFrequency[i]))
    f.write(" & ")
    f.write(str(incrementFrequency[i]))
    f.write(" & ")
    f.write(str(realFrequency[i]/(pow(2.0,16.0)*ROOTNOTE)))
    f.write(" & \\\\ \n")

    linecounter += 1
    if linecounter > 44:
        f.write("    \\end{tabular}\n\n")
        f.write("  \\end{center}\n")
        f.write("\\end{figure}\n")

        f.write("\\newpage\n")

        f.write("\\begin{figure}[H]\n")
        f.write("  \\begin{center}\n")
        f.write("    \\small\n\n")
        f.write("    \\begin{tabular}{ c | c c c c }\n")

        f.write("Note & Frequency (Hz)")
        f.write(" & Freq x 2\\textsuperscript{16} (Hz)")
        f.write(" & F\\textsubscript{C}/F\\textsubscript{CSAMPLEMIN} &  \\\\\ \n\\hline\n")

        linecounter = 0

f.write("    \\end{tabular}\n\n")
f.write("  \\end{center}\n")
f.write("\\end{figure}\n")

f.close()

print "Tables printed to: ", dirname+"/"
