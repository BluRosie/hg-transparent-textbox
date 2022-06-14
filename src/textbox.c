#include "../include/window.h"

void Tr_TextBox(GF_BGL_BMPWIN *win)
{
    u8 type = 0;

    *(u16*)0x04000050 = 0x1b4f;
    *(u16*)0x04000052 = 0x0510;

    TalkWinGraphicSet(win->ini, GF_BGL_BmpWinGet_Frame(win),944, 10, 1, 4);
    
    if(GF_BGL_BmpWinGet_Frame(win) > 4)
        type = 4;
    ArcUtil_PalSet(38,51,type,10 * 0x20,0x20,4);

    FieldTalkWinClear(win);

    BmpTalkWinWrite(win, 0, 944, 10);
}

static u16 fontPal[16] = {0x3713, 0x296B, 0x5EF5, 0x089D, 0x5EBF, 0x0F45, 0x47B3, 0x7DC0, 0x76EF, 0x5E5F, 0x737F, 0x0000, 0x0000, 0x0000, 0x0000, 0x7FFF};
static u8 colorComponents[2][3] = {{0, 0, 0}, {0, 0, 0}}; // rgb for both normal color and the shade color.  
static u8 slotToOverwrite = 3; // by default overwrite the red color

// colors are abbbbbgggggrrrrr
#define COMP_RED (0)
#define COMP_GREEN (1)
#define COMP_BLUE (2)

extern void (* const PalSetEzCommon_FuncTable[])(const void*, u32, u32); // 20F5968

void ArcUtil_PalSetEzCommon_rawPal(u32 palType, u32 srcOfs, u32 dstOfs, u32 transSize)
{
    u32 changePalette = FALSE;
    for (int i = 0; i < 2; i++)
    {
        for (int j = 0; j < 3; j++)
        {
            if (colorComponents[i][j] != 0)
                changePalette = TRUE;                
        }
    }

    if (changePalette && slotToOverwrite < 15)
    {
        fontPal[slotToOverwrite] = (colorComponents[0][COMP_RED] / 8)  
                                 | (colorComponents[0][COMP_GREEN] / 8) << 5
                                 | (colorComponents[0][COMP_BLUE] / 8) << 10;
        slotToOverwrite++;
        fontPal[slotToOverwrite] = (colorComponents[1][COMP_RED] / 8)  
                                 | (colorComponents[1][COMP_GREEN] / 8) << 5
                                 | (colorComponents[1][COMP_BLUE] / 8) << 10;
    }
    

    switch( palType )
    {
    case 2:
        GX_BeginLoadBGExtPltt();
        PalSetEzCommon_FuncTable[ palType ]( &fontPal[0], dstOfs, transSize );
        GX_EndLoadBGExtPltt();
        break;
    case 6:
        GXS_BeginLoadBGExtPltt();
        PalSetEzCommon_FuncTable[ palType ]( &fontPal[0], dstOfs, transSize );
        GXS_EndLoadBGExtPltt();
        break;
    case 3:
        GX_BeginLoadOBJExtPltt();
        PalSetEzCommon_FuncTable[ palType ]( &fontPal[0], dstOfs, transSize );
        GX_EndLoadOBJExtPltt();
        break;
    case 7:
        GXS_BeginLoadOBJExtPltt();
        PalSetEzCommon_FuncTable[ palType ]( &fontPal[0], dstOfs, transSize );
        GXS_EndLoadOBJExtPltt();
        break;
    default:
        PalSetEzCommon_FuncTable[ palType ]( &fontPal[0], dstOfs, transSize );
        break;
    }
}

void FieldMsgPrintInit(u32 type, u32 init)
{
    if (init == 1)
    {
        MSG_PrintInit();
    }
    SystemFontPaletteLoad(type, 0x1a0, 4);
    // ArcUtil_PalSet( /*16*/ARC_FONT, /*7*/NARC_font_system_ncrl, (PALTYPE)type, /*0x1a0*/offs, 0x20, /*4*/heap );
    // ArcUtil_PalSetEzCommon_rawPal(type, 0, 0x1a0, 0x20);

    ArcUtil_PalSetEzCommon_rawPal(type, 0, 0x180, 0x20);
    //ArcUtil_PalSet(16, 10, type, 0x180, 0x20, 4);
}
