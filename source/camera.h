#ifndef CAMERA_H
#define CAMERA_H

#include <tonc.h>

#include "game_obj.h"
#include "room.h"

struct camera
{
        // x & y coords are for the whole room
        u16 x;
        u16 y;
        u16 width;
        u16 height;

        u16 side_scroll_margin;
        u16 vertical_scroll_margin;

        struct game_obj *obj_to_follow;
        struct room *active_room;
};

struct camera create_camera(struct game_obj *obj_to_follow, struct room *active_room);

void update_camera(struct camera *active_camera);

#endif