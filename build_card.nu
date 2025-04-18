use ffmpeg.nu *
use log.nu [ "log info", "log warning" ]

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

const NAME_BOX = { x: 480, y: 80, w: (1560 - 480), h: (160 - 80) }
const NAME_OFFSET_X = 28
const NAME_POS = { x: $"($NAME_BOX.x)+($NAME_OFFSET_X)", y: $"($NAME_BOX.y)+($NAME_BOX.h / 2)-th/2" }
const NAME_FONT = { fontfile: $BOLD_FONT, fontcolor: "white", fontsize: 60 }

const ISC_POS = { x: ($NAME_BOX.x + $NAME_OFFSET_X), y: ($NAME_BOX.y - $NAME_OFFSET_X) }
const CLASSIFICATION_POS = { x: $"($NAME_BOX.x + $NAME_BOX.w - $NAME_OFFSET_X)-tw", y: $ISC_POS.y }
const ISC_FONT = { fontfile: $REGULAR_FONT, fontcolor: "black", fontsize: 30 }

const NAME_2_BOX = { x: 35, y: 780, w: (1560 - 35), h: (830 - 780) }
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

const ALLOWED_FACTIONS_OFFSET = { x: 50, y: 50 }
const ALLOWED_FACTIONS_IMAGE_SIZE = 70 + 10

const BOTTOM_FIRST_ROW_Y = 880
const BOTTOM_SECOND_ROW_Y = 925

const EQUIPMENT_BOX = { x: 35, y: 850, w: (690 - 35), h: (960 - 850) }
const EQUIPMENT_OFFSET_X = 10
const EQUIPMENT_TITLE_POS = { x: $"($EQUIPMENT_BOX.x)+($EQUIPMENT_OFFSET_X)", y: $"($BOTTOM_FIRST_ROW_Y)-th/2" }
const EQUIPMENT_POS = { x: $"($EQUIPMENT_BOX.x)+($EQUIPMENT_OFFSET_X)", y: $"($BOTTOM_SECOND_ROW_Y)-th/2" }
const EQUIPMENT_FONT_SIZE = 30
const EQUIPMENT_TITLE_FONT = { fontfile: $BOLD_FONT, fontcolor: "white", fontsize: ($EQUIPMENT_FONT_SIZE + 2) }
const EQUIPMENT_FONT = { fontfile: $REGULAR_FONT, fontcolor: "white", fontsize: ($EQUIPMENT_FONT_SIZE - 5) }

const MELEE_BOX = { x: 710, y: 850, w: (1335 - 710), h: (960 - 850) }
const MELEE_OFFSET_X = 10
const MELEE_WEAPONS_TITLE_POS = { x: $"($MELEE_BOX.x)+($MELEE_OFFSET_X)", y: $"($BOTTOM_FIRST_ROW_Y)-th/2" }
const MELEE_WEAPONS_POS = { x: $"($MELEE_BOX.x)+($MELEE_OFFSET_X)", y: $"($BOTTOM_SECOND_ROW_Y)-th/2" }
const MELEE_FONT_SIZE = 30
const MELEE_WEAPONS_TITLE_FONT  = { fontfile: $BOLD_FONT, fontcolor: "white", fontsize: ($MELEE_FONT_SIZE + 2) }
const MELEE_WEAPONS_FONT = { fontfile: $REGULAR_FONT, fontcolor: "white", fontsize: ($MELEE_FONT_SIZE - 5) }

const SWC_BOX = { x: 1355, y: 850, w: (1445 - 1355), h: (960 - 850) }
const SWC_TITLE_POS = { x: $"($SWC_BOX.x)+($SWC_BOX.w // 2)-tw/2", y: $"($BOTTOM_FIRST_ROW_Y)-th/2" }
const SWC_POS = { x: $"($SWC_BOX.x)+($SWC_BOX.w // 2)-tw/2", y: $"($BOTTOM_SECOND_ROW_Y)-th/2" }
const SWC_FONT_SIZE = 30
const SWC_TITLE_FONT = { fontfile: $BOLD_FONT, fontcolor: "white", fontsize: $SWC_FONT_SIZE }
const SWC_FONT = { fontfile: $BOLD_FONT, fontcolor: "white", fontsize: $SWC_FONT_SIZE }

const C_BOX = { x: 1460, y: 850, w: (1560 - 1460), h: (960 - 850) }
const C_TITLE_POS = { x: $"($C_BOX.x)+($C_BOX.w // 2)-tw/2", y: $"($BOTTOM_FIRST_ROW_Y)-th/2" }
const C_POS = { x: $"($C_BOX.x)+($C_BOX.w // 2)-tw/2", y: $"($BOTTOM_SECOND_ROW_Y)-th/2" }
const C_FONT_SIZE = 30
const C_TITLE_FONT = { fontfile: $REGULAR_FONT, fontcolor: "white", fontsize: $C_FONT_SIZE }
const C_FONT = { fontfile: $REGULAR_FONT, fontcolor: "white", fontsize: $C_FONT_SIZE }

const SPECIAL_SKILLS_BOX = { x: 1240, y: 350, w: (1560 - 1240), h: null }
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

const CHART_FONT_SIZE = 30
const CHART_FONT_CHAR_SIZE = 18
const CHART_OFFSET_Y = 30
const CHART_ATTR_INTERSPACE = 20
const CHART_RANGE_CELL_WIDTH = 100
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
                        x: $"($x + $CHART_RANGE_CELL_WIDTH / 2 + $in.index * $CHART_RANGE_CELL_WIDTH)-tw/2",
                        y: $y
                    }
                    ffmpeg-text $in.item $pos $CHART_FONT_B
                }
            }
        ),
        # range values
        ...($RANGES | enumerate | each { |it|
            let color = match ($equipment | get $it.item) {
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
                    x: ($x + $it.index * $CHART_RANGE_CELL_WIDTH),
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
                        x: $"($x + ($RANGES | length) * $CHART_RANGE_CELL_WIDTH + $in.item.1)-tw/2",
                        y: $y
                    }
                    ffmpeg-text $in.item.0.short $pos $CHART_FONT_B
                }
            }
        ),
        # stats values
        ...($STATS | zip $positions | enumerate | each { |it|
            let pos = {
                x: $"($x + ($RANGES | length) * $CHART_RANGE_CELL_WIDTH + $it.item.1)-tw/2",
                y: $"(if $no_header { $y } else { $y + $CHART_OFFSET_Y })+($CHART_RANGE_CELL_HEIGHT / 2)-th/2"
            }
            let text = if $it.item.0.field == "TRAITS" {
                if ($equipment | get $it.item.0.field | is-empty) {
                    ""
                } else {
                    "*"
                }
            } else {
                $"($equipment | get $it.item.0.field)"
            }
            ffmpeg-text $text $pos $CHART_FONT_R
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

    let characteristics_box = $CHARACTERISTICS_BOX | update h (
        $CHARACTERISTICS_BOX.w // 2 +  # because text is twice larger
        (if ($troop.characteristics | is-empty) { 0 } else { $CHARACTERISTICS_V_SPACE }) +
        $CHARACTERISTICS_IMAGE_SIZE * ($troop.characteristics | length)
    )
    let special_skills_box = $SPECIAL_SKILLS_BOX | update h (
        $SPECIAL_SKILLS_V_BASE + $SPECIAL_SKILLS_V_SPACE * (($troop.special_skills | length) - 1)
    )

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
            $troop.stats | transpose k v | enumerate | each { |it| [
                (ffmpeg-text $"($it.item.k)" { x: $"($STAT_KEYS_BOX.x)+($STAT_OFFSET_X)+($it.index)*($STAT_H_SPACE)-tw/2", y: $"($STAT_KEYS_BOX.y)+($STAT_KEYS_BOX.h / 2)-th/2" } $STAT_FONT),
                (ffmpeg-text $"($it.item.v)" { x: $"($STAT_VALS_BOX.x)+($STAT_OFFSET_X)+($it.index)*($STAT_H_SPACE)-tw/2", y: $"($STAT_VALS_BOX.y)+($STAT_VALS_BOX.h / 2)-th/2" } $STAT_FONT),
            ] } | flatten
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
                    let text = match ($it.item | describe --detailed).type {
                        "string" => $it.item,
                        "record" => $"($it.item.name) \(($it.item.mod)\)"
                    }
                    let pos = {
                        x: $"($SPECIAL_SKILLS_BOX.x)+($SPECIAL_SKILLS_OFFSET.x)",
                        y: $"($SPECIAL_SKILLS_BOX.y)+($SPECIAL_SKILLS_OFFSET.y)+($SPECIAL_SKILLS_V_SPACE)*($it.index)-th/2",
                    }

                    [(ffmpeg-text $text $pos $SPECIAL_SKILLS_FONT)]
                }
                $box | append ($skills | flatten)
            }
        ),

        { kind: "drawbox",  options: { ...$EQUIPMENT_BOX, color: "black@0.5", t: "fill" } },
        { kind: "drawbox",  options: { ...$EQUIPMENT_BOX, color: "black@0.5", t: "5" } },
        (ffmpeg-text "WEAPONRY | EQUIPMENT || PERIPHERAL" $EQUIPMENT_TITLE_POS  $EQUIPMENT_TITLE_FONT),
        (ffmpeg-text $equipment_text                      $EQUIPMENT_POS        $EQUIPMENT_FONT),

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

    let tmp = ffmpeg create ($BASE_IMAGE | ffmpeg options) --output (mktemp --tmpdir XXXXXXX.png)
        | [$in, ({ parent: $DIRS.minis, stem: $troop.asset, extension: "png" } | path join)]
            | ffmpeg combine ($MINI_OVERLAY | ffmpeg options) --output (mktemp --tmpdir XXXXXXX.png)
        | if $troop.faction != null {
            [$in, ({ parent: $DIRS.factions, stem: $troop.faction, extension: "png" } | path join)]
                | ffmpeg combine $"[1:v]format=rgba,colorchannelmixer=aa=0.5[ol];[0:v][ol]overlay=x=($FACTION_POS.x)-w/2:y=($FACTION_POS.y)h/2" --output (mktemp --tmpdir XXXXXXX.png)
        } else {
            $in
        }
        | ffmpeg mapply ($transforms | each { ffmpeg options })

    let tmp = $troop.characteristics
        | enumerate
        | reduce --fold $tmp { |it, acc|
            [$acc, ({ parent: $DIRS.characteristics, stem: $it.item, extension: "png" } | path join)] | ffmpeg combine ({
                kind: "overlay",
                options: {
                    x: $"($characteristics_box.x + $characteristics_box.w // 2)-w/2",
                    y: $"($characteristics_box.y + $CHARACTERISTICS_IMAGE_SIZE)+($it.index * $CHARACTERISTICS_IMAGE_SIZE)-h/2",
                },
            } | ffmpeg options) --output (mktemp --tmpdir XXXXXXX.png)
        }
        | [$in, ({ parent: $DIRS.icons, stem: ($troop.asset | str replace --regex '\..*$' ''), extension: "png" } | path join) ] | ffmpeg combine ({
            kind: "overlay",
            options: { x: $"($ICON_BOX.x + $ICON_BOX.w // 2)-w/2", y: $"($ICON_BOX.y + $ICON_BOX.h // 2)-h/2" },
        } | ffmpeg options) --output (mktemp --tmpdir XXXXXXX.png)

    let tmp = $troop.allowed_factions
        | enumerate
        | reduce --fold $tmp { |it, acc|
            [$acc, ({ parent: $DIRS.allowed_factions, stem: $it.item, extension: "png" } | path join)] | ffmpeg combine ({
                kind: "overlay",
                options: {
                    x: $"($STAT_VALS_BOX.x)+($ALLOWED_FACTIONS_OFFSET.x)+($it.index * $ALLOWED_FACTIONS_IMAGE_SIZE)-w/2",
                    y: $"($STAT_VALS_BOX.y)+($STAT_VALS_BOX.h)+($ALLOWED_FACTIONS_OFFSET.y)-h/2",
                },
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

    if ($equipments | is-empty) {
        log warning "\tno equipment"
        let res = ffmpeg create ($BASE_IMAGE | ffmpeg options) --output (mktemp --tmpdir XXXXXXX.png)
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
            let x_space = ($CANVAS.w - $offset.x - $CHART_START.x) / $CHART_FONT_CHAR_SIZE | into int
            let traits = $var.item.stats.TRAITS | split row ", "
            let res = generate { |var|
                let res = $var
                    | skip 1
                    | reduce --fold [$var.0] { |it, acc| $acc ++ [$"($acc | last), ($it)"] }
                    | where ($it | str length) <= $x_space
                    | last
                    | split row ", "

                let next = $var | skip ($res | length)

                if ($next | is-empty) {
                    { out: $res }
                } else {
                    { out: $res, next: $next }
                }
            } $traits
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
        equipment: $var.item.stats,
        x: $offset.x,
        y: ($offset.y + (if $var.index == 0 { 0 } else { $CHART_FONT_SIZE }) + ($var.index * $CHART_V_SPACE)),
    }}

    let res = ffmpeg create ($BASE_IMAGE | ffmpeg options) --output (mktemp --tmpdir XXXXXXX.png)
        | ffmpeg mapply ($names_transforms | each { ffmpeg options }) --output (mktemp --tmpdir XXXXXXX.png)
        | ffmpeg mapply ($traits_names_transforms | each { ffmpeg options }) --output (mktemp --tmpdir XXXXXXX.png)
        | ffmpeg mapply ($traits_values_transforms | each { ffmpeg options }) --output (mktemp --tmpdir XXXXXXX.png)

    let res = $weapon_bars
        | enumerate
        | insert item.no_header { $in.index > 0 }
        | get item
        | reduce --fold $res { |it, acc|
            $acc | put-weapon-chart $it.equipment $it.x $it.y $column_widths --no-header=$it.no_header
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
