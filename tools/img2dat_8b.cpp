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

#define MAXIMAGESIZEX  (160)
#define MAXIMAGESIZEY  (120)
#define SCALEFACTOR (4)
#define TEXTBOX     (30)


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
    set_window_title("IMG2DAT 8-bit Converter v0.1");
    BITMAP * buffer = create_bitmap(SCREEN_W, SCREEN_H);

    install_int_ex(ticker, BPS_TO_TIMER(35));

    printf("IMG2DAT v0.1\t CBW\n");




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
            outputr = create_bitmap(imagesizex, imagesizey);
            outputg = create_bitmap(imagesizex, imagesizey);
            outputb = create_bitmap(imagesizex, imagesizey);


            filename = name;
            filename += "_dat.txt";
            outputfilename = filename;
            FILE * outputfile = fopen(filename.c_str(),"w");


            printf("Converting image...\n");



            int colorthing, r, g, b;
            int colorchar;

            fprintf(outputfile,"displayBuffer\n");
            fprintf(outputfile,"long\n");

            for (int y = 0; y < imagesizey; y++) {

                if (y % 8 == 0 ) fprintf(outputfile, "\n'line %i\n", y);

                for (int x = 0; x < imagesizex; x++) {

                    if (x % 32 == 0) {
                        fprintf(outputfile, "byte\t");
                    }
                    if (x % 16 == 0) {
                        fprintf(outputfile, "\t");
                    }

                    colorthing = getpixel(inputimage, x, y);

                    //8 bit
                    /*
                    r = getr(colorthing) >> 5;
                    g = getg(colorthing) >> 5;
                    b = getb(colorthing) >> 6;
                    colorchar = (r << 5) + (g << 3) + b;
        */
                    //6 bit
                    r = getr(colorthing) >> 6;
                    g = getg(colorthing) >> 6;
                    b = getb(colorthing) >> 6;


                        colorchar = (r << 6) + (g << 4) + (b << 2);


                    fprintf(outputfile, "$%X",colorchar);
                    r = r << 6;
                    g = g << 6;
                    b = b << 6;

                    putpixel(outputimage, x, y, makecol(r, g, b));
                    putpixel(outputr, x, y, makecol(r, 0, 0));
                    putpixel(outputg, x, y, makecol(0, g, 0));
                    putpixel(outputb, x, y, makecol(0, 0, b));



                    if (x % 8 == 7) {
                        fprintf(outputfile, "\n");
                    }  else  {
                        fprintf(outputfile, ", ");
                    }

                }
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
            //    blit(inputimage, buffer, 0, 0, 0, 0, imagesizex, imagesizey);
            //    blit(outputimage, buffer, 0, 0, MAXIMAGESIZEX, 0, imagesizex, imagesizey);
                stretch_blit(inputimage, buffer, 0, 0, imagesizex, imagesizey, 0, 0, imagesizex*SCALEFACTOR, imagesizey*SCALEFACTOR);
                stretch_blit(outputimage, buffer, 0, 0, imagesizex, imagesizey, MAXIMAGESIZEX*SCALEFACTOR, 0, imagesizex*SCALEFACTOR, imagesizey*SCALEFACTOR);

                blit(outputr, buffer, 0, 0, 0, MAXIMAGESIZEY*SCALEFACTOR+TEXTBOX, imagesizex, imagesizey);
                blit(outputg, buffer, 0, 0, MAXIMAGESIZEX, MAXIMAGESIZEY*SCALEFACTOR+TEXTBOX, imagesizex, imagesizey);
                blit(outputb, buffer, 0, 0, MAXIMAGESIZEX*2, MAXIMAGESIZEY*SCALEFACTOR+TEXTBOX, imagesizex, imagesizey);


                textprintf_ex(buffer, font, 10, MAXIMAGESIZEY+10, makecol(255, 100, 200), -1, "R: %d", r = getr(colorthing) >> 5);
                textprintf_ex(buffer, font, 10, MAXIMAGESIZEY+20, makecol(255, 100, 200), -1, "G: %d", g = getg(colorthing) >> 5);
                textprintf_ex(buffer, font, 10, MAXIMAGESIZEY+30, makecol(255, 100, 200), -1, "B: %d", b = getb(colorthing) >> 6);

                colorchar = (r << 5) + (g << 3) + b;
             //   textprintf_ex(buffer, font, 10, MAXIMAGESIZEY+40, makecol(255, 100, 200), -1, "COL: %X", colorthing);

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

