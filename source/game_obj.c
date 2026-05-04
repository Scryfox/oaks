#include "game_obj.h"

// TODO: Make a game_obj creation function

// TODO: Make this function actually read the game object for info on what to load
void load_game_obj_data(const GBFS_FILE *data, struct game_obj obj)
{
        u32 tid = 1,
            pb = 0;
        const char *sp_pal_string = "test.pal.bin";
        const char *sp_img_string = "test.img.bin";

        gbfs_copy_obj(&pal_obj_mem[pb], data, sp_pal_string);
        gbfs_copy_obj(&tile_mem[4][tid], data, sp_img_string);

        obj_set_attr(obj.oam_slot,
                     ATTR0_SQUARE,
                     ATTR1_SIZE_64,
                     ATTR2_PALBANK(pb) | tid);
}