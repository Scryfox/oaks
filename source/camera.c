// TODO: Add camera creation function
#include "camera.h"

struct camera create_camera(struct game_obj *obj_to_follow, struct room *active_room)
{
        struct camera cam = {0, 0, 240, 160, 40, 20, obj_to_follow, active_room};

        // TODO: Move obj_to_follow to middle of camera unless near a boundary of the room

        return cam;
}

void update_camera(struct camera *cam)
{

        struct game_obj *obj = cam->obj_to_follow;

        // TODO: Implement this for the vertical axis as well
        if (obj->x <= cam->side_scroll_margin)
        {
                cam->x = 0;
        }
        else if (obj->x + obj->width >= cam->active_room->width - cam->side_scroll_margin)
        {
                cam->x = cam->active_room->width - cam->width;
        }
        else if (obj->x + obj->width > cam->x + cam->width - cam->side_scroll_margin)
        {
                cam->x += (obj->x + obj->width) - cam->x - (cam->width - cam->side_scroll_margin);
        }
        else if (obj->x < cam->x + cam->side_scroll_margin)
        {
                cam->x -= cam->side_scroll_margin - (obj->x - cam->x);
        }

        if (obj->y <= cam->vertical_scroll_margin)
        {
                cam->y = 0;
        }
        else if (obj->y + obj->height >= cam->active_room->height - cam->vertical_scroll_margin)
        {
                cam->y = cam->active_room->height - cam->height;
        }
        else if (obj->y + obj->height > cam->y + cam->height - cam->vertical_scroll_margin)
        {
                cam->y += (obj->y + obj->height) - cam->y - (cam->height - cam->vertical_scroll_margin);
        }
        else if (obj->y < cam->y + cam->vertical_scroll_margin)
        {
                cam->y -= cam->vertical_scroll_margin - (obj->y - cam->y);
        }

        obj->screen_x = obj->x - cam->x;
        obj->screen_y = obj->y - cam->y;

        REG_BG0HOFS = cam->x;
        REG_BG0VOFS = cam->y;

        obj_set_pos(obj->oam_slot, obj->screen_x, obj->screen_y);
};