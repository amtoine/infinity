use ffmpeg.nu *
use log.nu [ "log info", "log warning", "log error", "log debug" ]
use std iter

const CANVAS = { w: 1600, h: 1000 }
const BASE_IMAGE = { kind: "color", options: { c: "0xDDDDDD", s: $"($CANVAS.w)x($CANVAS.h)", d: 1 } }

const ASSETS_DIR = "./troops/assets/"
const DIRS = {
    minis:            ($ASSETS_DIR | path join "minis"),
    factions:         ($ASSETS_DIR | path join "factions" "940"),
    allowed_factions: ($ASSETS_DIR | path join "factions" "70")
    characteristics:  ($ASSETS_DIR | path join "characteristics"),
    icons:            ($ASSETS_DIR | path join "icons"),
}

const BOLD_FONT = "./adwaita-fonts-48.2/mono/AdwaitaMono-Bold.ttf"
const REGULAR_FONT = "./adwaita-fonts-48.2/mono/AdwaitaMono-Regular.ttf"

const VERSION_POS = { x: $"($CANVAS.w)-tw-2", y: $"($CANVAS.h)-th-2" }
const VERSION_FONT = { fontfile: $REGULAR_FONT, fontsize: 15, fontcolor: "black"}

const NAME_BOX = { x: 480, y: 80, w: (1560 - 480), h: (160 - 80) }
const NAME_OFFSET_X = 28
const NAME_POS = { x: $"($NAME_BOX.x)+($NAME_OFFSET_X)", y: $"($NAME_BOX.y)+($NAME_BOX.h / 2)-th/2" }
const NAME_FONT = { fontfile: $BOLD_FONT, fontcolor: "white", fontsize: 45 }

const ISC_POS = { x: ($NAME_BOX.x + $NAME_OFFSET_X), y: ($NAME_BOX.y - $NAME_OFFSET_X) }
const CLASSIFICATION_POS = { x: $"($NAME_BOX.x + $NAME_BOX.w - $NAME_OFFSET_X)-tw", y: $ISC_POS.y }
const ISC_FONT = { fontfile: $REGULAR_FONT, fontcolor: "black", fontsize: 30 }

const QR_CODE_SIZE = 4
const QR_CODE_MARGIN = 1
const QR_CODE_WIDTH = (33 + ($QR_CODE_MARGIN) * 2) * $QR_CODE_SIZE

const NAME_2_BOX = { x: 810, y: 780, w: (1560 - ($QR_CODE_WIDTH + 10) - 810), h: (830 - 780) }
const NAME_2_OFFSET_X = 10
const NAME_2_POS = { x: $"($NAME_2_BOX.x)+($NAME_2_OFFSET_X)", y: $"($NAME_2_BOX.y)+($NAME_2_BOX.h / 2)-th/2" }
const NAME_2_FONT = { fontfile: $REGULAR_FONT, fontcolor: "white", fontsize: 30 }

const ICON_BOX = { x: 35, y: 35, w: (155 - 35), h: (155 - 35) }

const CHARACTERISTICS_BOX = { x: 35, y: 175, w: (120 - 35), h: null }
const CHARACTERISTICS_V_SPACE = 10
const CHARACTERISTICS_IMAGE_SIZE = 70 + 5
const CHARACTERISTICS_TYPE_POS = { x: $"($CHARACTERISTICS_BOX.x + $CHARACTERISTICS_BOX.w // 2)-tw/2", y: $"($CHARACTERISTICS_BOX.y + 20)-th/2" }
const CHARACTERISTICS_TYPE_FONT = { fontfile: $BOLD_FONT, fontcolor: "white", fontsize: 30 }

const FACTION_POS = { x: 1455, y: 500 }

const STAT_KEYS_BOX = { x: 480, y: 180, w: (1560 - 480), h: (245 - 180) }
const STAT_VALS_BOX = {
    x: $STAT_KEYS_BOX.x,
    y: 265,
    w: $STAT_KEYS_BOX.w,
    h: $STAT_KEYS_BOX.h,
}
const STAT_H_SPACE = 108
const STAT_OFFSET_X = 60
const STAT_FONT = { fontfile: $REGULAR_FONT, fontcolor: "white", fontsize: 30 }

const MINI_OVERLAY = { kind: "overlay",  options: { x: "320-w/2", y: "H-h-50" } }
const QR_CODE_OVERLAY = { kind: "overlay",  options: { x: "1560-w", y: $"($NAME_2_BOX.y + $NAME_2_BOX.h)-h" } }

const ALLOWED_FACTIONS_OFFSET = { x: 50, y: 50 }
const ALLOWED_FACTIONS_IMAGE_SIZE = 70 + 10

const BOTTOM_FIRST_ROW_Y = 880
const BOTTOM_SECOND_ROW_Y = 925

const BOXES_MARGIN = 20
const EMPTY_BOX_HEIGHT = 60
const FULL_BOX_HEIGHT = 110

const EQUIPMENT_BOX = { x: 35, y: 850, w: (790 - 35), h: null }
const EQUIPMENT_OFFSET_X = 10
const EQUIPMENT_TITLE_POS = { x: $"($EQUIPMENT_BOX.x)+($EQUIPMENT_OFFSET_X)", y: $"($BOTTOM_FIRST_ROW_Y)-th/2" }
const EQUIPMENT_POS = { x: $"($EQUIPMENT_BOX.x)+($EQUIPMENT_OFFSET_X)", y: $"($BOTTOM_SECOND_ROW_Y)-th/2" }
const EQUIPMENT_FONT_SIZE = 30
const EQUIPMENT_TITLE_FONT = { fontfile: $BOLD_FONT, fontcolor: "white", fontsize: ($EQUIPMENT_FONT_SIZE - 2) }
const EQUIPMENT_FONT = { fontfile: $REGULAR_FONT, fontcolor: "white", fontsize: ($EQUIPMENT_FONT_SIZE - 8) }

const LIST_SEPARATOR = ", "
const LIST_SEPARATOR_V_OFFSET = 10
const EQUIPMENT_CHAR_SIZE = $EQUIPMENT_FONT.fontsize * 0.6

const MELEE_BOX = { x: 810, y: 850, w: (1335 - 810), h: (960 - 850) }
const MELEE_OFFSET_X = 10
const MELEE_WEAPONS_TITLE_POS = { x: $"($MELEE_BOX.x)+($MELEE_OFFSET_X)", y: $"($BOTTOM_FIRST_ROW_Y)-th/2" }
const MELEE_WEAPONS_POS = { x: $"($MELEE_BOX.x)+($MELEE_OFFSET_X)", y: $"($BOTTOM_SECOND_ROW_Y)-th/2" }
const MELEE_FONT_SIZE = 30
const MELEE_WEAPONS_TITLE_FONT  = { fontfile: $BOLD_FONT, fontcolor: "white", fontsize: ($MELEE_FONT_SIZE - 2) }
const MELEE_WEAPONS_FONT = { fontfile: $REGULAR_FONT, fontcolor: "white", fontsize: ($MELEE_FONT_SIZE - 8) }

const SWC_BOX = { x: 1355, y: 850, w: (1445 - 1355), h: (960 - 850) }
const SWC_TITLE_POS = { x: $"($SWC_BOX.x)+($SWC_BOX.w // 2)-tw/2", y: $"($BOTTOM_FIRST_ROW_Y)-th/2" }
const SWC_POS = { x: $"($SWC_BOX.x)+($SWC_BOX.w // 2)-tw/2", y: $"($BOTTOM_SECOND_ROW_Y)-th/2" }
const SWC_FONT_SIZE = 30
const SWC_TITLE_FONT = { fontfile: $BOLD_FONT, fontcolor: "white", fontsize: $SWC_FONT_SIZE }
const SWC_FONT = { fontfile: $REGULAR_FONT, fontcolor: "white", fontsize: $SWC_FONT_SIZE }

const C_BOX = { x: 1460, y: 850, w: (1560 - 1460), h: (960 - 850) }
const C_TITLE_POS = { x: $"($C_BOX.x)+($C_BOX.w // 2)-tw/2", y: $"($BOTTOM_FIRST_ROW_Y)-th/2" }
const C_POS = { x: $"($C_BOX.x)+($C_BOX.w // 2)-tw/2", y: $"($BOTTOM_SECOND_ROW_Y)-th/2" }
const C_FONT_SIZE = 30
const C_TITLE_FONT = { fontfile: $BOLD_FONT, fontcolor: "white", fontsize: $C_FONT_SIZE }
const C_FONT = { fontfile: $REGULAR_FONT, fontcolor: "white", fontsize: $C_FONT_SIZE }

const SPECIAL_SKILLS_BOX = { x: 1135, y: 350, w: (1560 - 1135), h: null }
const SPECIAL_SKILLS_OFFSET = { x: 10, y: 80 }
const SPECIAL_SKILLS_V_BASE = 100
const SPECIAL_SKILLS_V_SPACE = 30
const SPECIAL_SKILLS_TITLE_POS = { x: $"($SPECIAL_SKILLS_BOX.x)+($SPECIAL_SKILLS_OFFSET.x)", y: $"($SPECIAL_SKILLS_BOX.y)+30-th/2" }
const SPECIAL_SKILLS_TITLE_FONT = { fontfile: $BOLD_FONT,    fontcolor: "white", fontsize: 32 }
const SPECIAL_SKILLS_FONT       = { fontfile: $REGULAR_FONT, fontcolor: "white", fontsize: 18 }

def "ffmpeg-text" [text: string, position: record<x, y>, options: record] {
    let text = $text
        | str replace --all ":" "\\:"
        | str replace --all "," "\\,"
        | str replace --all "[" "\\["
        | str replace --all "]" "\\]"
        | $"'($in)'"
    { kind: "drawtext", options: { text: $text, ...$position, ...$options } }
}

def "put-version" []: [ path -> path ] {
    let versions = open versions.json
    let version_text = $"(git describe) [Army: ($versions.army), Rules: ($versions.rules)]"
    let out = mktemp --tmpdir infinity-XXXXXXX.png
    $in | ffmpeg apply ((ffmpeg-text $version_text $VERSION_POS $VERSION_FONT) | ffmpeg options) --output $out
}

const RANGES = ['8"', '16"', '24"', '32"', '40"', '48"', '96"']
const STATS = [
    [field,                    short];
    [PS,                       PS],
    [B,                        B],
    [AMMUNITION,               AMMO],
    ["SAVING ROLL ATTRIBUTE",  ATTR],
    ["NUMBER OF SAVING ROLLS", SR],
    ["TRAITS",                 TRAITS],
]

const CORVUS_BELLI_COLORS = {
    green:  "0x76ac5d",
    blue:   "0x59b9d1",
    yellow: "0xea9931",
    red:    "0xdc3e4c",
    black:  "0x231f20",
    gray:   "0xcdd5de",
}

const CHART_FONT_SIZE = 25
const CHART_FONT_CHAR_SIZE = 15
const CHART_OFFSET_Y = 30
const CHART_ATTR_INTERSPACE = 15
const CHART_RANGE_CELL_WIDTH = 98
const CHART_RANGE_CELL_HEIGHT = 50
const CHART_START = { x: 20, y: 50 }
const CHART_NAMES_OFFSET_X = 10
const CHART_FONT_B = { fontfile: $BOLD_FONT,    fontcolor: "black", fontsize: $CHART_FONT_SIZE }
const CHART_FONT_R = { fontfile: $REGULAR_FONT, fontcolor: "black", fontsize: $CHART_FONT_SIZE }
const CHART_V_SPACE = 60
const CHART_TRAITS_V_SPACE = 50
const CHART_TRAITS_H_SPACE = 20

def put-weapon-chart [equipment: record, x: int, y: int, column_widths: record, --no-header]: [ path -> path ] {
    let widths = $column_widths | values
    let positions = $widths
        | zip ($widths | skip 1)
        | reduce --fold [($CHART_ATTR_INTERSPACE + $CHART_FONT_CHAR_SIZE * $widths.0)] { |it, acc|
            $acc | append (($acc | last) + $CHART_ATTR_INTERSPACE + $CHART_FONT_CHAR_SIZE * ($it.0 + $it.1) / 2)
        }

    let transforms = [
        # range headers
        ...(
            if $no_header {
                []
            } else {
                $RANGES | enumerate | each {
                    let pos = {
                        x: $"($x + $CHART_RANGE_CELL_WIDTH / 2 + $in.index * $CHART_RANGE_CELL_WIDTH + $in.index - 1)-tw/2",
                        y: $y
                    }
                    ffmpeg-text $in.item $pos $CHART_FONT_B
                }
            }
        ),
        # range values
        ...($RANGES | enumerate | each { |it|
            let color = match ($equipment.stats | get $it.item) {
                "+3" | 3 | "3" => $CORVUS_BELLI_COLORS.green,
                "0" | 0 => $CORVUS_BELLI_COLORS.blue,
                "-3" | -3 => $CORVUS_BELLI_COLORS.yellow,
                "-6" | -6 => $CORVUS_BELLI_COLORS.red,
                "null" => $CORVUS_BELLI_COLORS.black,
                _ => $CORVUS_BELLI_COLORS.gray,
            }

            {
                kind: "drawbox",
                options: {
                    x: ($x + $it.index * $CHART_RANGE_CELL_WIDTH + $in.index - 1),
                    y: (if $no_header { $y } else { $y + $CHART_OFFSET_Y }),
                    w: $CHART_RANGE_CELL_WIDTH, h: $CHART_RANGE_CELL_HEIGHT,
                    color: $color, t: "fill",
                },
            }
        }),
        # stats headers
        ...(
            if $no_header {
                []
            } else {
                $STATS | zip $positions | enumerate | each {
                    let pos = {
                        x: $"($x + ($RANGES | length) * $CHART_RANGE_CELL_WIDTH + ($RANGES | length) - 1 + $in.item.1)-tw/2",
                        y: $y
                    }
                    ffmpeg-text $in.item.0.short $pos $CHART_FONT_B
                }
            }
        ),
        # stats values
        ...($STATS | zip $positions | enumerate | each { |it|
            let pos = {
                x: $"($x + ($RANGES | length) * $CHART_RANGE_CELL_WIDTH + ($RANGES | length) - 1 + $it.item.1)-tw/2",
                y: $"(if $no_header { $y } else { $y + $CHART_OFFSET_Y })+($CHART_RANGE_CELL_HEIGHT / 2)-th/2"
            }
            if $it.item.0.field == "TRAITS" {
                let text = if ($equipment.stats | get $it.item.0.field | is-empty) {
                    ""
                } else {
                    "*"
                }
                ffmpeg-text $text $pos $CHART_FONT_R
            } else {
                let stat = $equipment.stats | get $it.item.0.field

                if $equipment.mod != null and $it.item.0.field == $equipment.mod.k {
                    let v = $equipment.mod.v | into int
                    let res = match $equipment.mod.x? {
                         "-" => { text: $"($stat - $v)", color: $CORVUS_BELLI_COLORS.red },
                         "+" => { text: $"($stat + $v)", color: $CORVUS_BELLI_COLORS.green },
                        null => { text: $"($v)",         color: $CORVUS_BELLI_COLORS.yellow },
                    }
                    ffmpeg-text $"($res.text)" $pos ($CHART_FONT_B | update fontcolor $res.color)
                } else {
                    ffmpeg-text $"($stat)" $pos $CHART_FONT_R
                }
            }
        }),
    ]

    $in | ffmpeg mapply ($transforms | each { ffmpeg options }) --output (mktemp --tmpdir infinity-XXXXXXX.png)
}

def gen-stat-page [
    troop: record,
    color: string,
    output: path,
    modifiers: table<name: string, mod: record>,
] {
    def equipment-or-skill-to-text [
        equipment_or_skill,
        base_font: record<fontfile: path, fontcolor: string, fontsize: int>,
        pos: record<x: any, y: any>,
    ]: [ nothing -> record<transform: record, text: string> ] {
        let equipment_or_skill = match ($equipment_or_skill | describe --detailed).type {
            "string" => { name: $equipment_or_skill },
            "record" => $equipment_or_skill,
        }

        let text = if $equipment_or_skill.mod? == null {
            $equipment_or_skill.name
        } else {
            $"($equipment_or_skill.name) \(($equipment_or_skill.mod)\)"
        }
        let font = $base_font | if $equipment_or_skill.spec? == true {
            update fontfile $BOLD_FONT | update fontcolor $CORVUS_BELLI_COLORS.yellow
        } else {
            $in
        }

        { transform: (ffmpeg-text $text $pos $font), text: $text }
    }

    def equipment-to-text [x: record]: [ nothing -> list<record> ] {
        if $x.equipment == [] {
            return []
        }

        $x.equipment
            | iter intersperse $LIST_SEPARATOR
            | reduce --fold { transforms: [], pos: $x.text_pos } { |it, acc|
                let pos = if $it == $LIST_SEPARATOR {
                    $acc.pos | update y { $"($in)+($LIST_SEPARATOR_V_OFFSET)" }
                } else {
                    $acc.pos
                }
                let res = equipment-or-skill-to-text $it $EQUIPMENT_FONT $pos
                let next_pos = $acc.pos
                    | update x { $"($in) + (($res.text | str length) * $EQUIPMENT_CHAR_SIZE)" }

                { transforms: ($acc.transforms | append $res.transform), pos: $next_pos }
            }
            | get transforms
    }

    let modifiers = $modifiers | transpose --header-row | into record

    let peripheral = $troop.peripheral | if $in == [] {{
        equipment: $in,
        box: ($EQUIPMENT_BOX | update h $EMPTY_BOX_HEIGHT | update y { $in + $FULL_BOX_HEIGHT - $EMPTY_BOX_HEIGHT }),
        title_pos: ($EQUIPMENT_TITLE_POS | update y { $"($in)+($FULL_BOX_HEIGHT - $EMPTY_BOX_HEIGHT)" }),
        text_pos: ($EQUIPMENT_POS | update y { $"($in)+($FULL_BOX_HEIGHT - $EMPTY_BOX_HEIGHT)" }),
    }} else {{
        equipment: $in,
        box: ($EQUIPMENT_BOX | update h $FULL_BOX_HEIGHT),
        title_pos: $EQUIPMENT_TITLE_POS,
        text_pos: $EQUIPMENT_POS,
    }}

    let equipment = $troop.equipment | if $in == [] {{
        equipment: $in,
        box: ($peripheral.box | update y { $in - ($BOXES_MARGIN + $EMPTY_BOX_HEIGHT) } | update h $EMPTY_BOX_HEIGHT),
        title_pos: ($peripheral.title_pos | update y { $"($in)-($BOXES_MARGIN + $EMPTY_BOX_HEIGHT)" }),
        text_pos: ($peripheral.text_pos | update y { $"($in)-($BOXES_MARGIN + $EMPTY_BOX_HEIGHT)" }),
    }} else {{
        equipment: $in,
        box: ($peripheral.box | update y { $in - ($BOXES_MARGIN + $FULL_BOX_HEIGHT) } | update h $FULL_BOX_HEIGHT),
        title_pos: ($peripheral.title_pos | update y { $"($in)-($BOXES_MARGIN + $FULL_BOX_HEIGHT)" }),
        text_pos: ($peripheral.text_pos | update y { $"($in)-($BOXES_MARGIN + $FULL_BOX_HEIGHT)" }),
    }}

    let weaponry = $troop.weaponry | if $in == [] {{
        equipment: $in,
        box: ($equipment.box | update y { $in - ($BOXES_MARGIN + $EMPTY_BOX_HEIGHT) } | update h $EMPTY_BOX_HEIGHT),
        title_pos: ($equipment.title_pos | update y { $"($in)-($BOXES_MARGIN + $EMPTY_BOX_HEIGHT)" }),
        text_pos: ($equipment.text_pos | update y { $"($in)-($BOXES_MARGIN + $EMPTY_BOX_HEIGHT)" }),
    }} else {{
        equipment: $in,
        box: ($equipment.box | update y { $in - ($BOXES_MARGIN + $FULL_BOX_HEIGHT) } | update h $FULL_BOX_HEIGHT),
        title_pos: ($equipment.title_pos | update y { $"($in)-($BOXES_MARGIN + $FULL_BOX_HEIGHT)" }),
        text_pos: ($equipment.text_pos | update y { $"($in)-($BOXES_MARGIN + $FULL_BOX_HEIGHT)" }),
    }}

    let characteristics_box = $CHARACTERISTICS_BOX | update h (
        $CHARACTERISTICS_BOX.w // 2 +  # because text is twice larger
        (if ($troop.characteristics | is-empty) { 0 } else { $CHARACTERISTICS_V_SPACE }) +
        $CHARACTERISTICS_IMAGE_SIZE * ($troop.characteristics | length)
    )
    let special_skills_box = $SPECIAL_SKILLS_BOX | update h (
        $SPECIAL_SKILLS_V_BASE + $SPECIAL_SKILLS_V_SPACE * (($troop.special_skills | length) - 1)
    )

    let qrcode = mktemp --tmpdir infinity-XXXXXXX.png
    log info $"generating QR code in (ansi purple)($qrcode)(ansi reset)"
    qrencode --margin $QR_CODE_MARGIN --size $QR_CODE_SIZE -o $qrcode $troop.reference

    let transforms = [
        (ffmpeg-text $"ISC: ($troop.isc)"  $ISC_POS            $ISC_FONT),
        (ffmpeg-text $troop.classification $CLASSIFICATION_POS $ISC_FONT),

        { kind: "drawbox",  options: { ...$NAME_BOX, color: $"($color)@1.0", t: "fill" } },
        { kind: "drawbox",  options: { ...$NAME_BOX, color: "black@0.4",     t: "5" } },
        (ffmpeg-text $troop.name $NAME_POS $NAME_FONT),

        { kind: "drawbox",  options: { ...$NAME_2_BOX, color: $"($color)@1.0", t: "fill" } },
        { kind: "drawbox",  options: { ...$NAME_2_BOX, color: "black@0.4",     t: "5" } },
        (ffmpeg-text $troop.short_name $NAME_2_POS $NAME_2_FONT),

        { kind: "drawbox",  options: { ...$ICON_BOX, color: "black@0.5", t: "fill" } },
        { kind: "drawbox",  options: { ...$ICON_BOX, color: "black@0.5", t: "5" } },

        { kind: "drawbox",  options: { ...$characteristics_box, color: "black@0.5", t: "fill" } },
        { kind: "drawbox",  options: { ...$characteristics_box, color: "black@0.5", t: "5" } },
        (ffmpeg-text $troop.type $CHARACTERISTICS_TYPE_POS $CHARACTERISTICS_TYPE_FONT),

        { kind: "drawbox",  options: { ...$STAT_KEYS_BOX, color: $"($color)@1.0", t: "fill" } },
        { kind: "drawbox",  options: { ...$STAT_KEYS_BOX, color: "black@0.4",     t: "5" } },

        { kind: "drawbox",  options: { ...$STAT_VALS_BOX, color: "black@0.5",     t: "fill" } },
        { kind: "drawbox",  options: { ...$STAT_VALS_BOX, color: "black@0.5",     t: "5" } },
        ...(
            $troop.stats | transpose k v | enumerate | each { |it|
                const MARTIAL_ARTS = [
                    [level, attack, opponent, burst      ];
                    [    1,      0,       -3, [0]        ],
                    [    2,     +3,       -3, [0]        ],
                    [    3,     +3,       -3, [+1SD]     ],
                    [    4,     +3,       -3, [+1B]      ],
                    [    5,     +3,       -3, [+1B, +1SD]],
                ]

                let stat = match $it.item.k {
                    "BS" => {
                        if $modifiers."BS Attack"? != null {
                            let v = $modifiers."BS Attack".v | into int
                            match $modifiers."BS Attack".x? {
                                 "-" => { v: $"($it.item.v - $v)", color: $CORVUS_BELLI_COLORS.red    },
                                 "+" => { v: $"($it.item.v + $v)", color: $CORVUS_BELLI_COLORS.green  },
                                null => { v: $"($v)",              color: $CORVUS_BELLI_COLORS.yellow },
                            }
                        } else {
                            { v: $it.item.v, color: $STAT_FONT.fontcolor }
                        }
                    },
                    "CC" => {
                        let cc_value = if $modifiers."CC Attack"? != null {
                            let v = $modifiers."CC Attack".v | into int
                            match $modifiers."CC Attack".x? {
                                 "-" => { $it.item.v - $v },
                                 "+" => { $it.item.v + $v },
                                null => { $v },
                            }
                        } else {
                            $it.item.v
                        }
                        let cc_value = if $modifiers."Martial Arts"? != null {
                            let art = $MARTIAL_ARTS | where level == $modifiers."Martial Arts".v | into record
                            $cc_value + $art.attack
                        } else {
                            $cc_value
                        }

                        let color = if $modifiers."CC Attack"? == null and $modifiers."Martial Arts"? == null {
                            $STAT_FONT.fontcolor
                        } else if $cc_value - $it.item.v == 0 {
                            $CORVUS_BELLI_COLORS.yellow
                        } else if $cc_value - $it.item.v > 0 {
                            $CORVUS_BELLI_COLORS.green
                        } else {
                            $CORVUS_BELLI_COLORS.red
                        }

                        { v: $cc_value, color: $color }
                    },
                    "MOV" => {
                        if $modifiers."Terrain"? != null {
                            match $modifiers."Terrain" {
                                "Total" => {
                                    let mov = $it.item.v | parse "{f}-{s}" | into record | into int f s
                                    { v: $"($mov.f + 1)-($mov.s)", color: $CORVUS_BELLI_COLORS.green }
                                },
                                _ => {  v: $it.item.v, color: $CORVUS_BELLI_COLORS.yellow },
                            }
                        } else {
                            { v: $it.item.v, color: $STAT_FONT.fontcolor }
                        }
                    },
                    _ => { v: $it.item.v, color: $STAT_FONT.fontcolor },
                }

                [
                    (ffmpeg-text $"($it.item.k)" { x: $"($STAT_KEYS_BOX.x)+($STAT_OFFSET_X)+($it.index)*($STAT_H_SPACE)-tw/2", y: $"($STAT_KEYS_BOX.y)+($STAT_KEYS_BOX.h / 2)-th/2" } $STAT_FONT),
                    (ffmpeg-text $"($stat.v)" { x: $"($STAT_VALS_BOX.x)+($STAT_OFFSET_X)+($it.index)*($STAT_H_SPACE)-tw/2", y: $"($STAT_VALS_BOX.y)+($STAT_VALS_BOX.h / 2)-th/2" } ($STAT_FONT | update fontcolor $stat.color)),
                ]
            } | flatten
        ),

        ...(
            if ($troop.special_skills | is-empty) {
                []
            } else {
                let box = [
                    { kind: "drawbox",  options: { ...$special_skills_box, color: "black@0.5", t: "fill" } },
                    { kind: "drawbox",  options: { ...$special_skills_box, color: "black@0.5", t: "5" } },
                    (ffmpeg-text "Special skills" $SPECIAL_SKILLS_TITLE_POS $SPECIAL_SKILLS_TITLE_FONT),
                ]
                let skills = $troop.special_skills | enumerate | each { |it|
                    let pos = {
                        x: $"($SPECIAL_SKILLS_BOX.x)+($SPECIAL_SKILLS_OFFSET.x)",
                        y: $"($SPECIAL_SKILLS_BOX.y)+($SPECIAL_SKILLS_OFFSET.y)+($SPECIAL_SKILLS_V_SPACE)*($it.index)-th/2",
                    }

                    [(equipment-or-skill-to-text $it.item $SPECIAL_SKILLS_FONT $pos).transform]
                }
                $box | append ($skills | flatten)
            }
        ),

        { kind: "drawbox",  options: { ...$weaponry.box, color: "black@0.5", t: "fill" } },
        { kind: "drawbox",  options: { ...$weaponry.box, color: "black@0.5", t: "5" } },
        (ffmpeg-text "WEAPONRY" $weaponry.title_pos $EQUIPMENT_TITLE_FONT),
        ...(equipment-to-text $weaponry),

        { kind: "drawbox",  options: { ...$equipment.box, color: "black@0.5", t: "fill" } },
        { kind: "drawbox",  options: { ...$equipment.box, color: "black@0.5", t: "5" } },
        (ffmpeg-text "EQUIPMENT" $equipment.title_pos $EQUIPMENT_TITLE_FONT),
        ...(equipment-to-text $equipment),

        { kind: "drawbox",  options: { ...$peripheral.box, color: "black@0.5", t: "fill" } },
        { kind: "drawbox",  options: { ...$peripheral.box, color: "black@0.5", t: "5" } },
        (ffmpeg-text "PERIPHERAL" $peripheral.title_pos $EQUIPMENT_TITLE_FONT),
        ...(equipment-to-text $peripheral),

        { kind: "drawbox",  options: { ...$MELEE_BOX, color: "black@0.5", t: "fill" } },
        { kind: "drawbox",  options: { ...$MELEE_BOX, color: "black@0.5", t: "5" } },
        (ffmpeg-text "MELEE WEAPONS" $MELEE_WEAPONS_TITLE_POS  $MELEE_WEAPONS_TITLE_FONT),
        (do {
            let text = $troop.melee_weapons | each { |it|
                match ($it | describe --detailed).type {
                    "string" => $it,
                    "record" => $"($it.name) \(($it.mod)\)",
                }
            } | str join ", "
            ffmpeg-text $text $MELEE_WEAPONS_POS $MELEE_WEAPONS_FONT
        }),

        { kind: "drawbox",  options: { ...$SWC_BOX, color: "black@0.5", t: "fill" } },
        { kind: "drawbox",  options: { ...$SWC_BOX, color: "black@0.5", t: "5" } },
        (ffmpeg-text "SWC"           $SWC_TITLE_POS  $SWC_TITLE_FONT),
        (ffmpeg-text $"($troop.SWC)" $SWC_POS        $SWC_FONT),

        { kind: "drawbox",  options: { ...$C_BOX, color: "black@0.5", t: "fill" } },
        { kind: "drawbox",  options: { ...$C_BOX, color: "black@0.5", t: "5" } },
        (ffmpeg-text "C"           $C_TITLE_POS  $C_TITLE_FONT),
        (ffmpeg-text $"($troop.C)" $C_POS        $C_FONT),
    ]

    let tmp = ffmpeg create ($BASE_IMAGE | ffmpeg options) --output (mktemp --tmpdir infinity-XXXXXXX.png)
        | [$in, ({ parent: $DIRS.minis, stem: $troop.asset, extension: "png" } | path join)]
            | ffmpeg combine ($MINI_OVERLAY | ffmpeg options) --output (mktemp --tmpdir infinity-XXXXXXX.png)
        | if $troop.faction != null {
            [$in, ({ parent: $DIRS.factions, stem: $troop.faction, extension: "png" } | path join)]
                | ffmpeg combine $"[1:v]format=rgba,colorchannelmixer=aa=0.5[ol];[0:v][ol]overlay=x=($FACTION_POS.x)-w/2:y=($FACTION_POS.y)-h/2" --output (mktemp --tmpdir infinity-XXXXXXX.png)
        } else {
            $in
        }
        | [$in, $qrcode] | ffmpeg combine ($QR_CODE_OVERLAY | ffmpeg options) --output (mktemp --tmpdir infinity-XXXXXXX.png)
        | ffmpeg mapply ($transforms | compact | each { ffmpeg options })

    let tmp = $troop.characteristics
        | enumerate
        | reduce --fold $tmp { |it, acc|
            [$acc, ({ parent: $DIRS.characteristics, stem: $it.item, extension: "png" } | path join)] | ffmpeg combine ({
                kind: "overlay",
                options: {
                    x: $"($characteristics_box.x + $characteristics_box.w // 2)-w/2",
                    y: $"($characteristics_box.y + $CHARACTERISTICS_IMAGE_SIZE)+($it.index * $CHARACTERISTICS_IMAGE_SIZE)-h/2",
                },
            } | ffmpeg options) --output (mktemp --tmpdir infinity-XXXXXXX.png)
        }
        | [$in, ({ parent: $DIRS.icons, stem: ($troop.asset | str replace --regex '\..*$' ''), extension: "png" } | path join) ] | ffmpeg combine ({
            kind: "overlay",
            options: { x: $"($ICON_BOX.x + $ICON_BOX.w // 2)-w/2", y: $"($ICON_BOX.y + $ICON_BOX.h // 2)-h/2" },
        } | ffmpeg options) --output (mktemp --tmpdir infinity-XXXXXXX.png)

    let tmp = $troop.allowed_factions
        | enumerate
        | reduce --fold $tmp { |it, acc|
            [$acc, ({ parent: $DIRS.allowed_factions, stem: $it.item, extension: "png" } | path join)] | ffmpeg combine ({
                kind: "overlay",
                options: {
                    x: $"($STAT_VALS_BOX.x)+($ALLOWED_FACTIONS_OFFSET.x)+($it.index * $ALLOWED_FACTIONS_IMAGE_SIZE)-w/2",
                    y: $"($STAT_VALS_BOX.y)+($STAT_VALS_BOX.h)+($ALLOWED_FACTIONS_OFFSET.y)-h/2",
                },
            } | ffmpeg options) --output (mktemp --tmpdir infinity-XXXXXXX.png)
        }

    let tmp = $tmp | put-version

    let out = $output | path parse | update stem { $in ++ ".1" } | path join
    cp $tmp $out
    log info $"\t(ansi purple)($out)(ansi reset)"
}

def fit-items-in-width [
    items: list<string>, h_space: int, --separator: string = ", "
]: [
    nothing -> list<list<string>>
] {
    generate { |var|
        let res = $var
            | skip 1
            | reduce --fold [$var.0] { |it, acc|
                $acc ++ [$"($acc | last)($separator)($it)"]
            }
            | where ($it | str length) <= $h_space
            | last
            | split row $separator

        let next = $var | skip ($res | length)

        if ($next | is-empty) {
            { out: $res }
        } else {
            { out: $res, next: $next }
        }
    } $items
}

def gen-charts-page [troop: record, output: path] {
    let charts = ls charts/weapons/*.csv | reduce --fold [] { |it, acc|
        $acc ++ (open $it.name)
    }
    let equipments = $troop.weaponry ++ $troop.equipment ++ $troop.peripheral ++ $troop.melee_weapons
        | each { |it|
            match ($it | describe --detailed).type {
                "string" => { name: $it },
                "record" => $it,
            } | update name { str replace "CCW" "CC Weapon" }
        }
        | insert stats { |var|
            let equipment = $charts | where NAME == ($var.name | str upcase)
            if ($equipment | length) == 0 {
                log error $"(ansi cyan)($var.name)(ansi reset) not found in charts"
            }
            $equipment | each { into record }
        }
        | flatten stats
        | update name { |it|
            if $it.stats.MODE == "" {
                $it.stats.NAME
            } else {
                $"($it.stats.NAME) \(($it.stats.MODE)\)"
            }
        }
        | upsert mod { |it|
            let res = $it.mod? | default "" | parse "{k}={v}" | into record
            if $res != {} {
                $res
            } else {
                let res = $it.mod? | default "" | parse --regex '^(?<x>[+-])(?<v>\d+)(?<k>.+)$' | into record
                if $res != {} {
                    $res
                } else {
                    if $it.mod? != null {
                        log error $"could not parse modifier '($it.mod)' of '($it.name)'"
                    }
                    null
                }
            }
        }
        | where not ($it.stats | is-empty)

    if ($equipments | is-empty) {
        log warning "\tno equipment"
        let res = ffmpeg create ($BASE_IMAGE | ffmpeg options) --output (mktemp --tmpdir infinity-XXXXXXX.png)
            | put-version
        let out = $output | path parse | update stem { $in ++ ".2" } | path join
        cp $res $out
        log info $"\t(ansi purple)($out)(ansi reset)"
        return
    }

    let offset = {
        x: ($CHART_START.x + $CHART_FONT_CHAR_SIZE * ($equipments.name | each { str length } | math max)),
        y: $CHART_START.y
    }

    let names_transforms = $equipments | enumerate | each {(
        ffmpeg-text $in.item.name
            { x: $"($offset.x)-($CHART_NAMES_OFFSET_X)-tw", y: $"($offset.y)+($CHART_OFFSET_Y)+($in.index * $CHART_V_SPACE)+25-th/2" }
            $CHART_FONT_B
    )}

    let traits = $equipments
        | where not ($it.stats.TRAITS | is-empty)
        | enumerate
        | each { |var|
            let h_space = ($CANVAS.w - $offset.x - $CHART_START.x - 20) / $CHART_FONT_CHAR_SIZE | into int
            let items = $var.item.stats.TRAITS | split row ", "
            let res = fit-items-in-width $items $h_space --separator ", "
            $res | each { str join ", " } | enumerate | each { |it|
                let name = if $it.index == 0 {
                    $var.item.name
                } else {
                    ""
                }
                let traits = if $it.index < ($res | length) - 1 {
                    $it.item ++ ","
                } else {
                    $it.item
                }
                { name: $name, traits: $traits }
            }
        }
        | flatten

    let traits_names_transforms = $traits
        | enumerate
        | each {(
            ffmpeg-text $in.item.name
                {
                    x: $"($offset.x)-($CHART_NAMES_OFFSET_X)-tw",
                    y: $"($offset.y)+($CHART_OFFSET_Y)+($CHART_V_SPACE)*($equipments | length)+($CHART_TRAITS_V_SPACE)+($in.index * $CHART_TRAITS_V_SPACE)",
                }
                $CHART_FONT_B
        )}
    let traits_values_transforms = $traits
        | enumerate
        | each {(
            ffmpeg-text $in.item.traits
                {
                    x: ($offset.x + $CHART_TRAITS_H_SPACE),
                    y: $"($offset.y)+($CHART_OFFSET_Y)+($CHART_V_SPACE)*($equipments | length)+($CHART_TRAITS_V_SPACE)+($in.index * $CHART_TRAITS_V_SPACE)",
                }
                $CHART_FONT_R
        )}

    let column_widths_values = $STATS.field
        | reduce --fold ($equipments | flatten | select ...$STATS.field) { |it, acc|
            $acc | update $it { into string | str length }
        }
        | math max
        | update TRAITS { "TRAITS" | str length }
        | transpose
        | transpose --header-row

    let column_widths_keys = $STATS | insert len { $in.short | str length } | reject short | transpose --header-row
    let column_widths = $column_widths_keys | append $column_widths_values| math max

    let weapon_bars = $equipments | enumerate | each { |var| {
        equipment: $var.item,
        x: $offset.x,
        y: ($offset.y + (if $var.index == 0 { 0 } else { $CHART_FONT_SIZE }) + ($var.index * $CHART_V_SPACE)),
    }}

    let res = ffmpeg create ($BASE_IMAGE | ffmpeg options) --output (mktemp --tmpdir infinity-XXXXXXX.png)
        | ffmpeg mapply ($names_transforms | each { ffmpeg options }) --output (mktemp --tmpdir infinity-XXXXXXX.png)
        | ffmpeg mapply ($traits_names_transforms | each { ffmpeg options }) --output (mktemp --tmpdir infinity-XXXXXXX.png)
        | ffmpeg mapply ($traits_values_transforms | each { ffmpeg options }) --output (mktemp --tmpdir infinity-XXXXXXX.png)

    let res = $weapon_bars
        | enumerate
        | insert item.no_header { $in.index > 0 }
        | get item
        | reduce --fold $res { |it, acc|
            $acc | put-weapon-chart $it.equipment $it.x $it.y $column_widths --no-header=$it.no_header
        }

    let res = $res | put-version

    let out = $output | path parse | update stem { $in ++ ".2" } | path join
    cp $res $out
    log info $"\t(ansi purple)($out)(ansi reset)"

}

# skills that do not modify stats directly but rather change the way the game is
# played
const UNSUPPORTED_SKILLS = [
    "NCO", "Booty", "Dodge", "Dogged", "Frenzy", "Hacker", "Sensor", "Courage",
    "Stealth", "Commlink", "Discover", "Immunity", "Mimetism", "No Cover",
    "Number 2", "Warhorse", "Impetuous", "Minelayer", "Paramedic", "Lieutenant",
    "Peripheral", "Super-Jump", "Combat Jump", "Parachutist", "Infiltration",
    "Marksmanship", "Climbing Plus", "Transmutation", "Combat Instinct",
    "Religious Troop", "Chain of Command", "Forward Observer",
    "Forward Deployment", "Natural Born Warrior", "Specialist Operative",
]

# skills that modify the stats directly
const SUPPORTED_SKILLS = [ "BS Attack", "CC Attack", "Martial Arts", "Terrain" ]

export def main [troop: record, --color: string, --output: path = "output.png", --stats, --charts] {
    let modifiers = $troop.special_skills | each { |skill|
        let skill = if ($skill | describe --detailed).type == "record" {
            $skill | default null mod | reject spec?
        } else {
            { name: $skill, mod: null }
        }

        if $skill.name in $SUPPORTED_SKILLS {
            $skill
        } else if $skill.name in $UNSUPPORTED_SKILLS {
            log debug $"skipping skill '($skill)'"
        } else {
            log warning $"skipping skill '($skill)'"
        }
    }
    | upsert mod { |it|
        let res = $it.mod? | default "" | parse "{k}={v}" | into record
        if $res != {} {
            $res
        } else {
            let res = $it.mod? | default "" | parse --regex '^(?<x>[+-])(?<v>\d+)(?<k>.*)$' | into record
            if $res != {} {
                if $res.k != "" {
                    log warning $"skipping modifier '($it.mod)' of skill '($it.name)'"
                } else {
                    $res
                }
            } else {
                let res = $it.mod? | default "" | parse --regex '^L(?<v>\d+)$' | into record
                if $res != {} {
                    $res | into int v
                } else {
                    if $it.mod? != null {
                        if $it.mod in [ "Total", "Zero-G" ] {
                            { v: $it.mod }
                        } else {
                            log error $"could not parse modifier '($it.mod)' of skill '($it.name)'"
                        }
                    }
                }
            }
        }
    }
    | where $it.mod != null

    match [$stats, $charts] {
        [true, true] | [false, false] => {
            gen-stat-page $troop $color $output $modifiers
            gen-charts-page $troop $output
        },
        [true, false] => {
            gen-stat-page $troop $color $output $modifiers
        },
        [false, true] => {
            gen-charts-page $troop $output
        },
    }
}
