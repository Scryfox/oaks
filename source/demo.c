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

#include "camera.h"
#include "room.h"

void enable_interrupts()
{
        // Init interrupts and VBlank irq.
        irq_init(NULL);
        irq_add(II_VBLANK, NULL);
}

const GBFS_FILE *get_gbfs_file()
{
#ifdef DEV
        // #pragma message("Compiling for DEV")
        // For DEV build
        return find_first_gbfs_file(find_first_gbfs_file);
#else
        // #pragma message("Compiling for DEBUG")
        // For PROD build
        extern const int demo_gbfs_size asm("demo_gbfs_size");
        extern u8 demo_gbfs[3584] asm("demo_gbfs");
        return (GBFS_FILE *)demo_gbfs;
#endif
}

int main()
{

        enable_interrupts();

        REG_DISPCNT = DCNT_MODE0 | DCNT_BG0 | DCNT_OBJ | DCNT_OBJ_1D;

        const GBFS_FILE *data = get_gbfs_file();

        struct room main_room = {64 * 8, 32 * 8, "test_bg"};
        load_room_data(data, main_room);

        OBJ_ATTR obj_buffer[128];

        struct game_obj player = {200, 0, 64, 64,
                                  0, 0, 0, 0, 1,
                                  255, &obj_buffer[0], NULL};
        load_game_obj_data(data, player);

        struct camera main_camera = create_camera(&player, &main_room);

        // obj_set_pos(player.oam_slot, player.x, player.y);

        while (1)
        {
                VBlankIntrWait();
                key_poll();

                player.x += key_tri_horz();
                player.y += key_tri_vert();

                if ((s16)player.x < 0)
                        player.x = 0;
                if (player.x > main_room.width - player.width)
                        player.x = main_room.width - player.width;
                if ((s16)player.y < 0)
                        player.y = 0;
                if (player.y > main_room.height - player.height)
                        player.y = main_room.height - player.height;

                update_camera(&main_camera);

                oam_copy(oam_mem, obj_buffer, 1);
        }

        return 0;
}
