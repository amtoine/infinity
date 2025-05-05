use ../common.nu [
    BOLD_FONT, REGULAR_FONT, BASE_IMAGE, CANVAS, CORVUS_BELLI_COLORS,
    put-version, ffmpeg-text, "parse modifier-from-skill"
]
use ../ffmpeg.nu [ "ffmpeg metadata" ]

use ../skills-and-equipments.nu [ "generate-equipment-or-skill-card" ]

const RANGES = ['8"', '16"', '24"', '32"', '40"', '48"', '96"']
const STATS = [
    [field,                    short,  x   ];
    [PS,                       PS,     750 ],
    [B,                        B,      805 ],
    [AMMUNITION,               AMMO,   905 ],
    ["SAVING ROLL ATTRIBUTE",  ATTR,   1060],
    ["NUMBER OF SAVING ROLLS", SR,     1200],
]

const CHART_RANGE_CELL_WIDTH = 50

const FONT = { fontfile: $REGULAR_FONT, fontcolor: "black", fontsize: 22 }
const HEADER_FONT = { fontfile: $BOLD_FONT, fontcolor: "white", fontsize: 25 }
const RANGES_FONT = { fontfile: $BOLD_FONT, fontcolor: "white", fontsize: ($HEADER_FONT.fontsize * 0.7) }

const SKILL_CARD_MARGIN = 8
const SKILL_START = { x: 10, y: 10 }

const V_SPACE = 20

const HEADER_MAX_CHARS = 10
const NAME_MAX_CHARS = 25
const TRAITS_MAX_CHARS = 27

const NAME_X = 95 + 20
const RANGE_X = $NAME_X + $FONT.fontsize * ($NAME_MAX_CHARS * 0.33)
const TRAITS_X = $CANVAS.w - 165 - 20

const START_Y = 35

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

def put-weapons-charts [equipments: table<name: string, stats: record>]: [
    nothing -> record<y: int, ts: table<kind: string, options: record>>
] {
    let header_transforms = [
        { field: "NAME", x: $NAME_X },
        { field: "RANGE", x: ($RANGE_X + ($RANGES | length) / 2 * $CHART_RANGE_CELL_WIDTH) },
        ...($STATS | select field x),
        { field: "TRAITS", x: $TRAITS_X },
    ] | each { |h|
        # FIXME: no idea why this is IO call is required...
        print --no-newline ""
        let header_lines = fit-items-in-width ($h.field | split row " ") $HEADER_MAX_CHARS --separator " "
            | each { str join " " }

        $header_lines | enumerate | each { |l|
            ffmpeg-text $l.item {
                x: $"($h.x)-tw/2",
                y: $"($START_Y)+((3 - ($header_lines | length)) / 2 * $HEADER_FONT.fontsize)+($l.index * $HEADER_FONT.fontsize)-th/2"
            } $HEADER_FONT
        }
    }
    | flatten
    const HEADERS_BACKGROUND = {
        kind: "drawbox",
        options: {
            x: 0,
            y: $"($START_Y)+($HEADER_FONT.fontsize)-h/2",
            w: $CANVAS.w,
            h: (3 * $HEADER_FONT.fontsize + 20),
            color: "0x333333",
            t: "fill",
        },
    }

    const RANGES_Y = $START_Y + $HEADER_FONT.fontsize + $HEADERS_BACKGROUND.options.h / 2 + ($RANGES_FONT.fontsize + 20) / 2 + 10
    let ranges_transforms = $RANGES | enumerate | each { |r|
        ffmpeg-text $r.item {
            x: $"($RANGE_X + $CHART_RANGE_CELL_WIDTH / 2 + $r.index * $CHART_RANGE_CELL_WIDTH)-tw/2",
            y: $"($RANGES_Y)-th/2",
        } $RANGES_FONT
    }
    const RANGES_BACKGROUND = {
        kind: "drawbox",
        options: {
            x: 0,
            y: $"($RANGES_Y)-h/2",
            w: $CANVAS.w,
            h: ($RANGES_FONT.fontsize + 20),
            color: "0x555555",
            t: "fill",
        },
    }

    let transforms = $equipments | enumerate | reduce --fold {
        y: ($RANGES_Y + $RANGES_BACKGROUND.options.h),
        last_y: ($RANGES_Y + $RANGES_BACKGROUND.options.h // 2),
        ts: [],
    } { |eq, acc|
        # FIXME: no idea why this is IO call is required...
        print --no-newline ""

        let name = fit-items-in-width ($eq.item.name | split row " ") $NAME_MAX_CHARS --separator " "
            | each { str join " " }
        let traits = fit-items-in-width ($eq.item.stats.traits | split row " ") $TRAITS_MAX_CHARS --separator " "
            | each { str join " " }

        let y = if ($name | length) == ($traits | length) {
            { name: $acc.y, traits: $acc.y }
        } else if ($name | length) > ($traits | length) {
            let d = ($name | length) - ($traits | length)
            { name: $acc.y, traits: ($acc.y + $d / 2 * $FONT.fontsize) }
        } else {
            let d = ($traits | length) - ($name | length)
            { name: ($acc.y + $d / 2 * $FONT.fontsize), traits: $acc.y }
        }

        let name_lines = $name | enumerate | each { |t|
            ffmpeg-text $t.item { x: $"($NAME_X)-tw/2", y: $"($y.name)+($t.index * $FONT.fontsize)-th/2" } $FONT
        }
        let trait_lines = $traits | enumerate | each { |t|
            ffmpeg-text $t.item { x: $"($TRAITS_X)-tw/2", y: $"($y.traits)+($t.index * $FONT.fontsize)-th/2" } $FONT
        }

        let range_y = $y.name + (($name | length) - 1) / 2 * $FONT.fontsize
        let range_h = ([($name | length), ($traits | length)] | math max) * $FONT.fontsize + $V_SPACE * 0.75

        let background = {
            kind: "drawbox",
            options: {
                x: 0,
                y: $"($range_y)-h/2",
                w: $CANVAS.w,
                h: $range_h,
                color: (if ($eq.index mod 2) == 0 { "0xd0d0d0" } else { "0xc2c2c2" }),
                t: "fill",
            },
        }

        let ranges_boxes = $RANGES | enumerate | each { |it|
            let color = match ($eq.item.stats | get $it.item) {
                "+6" | 6 | "6" => $CORVUS_BELLI_COLORS.purple,
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
                    x: ($RANGE_X + $it.index * $CHART_RANGE_CELL_WIDTH),
                    y: $"($range_y)-h/2",
                    w: $CHART_RANGE_CELL_WIDTH,
                    h: $range_h,
                    color: $color, t: "fill",
                },
            }
        }

        let stats_boxes = $STATS | each { |s|
            let pos = {
                x: $"($s.x)-tw/2",
                y: $"($range_y)-th/2",
            }
            let text = $"($eq.item.stats | get $s.field)"
            ffmpeg-text $text $pos $FONT
        }

        {
            y: ($acc.y + $V_SPACE + ([($name | length), ($traits | length)] | math max) * $FONT.fontsize),
            last_y: ($range_y + $range_h // 2),
            ts: ($acc.ts ++ [$background] ++ $name_lines ++ $ranges_boxes ++ $stats_boxes ++ $trait_lines),
        }
    }

    {
        y: $transforms.last_y,
        ts: ([$HEADERS_BACKGROUND] ++ $header_transforms ++ [$RANGES_BACKGROUND] ++ $ranges_transforms ++ $transforms.ts),
    }
}

const COMMON_SKILLS = [
    "ALERT!",
    "BS ATTACK",
    "CAUTIOUS MOVEMENT",
    "CC ATTACK",
    "CLIMB",
    "DISCOVER",
    "DODGE",
    "IDLE",
    "INTUITIVE ATTACK",
    "JUMP",
    "MOVE",
    "LOOK OUT!",
    "PLACE DEPLOYABLE",
    "RELOAD",
    "REQUEST SPEEDBALL",
    "RESET",
    "SPECULATIVE ATTACK",
    "SUPPRESSIVE FIRE",
]

export def gen-charts-page [
    troop: record<
        isc: string,
        name: string,
        short_name: string,
        faction: any, # string or null
        allowed_factions: list<string>,
        asset: string,
        classification: string,
        reference: string,
        type: string,
        characteristics: list<string>,
        stats: record,
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
    let skills = try { ls skills/*.nuon } | default [] | each { open $in.name }
    let equipments = try { ls equipments/*.nuon } | default [] | each { open $in.name }

    # NOTE: this is required because of signature issues in Nushell
    let mods = $modifiers | transpose --header-row | into record

    let weapons_or_equipments = $troop.weaponry ++ $troop.equipment ++ $troop.peripheral ++ $troop.melee_weapons
        | each { |it|
            match ($it | describe --detailed).type {
                "string" => { name: $it },
                "record" => $it,
            } | update name { str replace "CCW" "CC Weapon" }
        }
        | insert stats { |var|
            let name = $var.name | str upcase
            let equipment = $charts | where NAME == $name
            if ($equipment | length) == 0 {
                let name = match $var.name {
                    "Multispectral Visor" => { $"($name) ($var.mod | str replace 'L' 'LEVEL ')" | str upcase },
                    _ => $name,
                }

                let e = $equipments | where NAME == $name | into record
                if $e == {} {
                    log error $"(ansi cyan)($var.name)(ansi reset) not found"
                } else {
                    [ ($e | insert __type "EQUIPMENT" | update name $name) ]
                }
            } else {
                $equipment | each { into record } | insert __type "WEAPON"
            }
        }
        | flatten stats
        | update stats { |it| # NOTE: i hate Nuhsell
            if $it.stats.stats? == null {
                $it.stats
            } else {
                $it.stats.stats
            }
        }
        | where not ($it.stats | is-empty)
        | update name { |it|
            if $it.stats.__type == "EQUIPMENT" { return $it.stats.name }

            if $it.stats.MODE? == null {
                $it.name
            } else if $it.stats.MODE == "" {
                $it.stats.NAME
            } else {
                $"($it.stats.NAME) \(($it.stats.MODE)\)"
            }
        }
        | default null mod
        | upsert mod { |it| $it | select name mod | parse modifier-from-skill }
        | update stats { |it|
            if $it.stats.__type == "EQUIPMENT" { return $it.stats }

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

    if ($weapons_or_equipments | is-empty) {
        log warning "\tno equipment"
    }

    let weapons = $weapons_or_equipments | where stats.__type == "WEAPON"
    let equipments = $weapons_or_equipments | where stats.__type == "EQUIPMENT" | flatten stats
    let skills = $troop.special_skills
        | each { |it|
            match ($it | describe --detailed).type {
                "string" => { name: $it },
                "record" => $it,
            }
        }
        | insert stats { |ss|
            let name = $ss.name | str upcase

            if $name in $COMMON_SKILLS {
                log debug $"skipping common skill (ansi cyan)($ss.name)(ansi reset)"
            } else {
                let name = match $ss.name {
                    "Martial Arts" => { $"($name) ($ss.mod | str replace 'L' 'LEVEL ')" | str upcase },
                    _ => $name,
                }
                let s = $skills | where NAME == $name | into record
                if $s == {} {
                    log error $"(ansi cyan)($ss.name)(ansi reset) not found in skills"
                } else {
                    $s
                }
            }
        }
        | where $it.stats != null
        | flatten stats

    let weapons_transforms = put-weapons-charts $weapons

    let equipments_and_skills_transforms = $skills ++ $equipments
        | each { |it|
            # FIXME: no idea why this is IO call is required...
            print --no-newline ""
            let skill_card = generate-equipment-or-skill-card $it
            let res = {
                asset: $skill_card.asset,
                transform: {
                    kind: "overlay",
                    options: {
                        x: ($SKILL_START.x + $it.pos.c * (390 + $SKILL_CARD_MARGIN)),
                        y: ($SKILL_START.y + ($weapons_transforms.y | into int) + $it.pos.y),
                    },
                },
            }

            let shape = $res.asset | ffmpeg metadata | get streams | select width height

            if $res.transform.options.x > $CANVAS.w or $res.transform.options.y > $CANVAS.h {
                log warning $"'($it.name)' outside for '($troop.name)'"
            } else if (
                $res.transform.options.x + $shape.width > $CANVAS.w
                or
                $res.transform.options.y + $shape.height > $CANVAS.h
            ) {
                log warning $"'($it.name)' partially outside for '($troop.name)'"
            }

            $res
        }

    let res = ffmpeg create ($BASE_IMAGE | ffmpeg options) --output (mktemp --tmpdir infinity-XXXXXXX.png)
        | ffmpeg mapply ($weapons_transforms.ts | each { ffmpeg options }) --output (mktemp --tmpdir infinity-XXXXXXX.png)

    let res = $equipments_and_skills_transforms
        | reduce --fold $res { |it, acc|
            [$acc, $it.asset] | ffmpeg combine ($it.transform | ffmpeg options) --output (mktemp --tmpdir infinity-XXXXXXX.png)
        }
        | put-version

    let out = $output | path parse | update stem { $in ++ ".2" } | path join
    cp $res $out
    log info $"\t(ansi purple)($out)(ansi reset)"
}
