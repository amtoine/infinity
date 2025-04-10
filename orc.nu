use ffmpeg.nu *

const NAME_BOX = { x: 480, y: 80, w: (1560 - 480), h: (160 - 80) }
const NAME_FONT_SIZE = 60
const NAME_OFFSET_X = 28

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

const TRANSFORMS = [
    { kind: "color",    options: { c: "white", s: "1600x1000", d: 1 } },

    { kind: "drawbox",  options: { x: $NAME_BOX.x, y: $NAME_BOX.y, w: $NAME_BOX.w, h: $NAME_BOX.h, color: "blue@0.5", t: "fill" } },
    { kind: "drawbox",  options: { x: $NAME_BOX.x, y: $NAME_BOX.y, w: $NAME_BOX.w, h: $NAME_BOX.h, color: "blue@0.5", t: "5" } },
    { kind: "drawtext", options: { text: "ORC TROOPS", fontcolor: "white", fontsize: $NAME_FONT_SIZE, x: $"($NAME_BOX.x)+($NAME_OFFSET_X)", y: $"($NAME_BOX.y)+($NAME_BOX.h / 2)-th/2" } },

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

]

export def main [] {
    ffmpeg mapply ($TRANSFORMS | each { ffmpeg options })
}
