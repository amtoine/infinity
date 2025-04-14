use ffmpeg.nu *
use log.nu [ "log info" ]

const BOLD_FONT = "/usr/share/fonts/Adwaita/AdwaitaMono-Bold.ttf"

const ISC_POS = { x: 505, y: 50 }
const ISC_FONT_SIZE = 30

const NAME_BOX = { x: 480, y: 80, w: (1560 - 480), h: (160 - 80) }
const NAME_FONT_SIZE = 60
const NAME_OFFSET_X = 28

const NAME_2_BOX = { x: 35, y: 780, w: (1560 - 35), h: (830 - 780) }
const NAME_2_FONT_SIZE = 30
const NAME_2_OFFSET_X = 10

const ICON_BOX = { x: 35, y: 35, w: (155 - 35), h: (155 - 35) }

const CHARACTERISTICS_BOX = { x: 35, y: 175, w: (120 - 35), h: null }
const CHARACTERISTICS_TEXT_POS = { x: ($CHARACTERISTICS_BOX.x + $CHARACTERISTICS_BOX.w // 2), y: 195 }
const CHARACTERISTICS_TEXT_FONT_SIZE = 30

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

const START = { kind: "color",    options: { c: "0xDDDDDD", s: "1600x1000", d: 1 } }

const IMAGE = { kind: "overlay",  options: { x: "320-w/2", y: "H-h-50" } }

const BOTTOM_FIRST_ROW_Y = 880
const BOTTOM_SECOND_ROW_Y = 925

const EQUIPMENT_BOX = { x: 35, y: 850, w: (690 - 35), h: (960 - 850) }
const EQUIPMENT_FONT_SIZE = 30
const EQUIPMENT_OFFSET_X = 10

const MELEE_BOX = { x: 710, y: 850, w: (1335 - 710), h: (960 - 850) }
const MELEE_FONT_SIZE = 30
const MELEE_OFFSET_X = 10

const SWC_BOX = { x: 1355, y: 850, w: (1445 - 1355), h: (960 - 850) }
const SWC_FONT_SIZE = 30
const SWC_OFFSET_X = 10

const C_BOX = { x: 1460, y: 850, w: (1560 - 1460), h: (960 - 850) }
const C_FONT_SIZE = 30
const C_OFFSET_X = 10

const SPECIAL_SKILLS_BOX = { x: 1240, y: 350, w: (1560 - 1240), h: null }
const SPECIAL_SKILLS_TITLE_FONT_SIZE = 30 + 2
const SPECIAL_SKILLS_FONT_SIZE = 18
const SPECIAL_SKILLS_OFFSET_X = 10

export def main [troop: record, --color: string, --output: path = "output.png"] {
    let equipment_text = [$troop.weaponry, $troop.equipment, $troop.peripheral]
        | each { default "_" }
        | $"($in.0) | ($in.1) || ($in.2)"

    let characteristics_box_h = $CHARACTERISTICS_BOX.w // 2 + (if ($troop.characteristics | is-empty) { 0 } else { 10 }) + 75 * ($troop.characteristics | length)
    let special_skills_box_h = 100 + 30 * (($troop.special_skills | length) - 1)

    let transforms = [
        { kind: "drawtext", options: { text: $"'ISC\\: ($troop.isc)'", fontcolor: "black", fontsize: $ISC_FONT_SIZE, x: $ISC_POS.x, y: $ISC_POS.y } },

        { kind: "drawbox",  options: { x: $NAME_BOX.x, y: $NAME_BOX.y, w: $NAME_BOX.w, h: $NAME_BOX.h, color: $"($color)@1.0", t: "fill" } },
        { kind: "drawbox",  options: { x: $NAME_BOX.x, y: $NAME_BOX.y, w: $NAME_BOX.w, h: $NAME_BOX.h, color: "black@0.4", t: "5" } },
        { kind: "drawtext", options: { text: $troop.name, fontfile: $BOLD_FONT, fontcolor: "white", fontsize: $NAME_FONT_SIZE, x: $"($NAME_BOX.x)+($NAME_OFFSET_X)", y: $"($NAME_BOX.y)+($NAME_BOX.h / 2)-th/2" } },

        { kind: "drawbox",  options: { x: $NAME_2_BOX.x, y: $NAME_2_BOX.y, w: $NAME_2_BOX.w, h: $NAME_2_BOX.h, color: $"($color)@1.0", t: "fill" } },
        { kind: "drawbox",  options: { x: $NAME_2_BOX.x, y: $NAME_2_BOX.y, w: $NAME_2_BOX.w, h: $NAME_2_BOX.h, color: "black@0.4", t: "5" } },
        { kind: "drawtext", options: { text: $troop.short_name, fontcolor: "white", fontsize: $NAME_2_FONT_SIZE, x: $"($NAME_2_BOX.x)+($NAME_2_OFFSET_X)", y: $"($NAME_2_BOX.y)+($NAME_2_BOX.h / 2)-th/2" } },

        { kind: "drawbox",  options: { x: $ICON_BOX.x, y: $ICON_BOX.y, w: $ICON_BOX.w, h: $ICON_BOX.h, color: "black@0.5", t: "fill" } },
        { kind: "drawbox",  options: { x: $ICON_BOX.x, y: $ICON_BOX.y, w: $ICON_BOX.w, h: $ICON_BOX.h, color: "black@0.5", t: "5" } },

        { kind: "drawbox",  options: { x: $CHARACTERISTICS_BOX.x, y: $CHARACTERISTICS_BOX.y, w: $CHARACTERISTICS_BOX.w, h: $characteristics_box_h, color: "black@0.5", t: "fill" } },
        { kind: "drawbox",  options: { x: $CHARACTERISTICS_BOX.x, y: $CHARACTERISTICS_BOX.y, w: $CHARACTERISTICS_BOX.w, h: $characteristics_box_h, color: "black@0.5", t: "5" } },
        { kind: "drawtext", options: { text: $troop.type, fontfile: $BOLD_FONT, fontcolor: "white", fontsize: $CHARACTERISTICS_TEXT_FONT_SIZE, x: $"($CHARACTERISTICS_TEXT_POS.x)-tw/2", y: $"($CHARACTERISTICS_TEXT_POS.y)-th/2" } },

        { kind: "drawbox",  options: { x: $STAT_KEYS_BOX.x, y: $STAT_KEYS_BOX.y, w: $STAT_KEYS_BOX.w, h: $STAT_KEYS_BOX.h, color: $"($color)@1.0", t: "fill" } },
        { kind: "drawbox",  options: { x: $STAT_KEYS_BOX.x, y: $STAT_KEYS_BOX.y, w: $STAT_KEYS_BOX.w, h: $STAT_KEYS_BOX.h, color: "black@0.4", t: "5" } },

        { kind: "drawbox",  options: { x: $STAT_VALS_BOX.x, y: $STAT_VALS_BOX.y, w: $STAT_VALS_BOX.w, h: $STAT_VALS_BOX.h, color: "black@0.5", t: "fill" } },
        { kind: "drawbox",  options: { x: $STAT_VALS_BOX.x, y: $STAT_VALS_BOX.y, w: $STAT_VALS_BOX.w, h: $STAT_VALS_BOX.h, color: "black@0.5", t: "5" } },

        ...(
            $troop.stats | transpose k v | enumerate | each { |it| [
                { kind: "drawtext", options: { text: $it.item.k, fontcolor: "white", fontsize: $STAT_FONT_SIZE, x: $"($STAT_KEYS_BOX.x)+($STAT_OFFSET_X)+($it.index)*($STAT_DX)-tw/2", y: $"($STAT_KEYS_BOX.y)+($STAT_KEYS_BOX.h / 2)-th/2" } },
                { kind: "drawtext", options: { text: $it.item.v, fontcolor: "white", fontsize: $STAT_FONT_SIZE, x: $"($STAT_VALS_BOX.x)+($STAT_OFFSET_X)+($it.index)*($STAT_DX)-tw/2", y: $"($STAT_VALS_BOX.y)+($STAT_VALS_BOX.h / 2)-th/2" } },
            ] } | flatten
        ),

        ...(
            if ($troop.special_skills | is-empty) {
                []
            } else {
                let box = [
                    { kind: "drawbox",  options: { x: $SPECIAL_SKILLS_BOX.x, y: $SPECIAL_SKILLS_BOX.y, w: $SPECIAL_SKILLS_BOX.w, h: $special_skills_box_h, color: "black@0.5", t: "fill" } },
                    { kind: "drawbox",  options: { x: $SPECIAL_SKILLS_BOX.x, y: $SPECIAL_SKILLS_BOX.y, w: $SPECIAL_SKILLS_BOX.w, h: $special_skills_box_h, color: "black@0.5", t: "5" } },
                    { kind: "drawtext", options: { text: "Special skills", fontfile: $BOLD_FONT, fontcolor: "white", fontsize: $SPECIAL_SKILLS_TITLE_FONT_SIZE, x: $"($SPECIAL_SKILLS_BOX.x)+($SPECIAL_SKILLS_OFFSET_X)", y: $"($SPECIAL_SKILLS_BOX.y)+30-th/2" } },
                ]
                let skills = $troop.special_skills | enumerate | each { |it|
                    [
                        { kind: "drawtext", options: {
                            text: $it.item,
                            fontcolor: "white",
                            fontsize: $SPECIAL_SKILLS_FONT_SIZE ,
                            x: $"($SPECIAL_SKILLS_BOX.x)+($SPECIAL_SKILLS_OFFSET_X)",
                            y: $"($SPECIAL_SKILLS_BOX.y)+80+30*($it.index)-th/2" },
                        },
                    ]
                }
                $box | append ($skills | flatten)
            }
        ),

        { kind: "drawbox",  options: { x: $EQUIPMENT_BOX.x, y: $EQUIPMENT_BOX.y, w: $EQUIPMENT_BOX.w, h: $EQUIPMENT_BOX.h, color: "black@0.5", t: "fill" } },
        { kind: "drawbox",  options: { x: $EQUIPMENT_BOX.x, y: $EQUIPMENT_BOX.y, w: $EQUIPMENT_BOX.w, h: $EQUIPMENT_BOX.h, color: "black@0.5", t: "5" } },
        { kind: "drawtext", options: { text: "WEAPONRY | EQUIPMENT || PERIPHERAL", fontfile: $BOLD_FONT, fontcolor: "white", fontsize: ($EQUIPMENT_FONT_SIZE + 2), x: $"($EQUIPMENT_BOX.x)+($EQUIPMENT_OFFSET_X)", y: $"($BOTTOM_FIRST_ROW_Y)-th/2" } },
        { kind: "drawtext", options: { text: $equipment_text, fontcolor: "white", fontsize: ($EQUIPMENT_FONT_SIZE - 5), x: $"($EQUIPMENT_BOX.x)+($EQUIPMENT_OFFSET_X)", y: $"($BOTTOM_SECOND_ROW_Y)-th/2" } },

        { kind: "drawbox",  options: { x: $MELEE_BOX.x, y: $MELEE_BOX.y, w: $MELEE_BOX.w, h: $MELEE_BOX.h, color: "black@0.5", t: "fill" } },
        { kind: "drawbox",  options: { x: $MELEE_BOX.x, y: $MELEE_BOX.y, w: $MELEE_BOX.w, h: $MELEE_BOX.h, color: "black@0.5", t: "5" } },
        { kind: "drawtext", options: { text: "MELEE WEAPONS", fontfile: $BOLD_FONT, fontcolor: "white", fontsize: ($MELEE_FONT_SIZE + 2), x: $"($MELEE_BOX.x)+($MELEE_OFFSET_X)", y: $"($BOTTOM_FIRST_ROW_Y)-th/2" } },
        { kind: "drawtext", options: { text: $"'($troop.melee_weapons | str join '\\, ')'", fontcolor: "white", fontsize: ($MELEE_FONT_SIZE - 5), x: $"($MELEE_BOX.x)+($MELEE_OFFSET_X)", y: $"($BOTTOM_SECOND_ROW_Y)-th/2" } },

        { kind: "drawbox",  options: { x: $SWC_BOX.x, y: $SWC_BOX.y, w: $SWC_BOX.w, h: $SWC_BOX.h, color: "black@0.5", t: "fill" } },
        { kind: "drawbox",  options: { x: $SWC_BOX.x, y: $SWC_BOX.y, w: $SWC_BOX.w, h: $SWC_BOX.h, color: "black@0.5", t: "5" } },
        { kind: "drawtext", options: { text: "SWC", fontfile: $BOLD_FONT, fontcolor: "white", fontsize: ($SWC_FONT_SIZE + 2), x: $"($SWC_BOX.x)+($SWC_BOX.w // 2)-tw/2", y: $"($BOTTOM_FIRST_ROW_Y)-th/2" } },
        { kind: "drawtext", options: { text: $troop.SWC, fontcolor: "white", fontsize: $SWC_FONT_SIZE, x: $"($SWC_BOX.x)+($SWC_BOX.w // 2)-tw/2", y: $"($BOTTOM_SECOND_ROW_Y)-th/2" } },

        { kind: "drawbox",  options: { x: $C_BOX.x, y: $C_BOX.y, w: $C_BOX.w, h: $C_BOX.h, color: "black@0.5", t: "fill" } },
        { kind: "drawbox",  options: { x: $C_BOX.x, y: $C_BOX.y, w: $C_BOX.w, h: $C_BOX.h, color: "black@0.5", t: "5" } },
        { kind: "drawtext", options: { text: "C", fontfile: $BOLD_FONT, fontcolor: "white", fontsize: ($C_FONT_SIZE + 2), x: $"($C_BOX.x)+($C_BOX.w // 2)-tw/2", y: $"($BOTTOM_FIRST_ROW_Y)-th/2" } },
        { kind: "drawtext", options: { text: $troop.C, fontcolor: "white", fontsize: $C_FONT_SIZE, x: $"($C_BOX.x)+($C_BOX.w // 2)-tw/2", y: $"($BOTTOM_SECOND_ROW_Y)-th/2" } },
    ]

    let tmp = ffmpeg create ($START | ffmpeg options) --output (mktemp --tmpdir XXXXXXX.png)
        | [$in, ({ parent: "./troops/assets/troops/", stem: $troop.asset, extension: "png" } | path join)] | ffmpeg combine ($IMAGE | ffmpeg options) --output (mktemp --tmpdir XXXXXXX.png)
        | if $troop.faction != null {
            [$in, ({ parent: "./troops/assets/factions/", stem: $troop.faction, extension: "png" } | path join)] | ffmpeg combine "[1:v]format=rgba,colorchannelmixer=aa=0.5[ol];[0:v][ol]overlay=x=1455-w/2:y=500-h/2" --output (mktemp --tmpdir XXXXXXX.png)
        } else {
            $in
        }
        | ffmpeg mapply ($transforms | each { ffmpeg options })

    $troop.characteristics
        | enumerate
        | reduce --fold $tmp { |it, acc|
            [$acc, ({ parent: "./troops/assets/characteristics/", stem: $it.item, extension: "png" } | path join)] | ffmpeg combine ({
                kind: "overlay",
                options: { x: $"($CHARACTERISTICS_BOX.x + $CHARACTERISTICS_BOX.w // 2)-w/2", y: $"255+($it.index * 75)-h/2" },
            } | ffmpeg options) --output (mktemp --tmpdir XXXXXXX.png)
        }
        | [$in, ({ parent: "./troops/assets/icons/", stem: ($troop.asset | str replace --regex '\..*$' ''), extension: "png" } | path join) ] | ffmpeg combine ({
            kind: "overlay",
            options: { x: $"($ICON_BOX.x + $ICON_BOX.w // 2)-w/2", y: $"($ICON_BOX.y + $ICON_BOX.h // 2)-h/2" },
        } | ffmpeg options) --output $output

    log info $"(ansi purple)($output)(ansi reset)"
}
