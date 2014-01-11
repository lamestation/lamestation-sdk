#include <stdio.h>
#include <iostream>
#include <math.h>
#include <string>
#include "allegro.h"

#ifdef _WIN32 || _WIN64
#include <winalleg.h>
#endif

using namespace std;

#define MAXIMAGESIZEX  (128)
#define MAXIMAGESIZEY  (64)
#define SCALEFACTOR (4)
#define TEXTBOX     (30)

#define PAGES       (8)
#define ADDRESSES   (128)

#define PIXELS      (8)

#define PROGRAM_TITLE   "IMG2DAT Monochrome Converter v0.1"

int main (int argc, char * argv[]) {
    allegro_init();
    install_keyboard();

    int screenx = MAXIMAGESIZEX*SCALEFACTOR*2;
    int screeny = MAXIMAGESIZEY*(SCALEFACTOR+1)+TEXTBOX;

    int imagesizex, imagesizey;
    int framesizex, framesizey;


    printf("IMG2DAT v0.3\n");

    char * name;
    if (argv[1] != NULL) {

        set_color_depth(32);
        set_gfx_mode(GFX_AUTODETECT_WINDOWED, screenx, screeny, 0, 0);
        set_window_title(PROGRAM_TITLE);
        BITMAP * buffer = create_bitmap(SCREEN_W, SCREEN_H);

        name = argv[1];

        string filename;
        filename += name;
        cout << filename.c_str();

        string inputfilename = filename;
        string outputfilename;

        BITMAP * inputimage = NULL;

        try {
            inputimage = load_bitmap(filename.c_str(), NULL);
        }
        catch(const string& error) {
            cout << error.c_str();
            exit(1);
        }


        BITMAP * outputimage = NULL;
        BITMAP * outputr = NULL;
        BITMAP * outputg = NULL;
        BITMAP * outputb = NULL;


        if (inputimage != NULL) {
            imagesizex = inputimage->w;
            imagesizey = inputimage->h;

            outputimage = create_bitmap(imagesizex, imagesizey);
            filename = name;

            FILE * outputfile = NULL;

            // bloobpie
            if (argv[2] != NULL) {

                if (!strcmp(argv[2],"-sprite")) {
                    printf("Converting sprite...\n");

                    filename += "_sprite.txt";
                    outputfile = fopen(filename.c_str(),"w");

                    if (argv[3] != NULL) framesizex = atoi(argv[3]); else framesizex = imagesizex;
                    if (argv[4] != NULL) framesizey = atoi(argv[4]); else framesizey = imagesizey;

                    fprintf(outputfile, "word\t$%X  'frameboost\n", (framesizex*2*framesizey/PIXELS) & 0xFFFF);
                    fprintf(outputfile, "word\t$%X, $%X   'width, height\n", (framesizex/PIXELS) & 0xFFFF, framesizey/PIXELS & 0xFFFF);


                } else if (!strcmp(argv[2],"-font")) {
                    printf("Converting bitmap font...\n");
                    fprintf(outputfile, "'meh\n");

                    filename += "_font.txt";
                    outputfile = fopen(filename.c_str(),"w");

                } else if (!strcmp(argv[2],"-tilemap")) {
                    printf("Converting tilemap...\n");

                    filename += "_tilemap.txt";
                    outputfile = fopen(filename.c_str(),"w");

                } else {
                    printf("Wait, what'd you want me to do?\n");
                    return 0;

                }
            }
            outputfilename = filename;

            int colorthing;
            int colorchar;
            int coloravg;
            int bytecount = 0;

            for (int page = 0; page < imagesizey/PIXELS; page++) {

                for (int address = 0; address < imagesizex; address++) {


                    colorchar = 0;

                    for (int pixel = 0; pixel < PIXELS; pixel++) {
                        int x = address;
                        int y = page*PIXELS + pixel;
                        colorthing = getpixel(inputimage, x, y);
                        coloravg = (getr(colorthing) +
                                getg(colorthing) + getb(colorthing))/3;

                        // if not black
                        if (coloravg > 0) {

                            if (coloravg < 255) {
                                colorchar += (1 << (pixel+8));
                                if (colorthing == makecol(255,0,255)) {

                                    putpixel(outputimage, x, y, makecol(255, 0, 255));
                                } else {

                                    putpixel(outputimage, x, y, makecol(139, 138, 116));
                                    colorchar += (1 << pixel);
                                }

                            } else {
                                putpixel(outputimage, x, y, makecol(255, 233, 166));
                                colorchar += (1 << pixel);
                            }
                        } else {
                            // if black
                            putpixel(outputimage, x, y, makecol(23,43,66));
                        }
                    }

                    if (bytecount % 16 == 0) fprintf(outputfile, "byte\t");
                    fprintf(outputfile, "$%X", colorchar & 0xFF);
                    fprintf(outputfile, ", ");
                    fprintf(outputfile, "$%X", colorchar >> 8);
                    if (bytecount % 16 != 15)
                        fprintf(outputfile, ", ");
                    else fprintf(outputfile, "\n");

                    bytecount++;

                }
            }
            fclose(outputfile);

            if (argv[5] != NULL && !strcmp(argv[5],"-noshow")) {
                printf("Don't show");
            } else {

                //BASIC ALLEGRO SETUP
                printf("Displaying image...\n");

                rectfill(buffer, 0,0, SCREEN_W-1, SCREEN_H-1, makecol(0,0,0));
                stretch_blit(inputimage, buffer, 0, 0, imagesizex, imagesizey,
                        0, 0, imagesizex*SCALEFACTOR, imagesizey*SCALEFACTOR);
                stretch_blit(outputimage, buffer, 0, 0, imagesizex, imagesizey,
                        MAXIMAGESIZEX*SCALEFACTOR, 0, imagesizex*SCALEFACTOR,
                        imagesizey*SCALEFACTOR);

                textprintf_centre_ex(buffer, font, MAXIMAGESIZEX*SCALEFACTOR/2,
                        MAXIMAGESIZEY*SCALEFACTOR+10, makecol(255, 100, 200),
                        -1, "Input File: %s", inputfilename.c_str());
                textprintf_centre_ex(buffer, font, MAXIMAGESIZEX*SCALEFACTOR*3/2,
                        MAXIMAGESIZEY*SCALEFACTOR+10, makecol(255, 100, 200),
                        -1, "Output File: %s", outputfilename.c_str());

                blit(buffer, screen, 0, 0, 0, 0, buffer->w, buffer->h);
                readkey();
            }
        } else {
            printf("That image does not exist.\n");
        }
        destroy_bitmap(buffer);
    } else {
        printf("\n%s\n",PROGRAM_TITLE);
        printf("\nSyntax: img2dat [name]\t-font");
        printf("\n\t\t\t-tilemap");
        printf("\n\t\t\t-sprite [frame_w] [frame_h]\n\n");
    }

    allegro_exit();
    return 0;
}
END_OF_MAIN()

