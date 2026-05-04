#ifndef ROOM_H
#define ROOM_H

#include <tonc.h>
#include <gbfs.h>

struct room
{
        u32 width;
        u32 height;
        const char *filename;
};

void load_room_data(const GBFS_FILE *data, struct room room);

#endif