use ffmpeg.nu *

const ISC_POS = { x: 505, y: 50 }
const ISC_FONT_SIZE = 30

const NAME_BOX = { x: 480, y: 80, w: (1560 - 480), h: (160 - 80) }
const NAME_FONT_SIZE = 60
const NAME_OFFSET_X = 28

const NAME_2_BOX = { x: 35, y: 780, w: (1560 - 35), h: (830 - 780) }
const NAME_2_FONT_SIZE = 30
const NAME_2_OFFSET_X = 5

const ICON_BOX = { x: 35, y: 35, w: (155 - 35), h: (155 - 35) }

const HI_BOX = { x: 35, y: 175, w: (120 - 35), h: (375 - 175) }
const HI_TEXT_POS = { x: ($HI_BOX.x + $HI_BOX.w // 2), y: 195 }
const HI_TEXT_FONT_SIZE = 30

const BASE_POS = { x: 325, y: 950 }

const STAT_KEYS_BOX = { x: 480, y: 180, w: (1560 - 480), h: (245 - 180) }
const STAT_VALS_BOX = {
    x: $STAT_KEYS_BOX.x,
    y: 265,
    w: $STAT_KEYS_BOX.w,
    h: $STAT_KEYS_BOX.h,
}
const STAT_FONT_SIZE = 30
const STAT_DX = 108
const STAT_OFFSET_X = 60

const START = { kind: "color",    options: { c: "white", s: "1600x1000", d: 1 } }

const IMAGE = { kind: "overlay",  options: { x: "10", y: "H-h-50" } }
const FACTION_IMAGE = { kind: "overlay",  options: { x: "1455-w/2", y: "500-h/2" } }

const EQUIPMENT_BOX = { x: 35, y: 850, w: (690 - 35), h: (960 - 850) }
const EQUIPMENT_FONT_SIZE = 30
const EQUIPMENT_OFFSET_X = 5

const MELEE_BOX = { x: 710, y: 850, w: (1335 - 710), h: (960 - 850) }
const MELEE_FONT_SIZE = 30
const MELEE_OFFSET_X = 5

const SWC_BOX = { x: 1355, y: 850, w: (1445 - 1355), h: (960 - 850) }
const SWC_FONT_SIZE = 30
const SWC_OFFSET_X = 5

const C_BOX = { x: 1460, y: 850, w: (1560 - 1460), h: (960 - 850) }
const C_FONT_SIZE = 30
const C_OFFSET_X = 5

const TRANSFORMS = [
    { kind: "drawtext", options: { text: "'ISC\\: Orc Troops'", fontcolor: "black", fontsize: $ISC_FONT_SIZE, x: $ISC_POS.x, y: $ISC_POS.y } },

    { kind: "drawbox",  options: { x: $NAME_BOX.x, y: $NAME_BOX.y, w: $NAME_BOX.w, h: $NAME_BOX.h, color: "blue@0.5", t: "fill" } },
    { kind: "drawbox",  options: { x: $NAME_BOX.x, y: $NAME_BOX.y, w: $NAME_BOX.w, h: $NAME_BOX.h, color: "blue@0.5", t: "5" } },
    { kind: "drawtext", options: { text: "ORC TROOPS", fontcolor: "white", fontsize: $NAME_FONT_SIZE, x: $"($NAME_BOX.x)+($NAME_OFFSET_X)", y: $"($NAME_BOX.y)+($NAME_BOX.h / 2)-th/2" } },

    { kind: "drawbox",  options: { x: $NAME_2_BOX.x, y: $NAME_2_BOX.y, w: $NAME_2_BOX.w, h: $NAME_2_BOX.h, color: "blue@0.5", t: "fill" } },
    { kind: "drawbox",  options: { x: $NAME_2_BOX.x, y: $NAME_2_BOX.y, w: $NAME_2_BOX.w, h: $NAME_2_BOX.h, color: "blue@0.5", t: "5" } },
    { kind: "drawtext", options: { text: "ORC", fontcolor: "white", fontsize: $NAME_2_FONT_SIZE, x: $"($NAME_2_BOX.x)+($NAME_2_OFFSET_X)", y: $"($NAME_2_BOX.y)+($NAME_2_BOX.h / 2)-th/2" } },

    { kind: "drawbox",  options: { x: $ICON_BOX.x, y: $ICON_BOX.y, w: $ICON_BOX.w, h: $ICON_BOX.h, color: "black@0.5", t: "fill" } },
    { kind: "drawbox",  options: { x: $ICON_BOX.x, y: $ICON_BOX.y, w: $ICON_BOX.w, h: $ICON_BOX.h, color: "black@0.5", t: "5" } },

    { kind: "drawbox",  options: { x: $HI_BOX.x, y: $HI_BOX.y, w: $HI_BOX.w, h: $HI_BOX.h, color: "black@0.5", t: "fill" } },
    { kind: "drawbox",  options: { x: $HI_BOX.x, y: $HI_BOX.y, w: $HI_BOX.w, h: $HI_BOX.h, color: "black@0.5", t: "5" } },
    { kind: "drawtext", options: { text: "HI", fontcolor: "white", fontsize: $HI_TEXT_FONT_SIZE, x: $"($HI_TEXT_POS.x)-tw/2", y: $"($HI_TEXT_POS.y)-th/2" } },

    { kind: "drawbox",  options: { x: $STAT_KEYS_BOX.x, y: $STAT_KEYS_BOX.y, w: $STAT_KEYS_BOX.w, h: $STAT_KEYS_BOX.h, color: "blue@0.5", t: "fill" } },
    { kind: "drawbox",  options: { x: $STAT_KEYS_BOX.x, y: $STAT_KEYS_BOX.y, w: $STAT_KEYS_BOX.w, h: $STAT_KEYS_BOX.h, color: "blue@0.5", t: "5" } },

    { kind: "drawbox",  options: { x: $STAT_VALS_BOX.x, y: $STAT_VALS_BOX.y, w: $STAT_VALS_BOX.w, h: $STAT_VALS_BOX.h, color: "black@0.5", t: "fill" } },
    { kind: "drawbox",  options: { x: $STAT_VALS_BOX.x, y: $STAT_VALS_BOX.y, w: $STAT_VALS_BOX.w, h: $STAT_VALS_BOX.h, color: "black@0.5", t: "5" } },

    { kind: "drawtext", options: { text:  "MOV", fontcolor: "white", fontsize: $STAT_FONT_SIZE, x: $"($STAT_KEYS_BOX.x)+($STAT_OFFSET_X)+0*($STAT_DX)-tw/2", y: $"($STAT_KEYS_BOX.y)+($STAT_KEYS_BOX.h / 2)-th/2" } },
    { kind: "drawtext", options: { text:  "6-2", fontcolor: "white", fontsize: $STAT_FONT_SIZE, x: $"($STAT_VALS_BOX.x)+($STAT_OFFSET_X)+0*($STAT_DX)-tw/2", y: $"($STAT_VALS_BOX.y)+($STAT_VALS_BOX.h / 2)-th/2" } },

    { kind: "drawtext", options: { text:   "CC", fontcolor: "white", fontsize: $STAT_FONT_SIZE, x: $"($STAT_KEYS_BOX.x)+($STAT_OFFSET_X)+1*($STAT_DX)-tw/2", y: $"($STAT_KEYS_BOX.y)+($STAT_KEYS_BOX.h / 2)-th/2" } },
    { kind: "drawtext", options: { text:   "15", fontcolor: "white", fontsize: $STAT_FONT_SIZE, x: $"($STAT_VALS_BOX.x)+($STAT_OFFSET_X)+1*($STAT_DX)-tw/2", y: $"($STAT_VALS_BOX.y)+($STAT_VALS_BOX.h / 2)-th/2" } },

    { kind: "drawtext", options: { text:   "BS", fontcolor: "white", fontsize: $STAT_FONT_SIZE, x: $"($STAT_KEYS_BOX.x)+($STAT_OFFSET_X)+2*($STAT_DX)-tw/2", y: $"($STAT_KEYS_BOX.y)+($STAT_KEYS_BOX.h / 2)-th/2" } },
    { kind: "drawtext", options: { text:   "14", fontcolor: "white", fontsize: $STAT_FONT_SIZE, x: $"($STAT_VALS_BOX.x)+($STAT_OFFSET_X)+2*($STAT_DX)-tw/2", y: $"($STAT_VALS_BOX.y)+($STAT_VALS_BOX.h / 2)-th/2" } },

    { kind: "drawtext", options: { text:   "PH", fontcolor: "white", fontsize: $STAT_FONT_SIZE, x: $"($STAT_KEYS_BOX.x)+($STAT_OFFSET_X)+3*($STAT_DX)-tw/2", y: $"($STAT_KEYS_BOX.y)+($STAT_KEYS_BOX.h / 2)-th/2" } },
    { kind: "drawtext", options: { text:   "14", fontcolor: "white", fontsize: $STAT_FONT_SIZE, x: $"($STAT_VALS_BOX.x)+($STAT_OFFSET_X)+3*($STAT_DX)-tw/2", y: $"($STAT_VALS_BOX.y)+($STAT_VALS_BOX.h / 2)-th/2" } },

    { kind: "drawtext", options: { text:  "WIP", fontcolor: "white", fontsize: $STAT_FONT_SIZE, x: $"($STAT_KEYS_BOX.x)+($STAT_OFFSET_X)+4*($STAT_DX)-tw/2", y: $"($STAT_KEYS_BOX.y)+($STAT_KEYS_BOX.h / 2)-th/2" } },
    { kind: "drawtext", options: { text:   "12", fontcolor: "white", fontsize: $STAT_FONT_SIZE, x: $"($STAT_VALS_BOX.x)+($STAT_OFFSET_X)+4*($STAT_DX)-tw/2", y: $"($STAT_VALS_BOX.y)+($STAT_VALS_BOX.h / 2)-th/2" } },

    { kind: "drawtext", options: { text:  "BTS", fontcolor: "white", fontsize: $STAT_FONT_SIZE, x: $"($STAT_KEYS_BOX.x)+($STAT_OFFSET_X)+6*($STAT_DX)-tw/2", y: $"($STAT_KEYS_BOX.y)+($STAT_KEYS_BOX.h / 2)-th/2" } },
    { kind: "drawtext", options: { text:    "4", fontcolor: "white", fontsize: $STAT_FONT_SIZE, x: $"($STAT_VALS_BOX.x)+($STAT_OFFSET_X)+5*($STAT_DX)-tw/2", y: $"($STAT_VALS_BOX.y)+($STAT_VALS_BOX.h / 2)-th/2" } },

    { kind: "drawtext", options: { text: "VITA", fontcolor: "white", fontsize: $STAT_FONT_SIZE, x: $"($STAT_KEYS_BOX.x)+($STAT_OFFSET_X)+7*($STAT_DX)-tw/2", y: $"($STAT_KEYS_BOX.y)+($STAT_KEYS_BOX.h / 2)-th/2" } },
    { kind: "drawtext", options: { text:    "3", fontcolor: "white", fontsize: $STAT_FONT_SIZE, x: $"($STAT_VALS_BOX.x)+($STAT_OFFSET_X)+6*($STAT_DX)-tw/2", y: $"($STAT_VALS_BOX.y)+($STAT_VALS_BOX.h / 2)-th/2" } },

    { kind: "drawtext", options: { text:  "AVA", fontcolor: "white", fontsize: $STAT_FONT_SIZE, x: $"($STAT_KEYS_BOX.x)+($STAT_OFFSET_X)+8*($STAT_DX)-tw/2", y: $"($STAT_KEYS_BOX.y)+($STAT_KEYS_BOX.h / 2)-th/2" } },
    { kind: "drawtext", options: { text:    "2", fontcolor: "white", fontsize: $STAT_FONT_SIZE, x: $"($STAT_VALS_BOX.x)+($STAT_OFFSET_X)+7*($STAT_DX)-tw/2", y: $"($STAT_VALS_BOX.y)+($STAT_VALS_BOX.h / 2)-th/2" } },

    { kind: "drawtext", options: { text:  "ARM", fontcolor: "white", fontsize: $STAT_FONT_SIZE, x: $"($STAT_KEYS_BOX.x)+($STAT_OFFSET_X)+5*($STAT_DX)-tw/2", y: $"($STAT_KEYS_BOX.y)+($STAT_KEYS_BOX.h / 2)-th/2" } },
    { kind: "drawtext", options: { text:    "3", fontcolor: "white", fontsize: $STAT_FONT_SIZE, x: $"($STAT_VALS_BOX.x)+($STAT_OFFSET_X)+8*($STAT_DX)-tw/2", y: $"($STAT_VALS_BOX.y)+($STAT_VALS_BOX.h / 2)-th/2" } },

    { kind: "drawtext", options: { text:    "S", fontcolor: "white", fontsize: $STAT_FONT_SIZE, x: $"($STAT_KEYS_BOX.x)+($STAT_OFFSET_X)+9*($STAT_DX)-tw/2", y: $"($STAT_KEYS_BOX.y)+($STAT_KEYS_BOX.h / 2)-th/2" } },
    { kind: "drawtext", options: { text:    "2", fontcolor: "white", fontsize: $STAT_FONT_SIZE, x: $"($STAT_VALS_BOX.x)+($STAT_OFFSET_X)+9*($STAT_DX)-tw/2", y: $"($STAT_VALS_BOX.y)+($STAT_VALS_BOX.h / 2)-th/2" } },

    { kind: "drawbox",  options: { x: $EQUIPMENT_BOX.x, y: $EQUIPMENT_BOX.y, w: $EQUIPMENT_BOX.w, h: $EQUIPMENT_BOX.h, color: "black@0.5", t: "fill" } },
    { kind: "drawbox",  options: { x: $EQUIPMENT_BOX.x, y: $EQUIPMENT_BOX.y, w: $EQUIPMENT_BOX.w, h: $EQUIPMENT_BOX.h, color: "black@0.5", t: "5" } },

    { kind: "drawbox",  options: { x: $MELEE_BOX.x, y: $MELEE_BOX.y, w: $MELEE_BOX.w, h: $MELEE_BOX.h, color: "black@0.5", t: "fill" } },
    { kind: "drawbox",  options: { x: $MELEE_BOX.x, y: $MELEE_BOX.y, w: $MELEE_BOX.w, h: $MELEE_BOX.h, color: "black@0.5", t: "5" } },

    { kind: "drawbox",  options: { x: $SWC_BOX.x, y: $SWC_BOX.y, w: $SWC_BOX.w, h: $SWC_BOX.h, color: "black@0.5", t: "fill" } },
    { kind: "drawbox",  options: { x: $SWC_BOX.x, y: $SWC_BOX.y, w: $SWC_BOX.w, h: $SWC_BOX.h, color: "black@0.5", t: "5" } },

    { kind: "drawbox",  options: { x: $C_BOX.x, y: $C_BOX.y, w: $C_BOX.w, h: $C_BOX.h, color: "black@0.5", t: "fill" } },
    { kind: "drawbox",  options: { x: $C_BOX.x, y: $C_BOX.y, w: $C_BOX.w, h: $C_BOX.h, color: "black@0.5", t: "5" } },
]

export def main [] {
    ffmpeg create ($START | ffmpeg options) --output (mktemp --tmpdir XXXXXXX.png)
        | [$in, "troops/assets/00001.png"] | ffmpeg combine ($IMAGE | ffmpeg options) --output (mktemp --tmpdir XXXXXXX.png)
        | [$in, "troops/assets/panoceania.png"] | ffmpeg combine ($FACTION_IMAGE | ffmpeg options) --output (mktemp --tmpdir XXXXXXX.png)
        | ffmpeg mapply ($TRANSFORMS | each { ffmpeg options })
        | [$in, "troops/assets/hi-00001.png"] | ffmpeg combine ({ kind: "overlay",  options: { x: $"($HI_BOX.x + $HI_BOX.w // 2)-w/2", y: "255-h/2" } } | ffmpeg options) --output (mktemp --tmpdir XXXXXXX.png)
        | [$in, "troops/assets/hi-00002.png"] | ffmpeg combine ({ kind: "overlay",  options: { x: $"($HI_BOX.x + $HI_BOX.w // 2)-w/2", y: "330-h/2" } } | ffmpeg options) --output (mktemp --tmpdir XXXXXXX.png)
        | [$in, "troops/assets/icon-00001.png"] | ffmpeg combine ({ kind: "overlay",  options: { x: $"($ICON_BOX.x + $ICON_BOX.w // 2)-w/2", y: $"($ICON_BOX.y + $ICON_BOX.h // 2)-h/2" } } | ffmpeg options) --output (mktemp --tmpdir XXXXXXX.png)
}
