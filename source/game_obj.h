#ifndef GAME_OBJ_H
#define GAME_OBJ_H

#include <tonc.h>
#include <gbfs.h>

struct game_obj
{
        u16 x;
        u16 y;
        u16 width;
        u16 height;

        u16 hor_velocity;
        u16 vert_velocity;
        u16 screen_x;
        u16 screen_y;
        u8 tile_id;

        char priority;

        OBJ_ATTR *oam_slot;
        struct game_obj *next;
};

void load_game_obj_data(const GBFS_FILE *data, struct game_obj obj);

#endif