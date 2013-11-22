#include <stdio.h>
#include <math.h>

#define NOTES   128
#define fFCMIN  55.0/4.0
#define FCsamplemin     55.0


//Propeller definitions
#define PROPNOTES   128
//#define sysclk      79787884
#define sysclk      80000000

#define A440        36909

#define PWMperiod   3200
#define fFCPROP     13.75
#define fSAMPLES    512.0

float pitch (float Fnaught, int n) {
    return Fnaught*pow(2,((float) n)/12.0);
}

int main (void) {

    FILE * tableP = fopen("frequencytable_PASM.txt","w");
    FILE * tableL = fopen("frequencytable_LaTeX.txt","w");
    FILE * tableC = fopen("frequencytable_C.txt","w");

    //Generate frequency table for the Propeller
    float fFrequencyP[PROPNOTES];
    unsigned int iFrequencyP[PROPNOTES];

    float fFs = ((float) sysclk)/((float) PWMperiod);
    float fFCMINPROP = fFs/fSAMPLES;


    for(int i = 0; i < PROPNOTES; i++) {
        fFrequencyP[i] = pitch(fFCPROP, i);
        iFrequencyP[i] = (int) (pow(2.0,12.0)*fFrequencyP[i]/fFCMINPROP);
    }

    printf("Generating PASM table... ");

    fprintf(tableP,"freqTable");
    for(int i = 0; i < PROPNOTES; i++) {
        if (i % 8 == 0) fprintf(tableP, "\nword\t");
        fprintf(tableP,"%i",iFrequencyP[i]);
        if (i % 8 != 7) fprintf(tableP,", ");
    }

    printf("DONE\n");


    //frequency tables for C function generator and LaTeX
    float fFrequency[NOTES];
    unsigned int iFrequency[NOTES];

    for(int i = 0; i < NOTES; i++) {
        fFrequency[i] = pitch(fFCMIN, i);
        iFrequency[i] = (int) (pow(2.0,16.0)*fFrequency[i]);
    }

    printf("Generating LaTeX table... ");

    fprintf(tableL, "\\begin{figure}[H]\n");
    fprintf(tableL, "  \\begin{center}\n");
    fprintf(tableL, "    \\small\n\n");
    fprintf(tableL, "    \\begin{tabular}{ c | c c c c }\n");
    fprintf(tableL, "%s%s%s", "Note & Frequency (Hz)"," & Freq x 2\\textsuperscript{16} (Hz)",
                        " & F\\textsubscript{C}/F\\textsubscript{CSAMPLEMIN} &  \\\\\ \n\\hline\n");

    int linecounter = 0;
    for(int i = 0; i < NOTES; i++) {
        fprintf(tableL, "%i & %10.3f & %i & %f & \\\\ \n",i,fFrequency[i],
                        iFrequency[i],fFrequency[i]/(pow(2.0,16.0)*FCsamplemin));


        linecounter++;
        if (linecounter > 44) {
            fprintf(tableL, "    \\end{tabular}\n\n");
            fprintf(tableL, "  \\end{center}\n");
            fprintf(tableL, "\\end{figure}\n");

            fprintf(tableL, "\\newpage\n");

            fprintf(tableL, "\\begin{figure}[H]\n");
            fprintf(tableL, "  \\begin{center}\n");
            fprintf(tableL, "    \\small\n\n");
            fprintf(tableL, "    \\begin{tabular}{ c | c c c c }\n");

            fprintf(tableL, "%s%s%s", "Note & Frequency (Hz)"," & Freq x 2\\textsuperscript{16} (Hz)",
                                " & F\\textsubscript{C}/F\\textsubscript{CSAMPLEMIN} &  \\\\\ \n\\hline\n");

            linecounter = 0;
        }
    }

    fprintf(tableL, "    \\end{tabular}\n\n");
    fprintf(tableL, "  \\end{center}\n");
    fprintf(tableL, "\\end{figure}\n");

    printf("DONE\n");



    printf("Generating C++ table... ");
    fprintf(tableC,"int frequencytable[] = {");
    fprintf(tableC,"%i",iFrequency[0]);

    for(int i = 1; i < NOTES; i++) {
        fprintf(tableC,",%i",iFrequency[i]);
        if (i % 10 == 9) fprintf(tableC,"\n            ");
    }

    fprintf(tableC,"};");
    printf("DONE\n");

    fclose(tableC);
    fclose(tableL);
    fclose(tableP);
    return 0;
}
