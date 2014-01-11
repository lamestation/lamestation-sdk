// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Project: Awesome Pong Game
// Creator: Brett Weir
// Date: 5/24/2010
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------

#include <stdio.h>
#include <math.h>
#include <string>
#include "allegro.h"
#ifdef _WIN32 || _WIN64
#include <winalleg.h>
#endif

using namespace std;

// ---------------------------------------------------------------------------------------
// ---------------------------------------------------------------------------------------

// place defines here

#define MAXIMAGESIZEX  (128)
#define MAXIMAGESIZEY  (64)
#define MAXCHARWIDTH    (6)
#define SCALEFACTOR (4)
#define TEXTBOX     (30)

#define PAGES       (8)
#define ADDRESSES   (128)

#define PIXELS      (8)



// ---------------------------------------------------------------------------------------
// ---------------------------------------------------------------------------------------

volatile int ticks;
void ticker(void)
{
   ++ticks;
} END_OF_FUNCTION(ticker);

LOCK_FUNCTION(ticker);
LOCK_VARIABLE(ticks);

int main (int argc, char * argv[]) {
    allegro_init();
    install_keyboard();
    install_timer();

    int screenx = MAXIMAGESIZEX*SCALEFACTOR*2;
    int screeny = MAXIMAGESIZEY*(SCALEFACTOR+1)+TEXTBOX;

    int imagesizex, imagesizey;

    set_color_depth(32);
    set_gfx_mode(GFX_AUTODETECT_WINDOWED, screenx, screeny, 0, 0);
    set_window_title("IMG2DAT Text Converter v0.1");
    BITMAP * buffer = create_bitmap(SCREEN_W, SCREEN_H);

    install_int_ex(ticker, BPS_TO_TIMER(35));

    printf("IMG2DAT Text v0.1\t CBW\n");




    char * name;
    if (argv[1] != NULL) {

        name = argv[1];

        string filename;
        filename += name;
        filename += ".bmp";
        string inputfilename = filename;
        string outputfilename;
        BITMAP * inputimage = load_bitmap(filename.c_str(), NULL);
        BITMAP * outputimage = NULL;
        BITMAP * outputr = NULL;
        BITMAP * outputg = NULL;
        BITMAP * outputb = NULL;


        if (inputimage != NULL) {
            imagesizex = inputimage->w;
            imagesizey = inputimage->h;

            outputimage = create_bitmap(imagesizex, imagesizey);

            filename = name;
            filename += "_dat.txt";
            outputfilename = filename;
            FILE * outputfile = fopen(filename.c_str(),"w");


            printf("Converting image...\n");



            int colorthing;
            int colorchar = 0;
            int charwidth = 0;
            int bytecount = 0;

            for (int page = 0; page < imagesizey/PIXELS; page++) {

                    for (int address = 0; address < imagesizex; address++) {

                        if (colorchar == 0) fprintf(outputfile, "byte\t");
                        colorchar = 0;

                        for (int pixel = 0; pixel < PIXELS; pixel++) {
                            int x = address;
                            int y = page*PIXELS + pixel;
                            colorthing = getpixel(inputimage, x, y);

                            if (colorthing > 0) {
                                colorchar += (1 << pixel);
                                putpixel(outputimage, x, y, makecol(255, 233, 166));

                            } else {
                                putpixel(outputimage, x, y, makecol(23,43,66));
                            }
                        }

                        fprintf(outputfile, "$%X", colorchar);
                        charwidth++;
                        if (colorchar == 0) {
                            while (charwidth < MAXCHARWIDTH) {
                                fprintf(outputfile, ", $%X", 0x0);
                                charwidth++;
                            }
                            charwidth = 0;
                            fprintf(outputfile, "\n");

                        } else fprintf(outputfile, ", ");


                    }
        //        }
            }


            fclose(outputfile);












    //BASIC ALLEGRO SETUP
            printf("Displaying image...\n");

            int running = 1;
            while (running) {
                rectfill(buffer, 0,0, SCREEN_W-1, SCREEN_H-1, makecol(0,0,0));
                poll_keyboard();
                if (key[KEY_ESC]) running = 0;

            //regular output
                stretch_blit(inputimage, buffer, 0, 0, imagesizex, imagesizey, 0, 0, imagesizex*SCALEFACTOR, imagesizey*SCALEFACTOR);
                stretch_blit(outputimage, buffer, 0, 0, imagesizex, imagesizey, MAXIMAGESIZEX*SCALEFACTOR, 0, imagesizex*SCALEFACTOR, imagesizey*SCALEFACTOR);

                textprintf_centre_ex(buffer, font, MAXIMAGESIZEX*SCALEFACTOR/2, MAXIMAGESIZEY*SCALEFACTOR+10, makecol(255, 100, 200), -1, "Input File: %s", inputfilename.c_str());
                textprintf_centre_ex(buffer, font, MAXIMAGESIZEX*SCALEFACTOR*3/2, MAXIMAGESIZEY*SCALEFACTOR+10, makecol(255, 100, 200), -1, "Output File: %s", outputfilename.c_str());


                blit(buffer, screen, 0, 0, 0, 0, buffer->w, buffer->h);
                while (ticks<1) {
                    yield_timeslice();
                    rest(10);
                }
                ticks=0;
            }





        } else {
            printf("That image does not exist.\n");
        }

    } else {
        printf("Give me something to convert, please.\n");

    }

    destroy_bitmap(buffer);

    allegro_exit();
    return 0;
}
END_OF_MAIN()

