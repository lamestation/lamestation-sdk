#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string>
#include "allegro.h"

#ifdef _WIN32 || _WIN64
#include <winalleg.h>
#endif

#define TOTALBYTES  4096
#define OPENINGCHUNKEND    (44)
#define TOTALDATAS  (2048)
#define TARGETSAMPLES  (512)

using namespace std;

#define BLACK       makecol(0,0,0)
#define DARKGRAY    makecol(60,60,60)
#define GRAY        makecol(120,120,120)
#define WHITE       makecol(255,255,255)

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
	install_mouse();
	install_timer();

	int imagesizex, imagesizey;

	set_color_depth(32);
	set_gfx_mode(GFX_AUTODETECT_WINDOWED, 512, 256, 0, 0);
	set_window_title("wav2dat 8-bit Sample Converter v0.1");
	BITMAP * buffer = create_bitmap(SCREEN_W, SCREEN_H);

	install_int_ex(ticker, BPS_TO_TIMER(35));

	printf("wav2dat v0.1\n");

	unsigned int c;
	unsigned int w;
	signed int w2;

	unsigned int filesize; // filesize = 8 + chunksize = 44 + bytesofaudio
	unsigned int datasize;
	unsigned int bitdepth;

	unsigned int sourcesamples;
	unsigned int sampleinc;

	unsigned int samples[TARGETSAMPLES];

	int samplecount = 0;

	string name;
	if (argc > 1) {
		name = argv[1];


		string filename = name;
		filename += ".wav";
		FILE * pFile = fopen(filename.c_str(),"rb");

		filename = name;
		filename += ".spin";
		FILE * pWrite = fopen(filename.c_str(),"w");

		if (pFile != NULL) {
			printf("IT OPENED!\n\n");

		}

		//get file size
		fseek(pFile, 0, SEEK_END);
		filesize = ftell(pFile);
		printf("%12s\t%u bytes\n","file size:", filesize);
		printf("%12s\t%u bytes\n","data size:", datasize = filesize - 44);

		//get bit depth
		fseek(pFile, 34, SEEK_SET);
		bitdepth = getc(pFile);
		printf("%12s\t%u bytes\n", "bit depth:", bitdepth);
		printf("%12s\t%u samples\n", "src size:", sourcesamples = datasize/(bitdepth/8));
		printf("%12s\t%u samples\n", "dst size:", TARGETSAMPLES);

		sampleinc = (sourcesamples << 8)/TARGETSAMPLES;
		printf("%12s\t%u.%u samples\n", "sample inc:", sampleinc>>8,
				(sampleinc & 0xFF)*100/256);


		fseek(pFile, OPENINGCHUNKEND, SEEK_SET);

		unsigned int itrunc;
		for (unsigned int i = 0; ((i >> 8) < sourcesamples) &&
				(samplecount < TARGETSAMPLES); i += (sourcesamples << 8)/TARGETSAMPLES) {
			//8 bit
			itrunc = i >> 8;

			if (samplecount % 16 == 0) fprintf(pWrite,"\nbyte\t");

			fseek(pFile, OPENINGCHUNKEND+itrunc*2 + 1, SEEK_SET);

			c = getc(pFile);
			w = c;
			w2 = (signed char) w + 128;

			printf("%i ",w2);
			fprintf(pWrite, "%i",w2);
			samples[samplecount] = w2;
			if (samplecount % 16 != 15) fprintf(pWrite,", ");

			samplecount++;

		}

		printf("\n%s\t%i samples\n", "samples taken:", samplecount);

		fclose (pFile);
		fclose (pWrite);


		printf("Displaying image...\n");

		show_mouse(screen);

		int running = 1;
		while (running) {
			rectfill(buffer, 0,0, SCREEN_W-1, SCREEN_H-1, BLACK);
			poll_keyboard();
			poll_mouse();
			if (key[KEY_ESC]) running = 0;


			hline(buffer, 0, 127, TARGETSAMPLES-1, DARKGRAY);
			hline(buffer, 0, 128, TARGETSAMPLES-1, DARKGRAY);


			vline(buffer, TARGETSAMPLES/2-1, 0, 255, DARKGRAY);
			for (int x = 0; x < TARGETSAMPLES; x += 32)
				vline(buffer, x, 0, 255, DARKGRAY);

			//cursor
			vline(buffer, mouse_x, 0, 255, GRAY);
			hline(buffer, 0, SCREEN_H - 1 - samples[mouse_x], TARGETSAMPLES-1, GRAY);


			for (int x = 0; x < TARGETSAMPLES; x++)
				putpixel(buffer, x, SCREEN_H - 1 - samples[x], WHITE);



			textprintf_right_ex(buffer, font, TARGETSAMPLES-10, 256-10, WHITE,
					-1, "Cursor:%3i,%3i", mouse_x, samples[mouse_x]);

			blit(buffer, screen, 0, 0, 0, 0, buffer->w, buffer->h);
			while (ticks<1) {
				yield_timeslice();
				rest(10);
			}
			ticks=0;
		}

	} else {
		printf ("No file given!\n");
	}


	remove_mouse();
	destroy_bitmap(buffer);

	allegro_exit();
	return 0;

}
END_OF_MAIN()
