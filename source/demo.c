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

	// Init interrupts and VBlank irq.
	irq_init(NULL);
	irq_add(II_VBLANK, NULL);

	const char *bg_pal_string = "col_test.pal.bin";
	const char *bg_tile_string = "col_test.img.bin";
	const char *bg_map_string = "col_test.map.bin";

	// Load palette
	gbfs_copy_obj(pal_bg_mem, data, bg_pal_string);
	// Load tiles into CBB 0
	gbfs_copy_obj(&tile_mem[0][0], data, bg_tile_string);
	// Load map into SBB 30
	gbfs_copy_obj(&se_mem[30][0], data, bg_map_string);

	u32 tid = 1, pb = 0;
	const char *sp_pal_string = "test.pal.bin";
	const char *sp_img_string = "test.img.bin";

	gbfs_copy_obj(&pal_obj_mem[pb], data, sp_pal_string);
	gbfs_copy_obj(&tile_mem[4][tid], data, sp_img_string);

	// set up BG0 for a 4bpp 64x32t map, using
	//   using charblock 0 and screenblock 31
	REG_BG0CNT = BG_CBB(0) | BG_SBB(30) | BG_4BPP | BG_REG_64x32;
	REG_DISPCNT = DCNT_MODE0 | DCNT_BG0 | DCNT_OBJ | DCNT_OBJ_1D;

	OBJ_ATTR obj_buffer[128];

	OBJ_ATTR *metr = &obj_buffer[0];

	obj_set_attr(metr,
				 ATTR0_SQUARE,
				 ATTR1_SIZE_64,
				 ATTR2_PALBANK(pb) | tid);

	int x = 96, y = 32;

	obj_set_pos(metr, x, y);

	while (1)
	{
		VBlankIntrWait();
		key_poll();

		x += key_tri_horz();
		y += key_tri_vert();

		obj_set_pos(metr, x, y);
		oam_copy(oam_mem, obj_buffer, 1);
	}

	return 0;
}
