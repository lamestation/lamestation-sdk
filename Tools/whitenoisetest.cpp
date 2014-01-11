#include <stdio.h>
#include <math.h>
#include "allegro.h"

#ifdef _WIN32 || _WIN64
#include <winalleg.h>
#endif

using namespace std;

// place defines here
#define BLACK       makecol(0,0,0)
#define BLUE        makecol(0,0,120)
#define WHITE       makecol(255,255,255)

volatile int ticks;
void ticker(void)
{
   ++ticks;
} END_OF_FUNCTION(ticker);

LOCK_FUNCTION(ticker);
LOCK_VARIABLE(ticks);

int main (void) {
    allegro_init();
    install_keyboard();
    install_timer();

    set_color_depth(32);
    set_gfx_mode(GFX_AUTODETECT_WINDOWED, 256, 600,0,0);
    set_window_title("White Noise Generator Test");
    BITMAP * buffer = create_bitmap(SCREEN_W, SCREEN_H);

    install_int_ex(ticker, BPS_TO_TIMER(35));


    unsigned int tallytemp;
    unsigned int tally[256] = {0};
    signed int tallyplot[256] = {0};
    unsigned int screenbottom = 0;
    signed int tallymovingavg = 0, tallymovingavgold = 0;
    int tallyavgnum = 16;

    unsigned int rand = 203943, rand2 = 0, rand3 = 0;
    unsigned int outputtemp = 0;

    unsigned int units = 0;
    unsigned int unitsmax = 50000000;
    unsigned int unitsperframe = 500000;
    unsigned int clearcounter = 0;







    int running = 1;
    while (running) {

        rectfill(buffer, 0, 0, SCREEN_W-1, SCREEN_H-1, BLACK);

        poll_keyboard();
        if (key[KEY_ESC]) running = 0;

        if (units < unitsmax) {
            for (int i = 0; i < unitsperframe; i++) {
                units++;

                rand = (unsigned) (((signed) rand) >> 1);
                rand2 = (rand & 0xFF);
                rand3 = (rand2 << 2);
                rand3 = (rand3^rand2) << 24;
                rand += rand3;

                outputtemp = (rand & 0xFF);
                tally[outputtemp]++;

            }
        }

        //FIND BOTTOM OF PLOT
        clearcounter = tally[0];
        for (int x = 1; x < 256; x++)
            if (clearcounter > tally[x]) clearcounter = tally[x];


        //PLOT PLOT
        screenbottom = SCREEN_H-1+clearcounter;
        tallymovingavgold = tallyplot[0];
        for (int x = 0; x < 256; x++) {
            tallytemp = tally[x];
            tallyplot[x] = (signed) SCREEN_H - 1 + (((signed) clearcounter - (signed) tallytemp)/64);

            vline(buffer, x, screenbottom, tallyplot[x], BLUE);

                tallymovingavg = 0;
                for (int i = x; i < x + tallyavgnum; i++) {
                    tallymovingavg += tallyplot[i%256];
                }
                tallymovingavg /= tallyavgnum;


                fastline(buffer, x-1, tallymovingavgold, x, tallymovingavg, makecol(255,0,0));
                putpixel(buffer, x, tallymovingavgold, WHITE);

                tallymovingavgold = tallymovingavg;

        }

        textprintf_ex(buffer, font, 10, 10, WHITE, -1, "Passes: %i", units);


        //vsync();
        blit(buffer, screen, 0, 0, 0, 0, buffer->w, buffer->h);

        while (ticks<1) {
            yield_timeslice();
            rest(10);
        }
        ticks=0;
    }


    destroy_bitmap(buffer);
    allegro_exit();
    return 0;
}
//END_OF_MAIN()
