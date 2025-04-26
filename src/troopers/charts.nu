use common.nu [
    BOLD_FONT, REGULAR_FONT, BASE_IMAGE, CANVAS,
    put-version, ffmpeg-text, "parse modifier-from-skill"
]

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
const CHART_RANGE_CELL_WIDTH = 70
const CHART_RANGE_CELL_HEIGHT = 45
const CHART_START = { x: 560, y: 50 }
const CHART_NAMES_OFFSET_X = 10
const CHART_FONT_B = { fontfile: $BOLD_FONT,    fontcolor: "black", fontsize: $CHART_FONT_SIZE }
const CHART_FONT_R = { fontfile: $REGULAR_FONT, fontcolor: "black", fontsize: $CHART_FONT_SIZE }
const CHART_V_SPACE = 60
const CHART_TRAITS_V_SPACE = 50
const CHART_TRAITS_H_SPACE = 20

def put-weapon-chart [
    equipment: record,
    x: int,
    y: int,
    column_widths: record,
    --no-header,
    modifiers: table<name: string, mod: record>,
]: [ path -> path ] {
    let widths = $column_widths | values
    let positions = $widths
        | zip ($widths | skip 1)
        | reduce --fold [($CHART_ATTR_INTERSPACE / 2 + $CHART_FONT_CHAR_SIZE * $widths.0)] { |it, acc|
            $acc | append (($acc | last) + $CHART_ATTR_INTERSPACE + $CHART_FONT_CHAR_SIZE * ($it.0 + $it.1) / 2)
        }

    let modifiers = $modifiers | transpose --header-row | into record

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
                if ($equipment.stats | get $it.item.0.field | is-empty) {
                    ""
                } else {
                    "*"
                }
            } else {
                $"($equipment.stats | get $it.item.0.field)"
            }
            ffmpeg-text $text $pos $CHART_FONT_R
        }),
    ]

    $in | ffmpeg mapply ($transforms | each { ffmpeg options }) --output (mktemp --tmpdir infinity-XXXXXXX.png)
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

export def gen-charts-page [
    troop: record<
        isc: string,
        name: string,
        short_name: string,
        faction: string,
        allowed_factions: list<string>,
        asset: string,
        classification: string,
        reference: string,
        type: string,
        characteristics: list<string>,
        stats: record<
            MOV: string,
            CC: int,
            BS: int,
            PH: int,
            WIP: int,
            ARM: int,
            BTS: int,
            VITA: int,
            S: int,
            AVA: int,
        >,
        special_skills: list<any>,
        weaponry: list<any>,
        equipment: list<any>,
        peripheral: list<any>,
        melee_weapons: list<any>,
        SWC: number,
        C: int
    >,
    output: path,
    modifiers: table<name: string, mod: record>,
] {
    let charts = ls charts/weapons/*.csv | reduce --fold [] { |it, acc|
        $acc ++ (open $it.name)
    }

    let mods = $modifiers | transpose --header-row | into record
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
        | default null mod
        | upsert mod { |it| $it | reject stats | parse modifier-from-skill }
        | where not ($it.stats | is-empty)
        | update stats { |it|
            let stat = $it.stats
                | update AMMUNITION { |stat|
                    let skill = $mods."BS Attack"?
                    if $skill != null {
                        if $skill.k != "AMMO" {
                            log warning $"invalid key '($skill.k)' for skill '($skill)'"
                        } else if "CC" in $it.stats.TRAITS {
                            $stat.AMMUNITION
                        } else {
                            $"($stat.AMMUNITION)->($skill.v)"
                        }
                    } else {
                        $stat.AMMUNITION
                    }
                }
                | update B { |stat|
                    let skill = if "CC" in $it.stats.TRAITS {
                        $mods."CC Attack"?
                    } else {
                        $mods."BS Attack"?
                    }

                    if $skill != null and $skill.k == "B" {
                        let v = $skill.v | into int
                        match $skill.x? {
                            # NOTE: no "-" (see p.68 of the rulebook)
                             "+" => $"($stat.B)+($v)",
                            null => $"($stat.B)->($v)",
                        }
                    } else {
                        $stat.B
                    }
                }
                if $it.mod? != null {
                    let v = $it.mod.v | into int
                    match $it.mod.x? {
                        # NOTE: no "-" (see p.68 of the rulebook)
                         "+" => { $stat | update $it.mod.k { $"($in)+($v)" } },
                        null => { $stat | update $it.mod.k { $"($in)->($v)" } },
                    }
                } else {
                    $stat
                }
        }

    if ($equipments | is-empty) {
        log warning "\tno equipment"
        let res = ffmpeg create ($BASE_IMAGE | ffmpeg options) --output (mktemp --tmpdir infinity-XXXXXXX.png)
            | put-version
        let out = $output | path parse | update stem { $in ++ ".2" } | path join
        cp $res $out
        log info $"\t(ansi purple)($out)(ansi reset)"
        return
    }

    let offset = $CHART_START

    let names_transforms = $equipments | enumerate | each {(
        ffmpeg-text $in.item.name
            { x: $"($offset.x)-($CHART_NAMES_OFFSET_X)-tw", y: $"($offset.y)+($CHART_OFFSET_Y)+($in.index * $CHART_V_SPACE)+25-th/2" }
            $CHART_FONT_B
    )}

    let traits = $equipments
        | where not ($it.stats.TRAITS | is-empty)
        | enumerate
        | each { |var|
            let h_space = ($CANVAS.w - $offset.x - 20) / $CHART_FONT_CHAR_SIZE | into int
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
            $acc | put-weapon-chart $it.equipment $it.x $it.y $column_widths $modifiers --no-header=$it.no_header
        }

    let res = $res | put-version

    let out = $output | path parse | update stem { $in ++ ".2" } | path join
    cp $res $out
    log info $"\t(ansi purple)($out)(ansi reset)"
}
