#include "room.h"

void load_room_data(const GBFS_FILE *data, struct room room)
{

        // set up BG0 for a 4bpp 64x32t map, using
        //   using charblock 0 and screenblock 31
        REG_BG0CNT = BG_CBB(0) | BG_SBB(30) | BG_4BPP | BG_REG_64x32;

        // TODO: Make the format strings variablized
        char bg_pal_string[24];
        sprintf(bg_pal_string, "%s.pal.bin", room.filename);

        char bg_tile_string[24];
        sprintf(bg_tile_string, "%s.img.bin", room.filename);

        char bg_map_string[24];
        sprintf(bg_map_string, "%s.map.bin", room.filename);

        // TODO: Make this be able to load to any place
        //  Load palette
        gbfs_copy_obj(pal_bg_mem, data, bg_pal_string);
        // Load tiles into CBB 0
        gbfs_copy_obj(&tile_mem[0][0], data, bg_tile_string);
        // Load map into SBB 30
        gbfs_copy_obj(&se_mem[30][0], data, bg_map_string);
}