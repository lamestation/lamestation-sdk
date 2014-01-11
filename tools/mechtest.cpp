// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Project: Awesome Pong Game
// Creator: Brett Weir
// Date: 5/24/2010
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------

#include <stdio.h>
#include <math.h>
#include "allegro.h"

#ifdef _WIN32 || _WIN64
#include <winalleg.h>
#endif

// ---------------------------------------------------------------------------------------
// ---------------------------------------------------------------------------------------




// place defines here
#define BLACK       makecol(0,0,0)
#define GREEN       makecol(0,255,0)
#define WHITE       makecol(255,255,255)

#define SCREENX     128
#define SCREENY     64
#define SCALE       6
#define BULLETS     100

#define LEVELSIZEX  32
#define LEVELSIZEY  16

#define MAPSIZEX    10
#define MAPSIZEY    10
#define TILESIZE    8





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
    set_gfx_mode(GFX_AUTODETECT_WINDOWED, SCREENX*SCALE, SCREENY*SCALE, 0, 0);
    set_window_title("Ultra Tank Destruction Battle Game");
    BITMAP * buffer = create_bitmap(SCREEN_W, SCREEN_H);

    install_int_ex(ticker, BPS_TO_TIMER(30));


    int tankx = 0, tanky = 0;
    int speed = 1;
    int tanksizex = 16, tanksizey = 16;
    int tankframe = 0, tankdir = 0;
    int walking = 0, shooting = 0;

    int xoffset = 0, yoffset = 0;

    int bullet = 0, bulletspeed = 3;
    int bulleton[BULLETS], bulletx[BULLETS], bullety[BULLETS], bulletspeedx[BULLETS], bulletspeedy[BULLETS];
    int shot = 0;

    int level[LEVELSIZEX*LEVELSIZEY] =
        {   2,2,2,2,2,3,2,2,2,2,2,2,2,2,2,2,    2,2,2,2,2,3,2,2,2,2,2,2,2,2,2,2,
            2,2,2,2,2,3,2,2,2,2,2,2,5,2,2,2,    2,2,2,2,2,3,2,2,2,2,2,2,2,2,2,2,
            3,3,3,3,3,3,3,3,3,3,3,2,4,2,2,2,    2,2,2,2,2,3,2,2,2,2,2,2,2,2,2,2,
            2,2,2,2,2,5,2,2,2,2,3,2,2,2,2,2,    2,2,2,2,2,3,2,2,2,2,2,2,2,2,2,2,

            2,2,2,2,2,3,2,2,2,2,2,2,2,2,2,2,    2,2,2,2,2,3,2,2,2,2,2,2,2,2,2,2,
            2,2,2,2,2,3,2,2,2,2,2,2,5,2,2,2,    2,2,2,2,2,3,2,2,2,2,2,2,2,2,2,2,
            3,3,3,3,3,3,3,3,3,3,3,2,4,2,2,2,    2,2,2,2,2,3,2,2,2,2,2,2,2,2,2,2,
            2,2,2,2,2,5,2,2,2,2,3,2,2,2,2,2,    2,2,2,2,2,3,2,2,2,2,2,2,2,2,2,2,

            2,2,2,2,2,3,2,2,2,2,2,2,2,2,2,2,    2,2,2,2,2,3,2,2,2,2,2,2,2,2,2,2,
            2,2,2,2,2,3,2,2,2,2,2,2,5,2,2,2,    2,2,2,2,2,3,2,2,2,2,2,2,2,2,2,2,
            3,3,3,3,3,3,3,3,3,3,3,2,4,2,2,2,    2,2,2,2,2,3,2,2,2,2,2,2,2,2,2,2,
            2,2,2,2,2,5,2,2,2,2,3,2,2,2,2,2,    2,2,2,2,2,3,2,2,2,2,2,2,2,2,2,2,

            2,2,2,2,5,4,2,2,2,2,3,2,2,5,2,2,    2,2,2,2,2,3,2,2,2,2,2,2,2,2,2,2,
            5,2,2,2,4,2,2,2,2,2,3,2,2,4,2,2,    2,2,2,2,2,3,2,2,2,2,2,2,2,2,2,2,
            4,2,2,2,2,2,2,2,5,2,3,3,3,3,3,3,    2,2,2,2,2,3,2,2,2,2,2,2,2,2,2,2,
            2,2,2,2,2,2,2,2,4,2,3,2,2,2,2,2,    2,2,2,2,2,3,2,2,2,2,2,2,2,2,2,2,     };

    for (int i = 0; i < BULLETS; i++) {
        bulleton[i] = 0;
        bulletx[i] = 0;
        bullety[i] = 0;
        bulletspeedx[i] = 0;
        bulletspeedy[i] = 0;
    }


    BITMAP * tank = load_bitmap("mechtest/extremetankn.bmp", NULL);
    BITMAP * bulletimg = load_bitmap("mechtest/bullet.bmp", NULL);
    BITMAP * tilemap = load_bitmap("mechtest/tilemap.bmp", NULL);


    int running = 1;
    while (running) {

        rectfill(buffer, 0, 0, SCREEN_W-1, SCREEN_H-1, WHITE);

        poll_keyboard();
        if (key[KEY_ESC]) running = 0;

// ---------------------------------------------------------------------------------------
// ---------------------------------------------------------------------------------------
        walking = 0;
        if (key[KEY_LEFT])  {tankdir = 0;   tankx-=speed;   walking=1;}
        if (key[KEY_RIGHT]) {tankdir = 1;   tankx+=speed;   walking=1;}
        if (key[KEY_UP])    {tankdir = 2;   tanky-=speed;   walking=1;}
        if (key[KEY_DOWN])  {tankdir = 3;   tanky+=speed;   walking=1;}

        if (key[KEY_S]) {
            if (!shot) {
                shot = 1;
                shooting = 1;
                bulleton[bullet] = 1;

                bulletspeedx[bullet] = 0;
                bulletspeedy[bullet] = 0;


                if (tankdir == 0) {
                    bulletx[bullet] = tankx - bulletimg->w;
                    bullety[bullet] = tanky + tanksizey/2 - bulletimg->h/2;
                    bulletspeedx[bullet] -= bulletspeed;

                }
                if (tankdir == 1) {
                    bulletx[bullet] = tankx + tanksizex;
                    bullety[bullet] = tanky + tanksizey/2 - bulletimg->h/2;
                    bulletspeedx[bullet] += bulletspeed;
                }
                if (tankdir == 2) {
                    bulletx[bullet] = tankx + tanksizex/2 - bulletimg->w/2;
                    bullety[bullet] = tanky - bulletimg->w/2;
                    bulletspeedy[bullet] -= bulletspeed;
                }
                if (tankdir == 3) {
                    bulletx[bullet] = tankx + tanksizex/2 - bulletimg->w/2;
                    bullety[bullet] = tanky + tanksizey;
                    bulletspeedy[bullet] += bulletspeed;
                }

                bullet++;
                if (bullet >= BULLETS) bullet = 0;
            }
        } else {
            shot = 0;
            shooting = 0;
        }


        xoffset = tankx - SCREENX/2 + tanksizex/2;
        yoffset = tanky - SCREENY/2 + tanksizey/2;

        if (xoffset > LEVELSIZEX*TILESIZE - SCREENX - 1) xoffset = LEVELSIZEX*TILESIZE - SCREENX - 1;
        if (yoffset > LEVELSIZEY*TILESIZE - SCREENY - 1) yoffset = LEVELSIZEY*TILESIZE - SCREENY - 1;

        if (xoffset < 0) xoffset = 0;
        if (yoffset < 0) yoffset = 0;




        int tilenum = 0;
        int destx1 = (xoffset)/TILESIZE, destx2 = (xoffset + SCREENX)/TILESIZE + 1;
        int desty1 = (yoffset)/TILESIZE, desty2 = (yoffset + SCREENY)/TILESIZE + 1;

        if (destx1 < 0) destx1 = 0;
        if (desty1 < 0) desty1 = 0;
        if (destx2 > LEVELSIZEX) destx2 = LEVELSIZEX;
        if (desty2 > LEVELSIZEY) desty2 = LEVELSIZEY;


        for (int y = desty1; y < desty2; y++) {
            for (int x = destx1; x < destx2; x++) {

                tilenum = level[y*LEVELSIZEX + x];
                stretch_blit(tilemap, buffer, (tilenum%MAPSIZEX)*TILESIZE, (tilenum/MAPSIZEX)*TILESIZE, TILESIZE, TILESIZE, (x*TILESIZE-xoffset)*SCALE, (y*TILESIZE-yoffset)*SCALE, TILESIZE*SCALE, TILESIZE*SCALE);


            }
        }



        if (walking) {
            if (tankframe == 1) {
                tankframe = 0;
            } else {
                tankframe = 1;
            }
        }
        masked_stretch_blit(tank, buffer, tankframe*tanksizex, tankdir*tanksizey, tanksizex, tanksizey, (tankx-xoffset)*SCALE, (tanky-yoffset)*SCALE, tanksizex*SCALE, tanksizey*SCALE);


        for (int i = 0; i < BULLETS; i++) {
            if (bulleton[i]) {
                bulletx[i] += bulletspeedx[i];
                bullety[i] += bulletspeedy[i];

                masked_stretch_blit(bulletimg, buffer, 0, 0, bulletimg->w, bulletimg->h, (bulletx[i]-xoffset)*SCALE, (bullety[i]-yoffset)*SCALE, bulletimg->w*SCALE, bulletimg->h*SCALE);
            }
        }




        //vsync();
        blit(buffer, screen, 0, 0, 0, 0, buffer->w, buffer->h);

        while (ticks<1) {
            yield_timeslice();
            rest(10);
        }
        ticks=0;
    }

// ---------------------------------------------------------------------------------------
// ---------------------------------------------------------------------------------------
    destroy_bitmap(tank);
    destroy_bitmap(bulletimg);
    destroy_bitmap(tilemap);

    destroy_bitmap(buffer);
    allegro_exit();
    return 0;
}
END_OF_MAIN()
