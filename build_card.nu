use ffmpeg.nu *
use log.nu [ "log info", "log warning" ]

const BOLD_FONT = "./adwaita-fonts-48.2/mono/AdwaitaMono-Bold.ttf"
const REGULAR_FONT = "./adwaita-fonts-48.2/mono/AdwaitaMono-Regular.ttf"

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

def "ffmpeg-text" [text: string] {
    $text
        | str replace --all ":" "\\:"
        | str replace --all "," "\\,"
        | str replace --all "[" "\\["
        | str replace --all "]" "\\]"
        | $"'($in)'"
}

def put-weapon-chart [equipment: record, x: int, y: int, --no-header]: [ path -> path ] {
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
    let m = 20
    let w = 20
    let positions = $STATS | zip ($STATS | skip 1) | reduce --fold [($m + $w * ($STATS.0.short | str length) / 2)] { |it, acc|
        $acc | append (($acc | last) + $m + $w * (($it.0.short | str length) / 2 + ($it.1.short | str length) / 2))
    }

    let range_cell_width = 100
    let range_cell_height = 50

    let transforms = [
        ...(
            if $no_header {
                []
            } else {
                $RANGES | enumerate | each { |it| {
                    kind: "drawtext",
                    options: {
                        text: (ffmpeg-text $it.item),
                        fontfile: $BOLD_FONT, fontcolor: "black", fontsize: 30,
                        x: $"($x + $range_cell_width / 2 + $it.index * $range_cell_width)-tw/2", y: $y,
                    },
                }}
            }
        ),
        ...($RANGES | enumerate | each { |it|
            let color = match ($equipment | get $it.item) {
                "+3" | 3 | "3" => "0x76ac5d",
                "0" | 0 => "0x59b9d1",
                "-3" | -3 => "0xea9931",
                "-6" | -6 => "0xdc3e4c",
                "null" => "0x231f20",
                _ => "0xcdd5de",
            }

            { kind: "drawbox",  options: { x: ($x + $it.index * $range_cell_width), y: (if $no_header { $y } else { $y + 30 }), w: $range_cell_width, h: $range_cell_height, color: $color, t: "fill" } }
        }),
        ...(
            if $no_header {
                []
            } else {
                $STATS | zip $positions | enumerate | each { |it| {
                    kind: "drawtext",
                    options: {
                        text: (ffmpeg-text $it.item.0.short),
                        fontfile: $BOLD_FONT, fontcolor: "black", fontsize: 30,
                        x: $"($x + ($RANGES | length) * $range_cell_width + $it.item.1)-tw/2", y: $y,
                    },
                }}
            }
        ),
        ...($STATS | zip $positions | enumerate | each { |it|
            if $it.item.0.field == "TRAITS" {{
                kind: "drawtext",
                options: {
                    text: (ffmpeg-text (if ($equipment | get $it.item.0.field | is-empty) { "" } else { "*" })),
                    fontfile: $REGULAR_FONT, fontcolor: "black", fontsize: 30,
                    x: $"($x + ($RANGES | length) * $range_cell_width + $it.item.1)-tw/2", y: $"(if $no_header { $y } else { $y + 30 })+($range_cell_height / 2)-th/2",
                },
            }} else {{
                kind: "drawtext",
                options: {
                    text: (ffmpeg-text $"($equipment | get $it.item.0.field)"),
                    fontfile: $REGULAR_FONT, fontcolor: "black", fontsize: 30,
                    x: $"($x + ($RANGES | length) * $range_cell_width + $it.item.1)-tw/2", y: $"(if $no_header { $y } else { $y + 30 })+($range_cell_height / 2)-th/2",
                },
            }}
        }),
    ]

    $in | ffmpeg mapply ($transforms | each { ffmpeg options }) --output (mktemp --tmpdir XXXXXXX.png)
}

def gen-stat-page [troop: record, color: string, output: path] {
    let equipment_text = [$troop.weaponry, $troop.equipment, $troop.peripheral]
        | each { default [] }
        | each {
            each { |it|
                match ($it | describe --detailed).type {
                    "string" => $it,
                    "record" => $"($it.name) \(($it.mod)\)"
                }
            }
        }
        | each { if ($in | is-empty) { "_" } else { $in | str join "\\, " } }
        | $"($in.0) | ($in.1) || ($in.2)"

    let characteristics_box_h = $CHARACTERISTICS_BOX.w // 2 + (if ($troop.characteristics | is-empty) { 0 } else { 10 }) + 75 * ($troop.characteristics | length)
    let special_skills_box_h = 100 + 30 * (($troop.special_skills | length) - 1)

    let transforms = [
        { kind: "drawtext", options: { text: (ffmpeg-text $"ISC: ($troop.isc)"), fontfile: $REGULAR_FONT, fontcolor: "black", fontsize: $ISC_FONT_SIZE, x: $ISC_POS.x, y: $ISC_POS.y } },
        { kind: "drawtext", options: { text: (ffmpeg-text $troop.classification), fontfile: $REGULAR_FONT, fontcolor: "black", fontsize: $ISC_FONT_SIZE, x: $"($NAME_BOX.x)+($NAME_BOX.w)-($NAME_OFFSET_X)-tw", y: $ISC_POS.y } },

        { kind: "drawbox",  options: { x: $NAME_BOX.x, y: $NAME_BOX.y, w: $NAME_BOX.w, h: $NAME_BOX.h, color: $"($color)@1.0", t: "fill" } },
        { kind: "drawbox",  options: { x: $NAME_BOX.x, y: $NAME_BOX.y, w: $NAME_BOX.w, h: $NAME_BOX.h, color: "black@0.4", t: "5" } },
        { kind: "drawtext", options: { text: (ffmpeg-text $troop.name), fontfile: $BOLD_FONT, fontcolor: "white", fontsize: $NAME_FONT_SIZE, x: $"($NAME_BOX.x)+($NAME_OFFSET_X)", y: $"($NAME_BOX.y)+($NAME_BOX.h / 2)-th/2" } },

        { kind: "drawbox",  options: { x: $NAME_2_BOX.x, y: $NAME_2_BOX.y, w: $NAME_2_BOX.w, h: $NAME_2_BOX.h, color: $"($color)@1.0", t: "fill" } },
        { kind: "drawbox",  options: { x: $NAME_2_BOX.x, y: $NAME_2_BOX.y, w: $NAME_2_BOX.w, h: $NAME_2_BOX.h, color: "black@0.4", t: "5" } },
        { kind: "drawtext", options: { text: (ffmpeg-text $troop.short_name), fontfile: $REGULAR_FONT, fontcolor: "white", fontsize: $NAME_2_FONT_SIZE, x: $"($NAME_2_BOX.x)+($NAME_2_OFFSET_X)", y: $"($NAME_2_BOX.y)+($NAME_2_BOX.h / 2)-th/2" } },

        { kind: "drawbox",  options: { x: $ICON_BOX.x, y: $ICON_BOX.y, w: $ICON_BOX.w, h: $ICON_BOX.h, color: "black@0.5", t: "fill" } },
        { kind: "drawbox",  options: { x: $ICON_BOX.x, y: $ICON_BOX.y, w: $ICON_BOX.w, h: $ICON_BOX.h, color: "black@0.5", t: "5" } },

        { kind: "drawbox",  options: { x: $CHARACTERISTICS_BOX.x, y: $CHARACTERISTICS_BOX.y, w: $CHARACTERISTICS_BOX.w, h: $characteristics_box_h, color: "black@0.5", t: "fill" } },
        { kind: "drawbox",  options: { x: $CHARACTERISTICS_BOX.x, y: $CHARACTERISTICS_BOX.y, w: $CHARACTERISTICS_BOX.w, h: $characteristics_box_h, color: "black@0.5", t: "5" } },
        { kind: "drawtext", options: { text: (ffmpeg-text $troop.type), fontfile: $BOLD_FONT, fontcolor: "white", fontsize: $CHARACTERISTICS_TEXT_FONT_SIZE, x: $"($CHARACTERISTICS_TEXT_POS.x)-tw/2", y: $"($CHARACTERISTICS_TEXT_POS.y)-th/2" } },

        { kind: "drawbox",  options: { x: $STAT_KEYS_BOX.x, y: $STAT_KEYS_BOX.y, w: $STAT_KEYS_BOX.w, h: $STAT_KEYS_BOX.h, color: $"($color)@1.0", t: "fill" } },
        { kind: "drawbox",  options: { x: $STAT_KEYS_BOX.x, y: $STAT_KEYS_BOX.y, w: $STAT_KEYS_BOX.w, h: $STAT_KEYS_BOX.h, color: "black@0.4", t: "5" } },

        { kind: "drawbox",  options: { x: $STAT_VALS_BOX.x, y: $STAT_VALS_BOX.y, w: $STAT_VALS_BOX.w, h: $STAT_VALS_BOX.h, color: "black@0.5", t: "fill" } },
        { kind: "drawbox",  options: { x: $STAT_VALS_BOX.x, y: $STAT_VALS_BOX.y, w: $STAT_VALS_BOX.w, h: $STAT_VALS_BOX.h, color: "black@0.5", t: "5" } },

        ...(
            $troop.stats | transpose k v | enumerate | each { |it| [
                { kind: "drawtext", options: { text: (ffmpeg-text $"($it.item.k)"), fontfile: $REGULAR_FONT, fontcolor: "white", fontsize: $STAT_FONT_SIZE, x: $"($STAT_KEYS_BOX.x)+($STAT_OFFSET_X)+($it.index)*($STAT_DX)-tw/2", y: $"($STAT_KEYS_BOX.y)+($STAT_KEYS_BOX.h / 2)-th/2" } },
                { kind: "drawtext", options: { text: (ffmpeg-text $"($it.item.v)"), fontfile: $REGULAR_FONT, fontcolor: "white", fontsize: $STAT_FONT_SIZE, x: $"($STAT_VALS_BOX.x)+($STAT_OFFSET_X)+($it.index)*($STAT_DX)-tw/2", y: $"($STAT_VALS_BOX.y)+($STAT_VALS_BOX.h / 2)-th/2" } },
            ] } | flatten
        ),

        ...(
            if ($troop.special_skills | is-empty) {
                []
            } else {
                let box = [
                    { kind: "drawbox",  options: { x: $SPECIAL_SKILLS_BOX.x, y: $SPECIAL_SKILLS_BOX.y, w: $SPECIAL_SKILLS_BOX.w, h: $special_skills_box_h, color: "black@0.5", t: "fill" } },
                    { kind: "drawbox",  options: { x: $SPECIAL_SKILLS_BOX.x, y: $SPECIAL_SKILLS_BOX.y, w: $SPECIAL_SKILLS_BOX.w, h: $special_skills_box_h, color: "black@0.5", t: "5" } },
                    { kind: "drawtext", options: { text: (ffmpeg-text "Special skills"), fontfile: $BOLD_FONT, fontcolor: "white", fontsize: $SPECIAL_SKILLS_TITLE_FONT_SIZE, x: $"($SPECIAL_SKILLS_BOX.x)+($SPECIAL_SKILLS_OFFSET_X)", y: $"($SPECIAL_SKILLS_BOX.y)+30-th/2" } },
                ]
                let skills = $troop.special_skills | enumerate | each { |it|
                    let text = match ($it.item | describe --detailed).type {
                        "string" => $it.item,
                        "record" => $"($it.item.name) \(($it.item.mod)\)"
                    }
                    [
                        { kind: "drawtext", options: {
                            text: (ffmpeg-text $text),
                            fontfile: $REGULAR_FONT,
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
        { kind: "drawtext", options: { text: (ffmpeg-text "WEAPONRY | EQUIPMENT || PERIPHERAL"), fontfile: $BOLD_FONT, fontcolor: "white", fontsize: ($EQUIPMENT_FONT_SIZE + 2), x: $"($EQUIPMENT_BOX.x)+($EQUIPMENT_OFFSET_X)", y: $"($BOTTOM_FIRST_ROW_Y)-th/2" } },
        { kind: "drawtext", options: { text: (ffmpeg-text $equipment_text), fontfile: $REGULAR_FONT, fontcolor: "white", fontsize: ($EQUIPMENT_FONT_SIZE - 5), x: $"($EQUIPMENT_BOX.x)+($EQUIPMENT_OFFSET_X)", y: $"($BOTTOM_SECOND_ROW_Y)-th/2" } },

        { kind: "drawbox",  options: { x: $MELEE_BOX.x, y: $MELEE_BOX.y, w: $MELEE_BOX.w, h: $MELEE_BOX.h, color: "black@0.5", t: "fill" } },
        { kind: "drawbox",  options: { x: $MELEE_BOX.x, y: $MELEE_BOX.y, w: $MELEE_BOX.w, h: $MELEE_BOX.h, color: "black@0.5", t: "5" } },
        { kind: "drawtext", options: { text: (ffmpeg-text "MELEE WEAPONS"), fontfile: $BOLD_FONT, fontcolor: "white", fontsize: ($MELEE_FONT_SIZE + 2), x: $"($MELEE_BOX.x)+($MELEE_OFFSET_X)", y: $"($BOTTOM_FIRST_ROW_Y)-th/2" } },
        (do {
            let text = $troop.melee_weapons | each { |it|
                match ($it | describe --detailed).type {
                    "string" => $it,
                    "record" => $"($it.name) \(($it.mod)\)",
                }
            } | str join ", "
            { kind: "drawtext", options: { text: (ffmpeg-text $text), fontfile: $REGULAR_FONT, fontcolor: "white", fontsize: ($MELEE_FONT_SIZE - 5), x: $"($MELEE_BOX.x)+($MELEE_OFFSET_X)", y: $"($BOTTOM_SECOND_ROW_Y)-th/2" } }
        }),

        { kind: "drawbox",  options: { x: $SWC_BOX.x, y: $SWC_BOX.y, w: $SWC_BOX.w, h: $SWC_BOX.h, color: "black@0.5", t: "fill" } },
        { kind: "drawbox",  options: { x: $SWC_BOX.x, y: $SWC_BOX.y, w: $SWC_BOX.w, h: $SWC_BOX.h, color: "black@0.5", t: "5" } },
        { kind: "drawtext", options: { text: (ffmpeg-text "SWC"), fontfile: $BOLD_FONT, fontcolor: "white", fontsize: ($SWC_FONT_SIZE + 2), x: $"($SWC_BOX.x)+($SWC_BOX.w // 2)-tw/2", y: $"($BOTTOM_FIRST_ROW_Y)-th/2" } },
        { kind: "drawtext", options: { text: (ffmpeg-text $"($troop.SWC)"), fontfile: $REGULAR_FONT, fontcolor: "white", fontsize: $SWC_FONT_SIZE, x: $"($SWC_BOX.x)+($SWC_BOX.w // 2)-tw/2", y: $"($BOTTOM_SECOND_ROW_Y)-th/2" } },

        { kind: "drawbox",  options: { x: $C_BOX.x, y: $C_BOX.y, w: $C_BOX.w, h: $C_BOX.h, color: "black@0.5", t: "fill" } },
        { kind: "drawbox",  options: { x: $C_BOX.x, y: $C_BOX.y, w: $C_BOX.w, h: $C_BOX.h, color: "black@0.5", t: "5" } },
        { kind: "drawtext", options: { text: (ffmpeg-text "C"), fontfile: $BOLD_FONT, fontcolor: "white", fontsize: ($C_FONT_SIZE + 2), x: $"($C_BOX.x)+($C_BOX.w // 2)-tw/2", y: $"($BOTTOM_FIRST_ROW_Y)-th/2" } },
        { kind: "drawtext", options: { text: (ffmpeg-text $"($troop.C)"), fontfile: $REGULAR_FONT, fontcolor: "white", fontsize: $C_FONT_SIZE, x: $"($C_BOX.x)+($C_BOX.w // 2)-tw/2", y: $"($BOTTOM_SECOND_ROW_Y)-th/2" } },
    ]

    let tmp = ffmpeg create ($START | ffmpeg options) --output (mktemp --tmpdir XXXXXXX.png)
        | [$in, ({ parent: "./troops/assets/minis/", stem: $troop.asset, extension: "png" } | path join)] | ffmpeg combine ($IMAGE | ffmpeg options) --output (mktemp --tmpdir XXXXXXX.png)
        | if $troop.faction != null {
            [$in, ({ parent: "./troops/assets/factions/940/", stem: $troop.faction, extension: "png" } | path join)] | ffmpeg combine "[1:v]format=rgba,colorchannelmixer=aa=0.5[ol];[0:v][ol]overlay=x=1455-w/2:y=500-h/2" --output (mktemp --tmpdir XXXXXXX.png)
        } else {
            $in
        }
        | ffmpeg mapply ($transforms | each { ffmpeg options })

    let tmp = $troop.characteristics
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
        } | ffmpeg options) --output (mktemp --tmpdir XXXXXXX.png)

    let tmp = $troop.allowed_factions
        | enumerate
        | reduce --fold $tmp { |it, acc|
            [$acc, ({ parent: "./troops/assets/factions/70/", stem: $it.item, extension: "png" } | path join)] | ffmpeg combine ({
                kind: "overlay",
                options: { x: $"($STAT_VALS_BOX.x)+50+($it.index * 80)-w/2", y: $"($STAT_VALS_BOX.y)+($STAT_VALS_BOX.h)+50-h/2" },
            } | ffmpeg options) --output (mktemp --tmpdir XXXXXXX.png)
        }

    let out = $output | path parse | update stem { $in ++ ".1" } | path join
    cp $tmp $out
    log info $"\t(ansi purple)($out)(ansi reset)"
}

def gen-charts-page [troop: record, output: path] {
    let charts = [
        [name,             type];

        [cc-weapons,       cc],
        [pistols,          pistol],
        [rifles,           rifle],
        [uncategorized,    null],
        [grenades,         grenade],
        [submachine-guns,  submachine_gun],
        [shotguns,         shotgun],
        [red_furies,       red_fury],
        [rocket_launchers, rocket_launcher],
    ] | reduce --fold [] { |it, acc|
        $acc ++ (
            { parent: "charts/weapons", stem: $it.name, extension: "csv" } | path join | open $in | insert type $it.type
        )
    }
    let equipments = $troop.weaponry ++ $troop.equipment ++ $troop.peripheral ++ $troop.melee_weapons
        | each { |it|
            match ($it | describe --detailed).type {
                "string" => { name: $it },
                "record" => $it,
            }
        }
        | insert stats { |var|
            let equipment = $charts | where NAME == ($var.name | str upcase)
            if ($equipment | length) == 0 {
                log warning $"(ansi cyan)($var.name)(ansi reset) not found in charts"
            }
            $equipment | each { into record }
        }
        | where not ($it.stats | is-empty)
        | flatten stats

    let start_x = 250

    let names_transforms = $equipments | enumerate | each { |var| {
        kind: "drawtext",
        options: {
            text: (ffmpeg-text $var.item.name),
            x: $"($start_x)-10-tw", y: $"50+30+($var.index * 60)+25-th/2",
            fontfile: $REGULAR_FONT, fontcolor: "black", fontsize: 30,
        },
    }}

    let traits_transforms = $equipments
        | where not ($it.stats.TRAITS | is-empty)
        | enumerate
        | each { |var| {
            kind: "drawtext",
            options: {
                text: (ffmpeg-text $"($var.item.name)  ($var.item.stats.TRAITS)"),
                x: $"($start_x)-10", y: $"50+30+60*($equipments | length)+50+($var.index * 100)",
                fontfile: $REGULAR_FONT, fontcolor: "black", fontsize: 30,
            },
        }}

    let weapon_bars = $equipments | enumerate | each { |var| {
        equipment: $var.item.stats,
        x: $start_x,
        y: (50 + (if $var.index == 0 { 0 } else { 30 }) + ($var.index * 60)),
    }}

    let res = ffmpeg create ($START | ffmpeg options) --output (mktemp --tmpdir XXXXXXX.png)
        | ffmpeg mapply ($names_transforms | each { ffmpeg options }) --output (mktemp --tmpdir XXXXXXX.png)
        | ffmpeg mapply ($traits_transforms | each { ffmpeg options }) --output (mktemp --tmpdir XXXXXXX.png)

    let res = $weapon_bars
        | enumerate
        | insert item.no_header { $in.index > 0 }
        | get item
        | reduce --fold $res { |it, acc|
            $acc | put-weapon-chart $it.equipment $it.x $it.y --no-header=$it.no_header
        }

    let out = $output | path parse | update stem { $in ++ ".2" } | path join
    cp $res $out
    log info $"\t(ansi purple)($out)(ansi reset)"

}

export def main [troop: record, --color: string, --output: path = "output.png", --stats, --charts] {
    match [$stats, $charts] {
        [true, true] | [false, false] => {
            gen-stat-page $troop $color $output
            gen-charts-page $troop $output
        },
        [true, false] => {
            gen-stat-page $troop $color $output
        },
        [false, true] => {
            gen-charts-page $troop $output
        },
    }
}
