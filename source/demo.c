//
// demo_demo.c
// Essential tilemap loading: the start of brinstar from metroid 1
//
// (20060221 - 20070216, cearn)

#include <string.h>
#include <stdlib.h>

#include <tonc.h>
#include <gbfs.h>
// #include "../build/demo.h"

int main()
{
	// Init interrupts and VBlank irq.
	irq_init(NULL);
	irq_add(II_VBLANK, NULL);

#ifdef DEV
#pragma message("Compiling for DEV")
	// For DEV build
	const GBFS_FILE *data = find_first_gbfs_file(find_first_gbfs_file);
#else
#pragma message("Compiling for DEBUG")
	// For PROD build
	extern const int demo_gbfs_size asm("demo_gbfs_size");
	extern u8 demo_gbfs[3584] asm("demo_gbfs");
	const GBFS_FILE *data = (GBFS_FILE *)demo_gbfs;
#endif

	// Load palette
	gbfs_copy_obj(pal_bg_mem, data, "demo.pal.bin");
	// Load tiles into CBB 0
	gbfs_copy_obj(&tile_mem[0][0], data, "demo.img.bin");
	// Load map into SBB 30
	gbfs_copy_obj(&se_mem[30][0], data, "demo.map.bin");

	// set up BG0 for a 4bpp 64x32t map, using
	//   using charblock 0 and screenblock 31
	REG_BG0CNT = BG_CBB(0) | BG_SBB(30) | BG_4BPP | BG_REG_32x32;
	REG_DISPCNT = DCNT_MODE0 | DCNT_BG0;

	// Scroll around some
	int x = 192, y = 64;
	while (1)
	{
		VBlankIntrWait();
		key_poll();

		x += key_tri_horz();
		y += key_tri_vert();

		REG_BG0HOFS = x;
		REG_BG0VOFS = y;
	}

	return 0;
}
