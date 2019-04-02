// Author: Cameron Cannara
// Grid_Based_Example || main.c
// UNPOLISHED. The code is somewhat inefficient

#include <gb/gb.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#include "baseMapMeta.c"
#include "tileMeta.c"
#include "player.c"

// Arrays for x and y axis
INT8 xG[] = {24, 40, 56, 72, 88, 104, 120};
INT8 yG[] = {32, 48, 64, 80, 96, 112};

//   Method for delaying the game efficently. Override for delay()
//   Precondition: numLoops is type INT8.
void preformantDelay(INT8 numLoops)
{
    UINT8 i;
    for (i = 0; i < numLoops; i++)
    {
        wait_vbl_done();
    }
}

//  Moves the player's metapixels x units horizontally and y units vertically
//  Precondition: numLoops, x and y are all type INT8.
void preformMovePlayer(INT8 numLoops, INT8 x, INT8 y)
{
    UINT8 i;
    for (i = 0; i < numLoops; i++)
    {
        scroll_sprite(0, x, y);
        scroll_sprite(1, x, y);
        scroll_sprite(2, x, y);
        scroll_sprite(3, x, y);
        wait_vbl_done();
    }
}

//  Changes the player's metapixels based on playerFrame
//  Precondition: playerFrame is type INT8
INT8 playerAnimateIdle(INT8 playerFrame)
{
    if (playerFrame == 1)
    {
        set_sprite_tile(0, 5);
        set_sprite_tile(1, 4);
        set_sprite_tile(2, 6);
        set_sprite_tile(3, 7);
        return 2;
    }
    if (playerFrame == 2)
    {
        set_sprite_tile(0, 1);
        set_sprite_tile(1, 0);
        set_sprite_tile(2, 2);
        set_sprite_tile(3, 3);
        return 1;
    }
}

//  Instantiates the game by setting up background and player based on metapixels
//  Precondition: playerSpritePos is type INT8 and is length of 2.
void instantiateGame(INT8 playerSpritePos [])
{
    if (length(playerSpritePos) != 2)
        return;

    set_bkg_data(0, 14, tileMeta);
    set_bkg_tiles(0, 0, 20, 18, baseMapMeta);
    SHOW_BKG;
    DISPLAY_ON;
    
    set_sprite_data(0, 8, player);

    move_sprite(0, playerSpritePos[0], playerSpritePos[1]+8);
    move_sprite(1, playerSpritePos[0], playerSpritePos[1]);
    move_sprite(2, playerSpritePos[0] + 8, playerSpritePos[1]);
    move_sprite(3, playerSpritePos[0] + 8, playerSpritePos[1] + 8);
    
    SHOW_SPRITES;
}

// Instantiates faux enemy at xG[3] and yG[3], (3, 3) on grid, (72, 80) pixel based
void instantiateEnemy()
{
    INT8 randSpritePos[] = {xG[3], yG[3]};

    move_sprite(4, randSpritePos[0], randSpritePos[1]+8);
    move_sprite(5, randSpritePos[0], randSpritePos[1]);
    move_sprite(6, randSpritePos[0] + 8, randSpritePos[1]);
    move_sprite(7, randSpritePos[0] + 8, randSpritePos[1] + 8);

    set_sprite_tile(5, 0);
    set_sprite_tile(4, 1);
    set_sprite_tile(6, 2);
    set_sprite_tile(7, 3);
}

void main()
{ 
    // 7 x 6 Grid
    INT8 playerSpritePos [] = {xG[0], yG[5]};   // Position of Player
    INT8 playerFrame = playerAnimateIdle(2);    // Frame of Player
    INT8 STATE_PLAY = 0;                        // State of Game


    printf("\nPress Start");
    waitpad(J_START);

    instantiateGame(playerSpritePos, playerFrame);
    instantiateEnemy();

    // Game loop
    while(1)
    {
        playerFrame = playerAnimateIdle(playerFrame);
        
        //if (STATE_PLAY == 0)
        //{
            switch (joypad())
            {
                case J_LEFT:
                    if (playerSpritePos[0] > xG[0])
                    {
                        preformMovePlayer(8, -2, 0);
                        playerSpritePos[0] -= 16;
                        STATE_PLAY = 1;
                    }
                    break;
                case J_RIGHT:
                    if (playerSpritePos[0] < xG[6])
                    {
                        preformMovePlayer(8, 2, 0);
                        playerSpritePos[0] += 16;
                        STATE_PLAY = 1;
                    }
                    break;
                case J_DOWN:
                    if (playerSpritePos[1] < yG[5])
                    {
                        preformMovePlayer(8, 0, 2);
                        STATE_PLAY = 1;
                        playerSpritePos[1] += 16;
                    }
                    break;
                case J_UP:
                    if (playerSpritePos[1] > yG[0])
                    {
                        preformMovePlayer(8, 0, -2);
                        STATE_PLAY = 1;
                        playerSpritePos[1] -= 16;
                    }
                    break;
            }
            preformantDelay(20);
        //}        
    }

}