use ../common.nu [
    BOLD_FONT, REGULAR_FONT, BASE_COLOR, CORVUS_BELLI_COLORS, TEXT_ALIGNMENT,
    put-version, ffmpeg-text, "parse modifier-from-skill", fit-items-in-width,
]
use ../ffmpeg.nu [ "ffmpeg metadata" ]

def get-options [options: record] {
    let box = $options.margins.left | {
        x: $in,
        y: $options.margins.top,
        w: ($options.margins.right - $in),
        h: (55 * $options.scale.y),
    }

    let header_max_chars = 10
    let name_max_chars = 25
    let traits_max_chars = 27

    let normal_fontsize = 22 * $options.scale.x
    let header_fontsize = 25 * $options.scale.y
    let ranges_fontsize = $header_fontsize * 0.7

    let name_x = (140 + 20) * $options.scale.x

    let start_y = $box.y + $box.h + $options.margins.top
    let headers_background_h = 3 * $header_fontsize + 20 * $options.scale.y
    let ranges_y = (
        $start_y +
        $header_fontsize +
        $headers_background_h / 2 +
        ($ranges_fontsize + 20 * $options.scale.y) / 2 +
        10 * $options.scale.y
    )

    {
        base_image: {
            kind: "color",
            options: {
                c: $BASE_COLOR,
                s: $"($options.canvas.w)x($options.canvas.h)",
                d: 1,
            },
        },
        name: {
            box: $box,
            text: {
                pos: {
                    x: ($box.x + 28 * $options.scale.x),
                    y: ($box.y + $box.h / 2),
                    alignment: $TEXT_ALIGNMENT.left,
                },
                font: {
                    fontfile: $BOLD_FONT,
                    fontcolor: "white",
                    fontsize: (45 * $options.scale.x),
                },
            }
            max_chars: $name_max_chars,
            x: $name_x,
        },
        v_space: (20 * $options.scale.y),
        box_border: (5 * $options.scale.x),
        fonts: {
            normal: { fontfile: $REGULAR_FONT, fontcolor: "black", fontsize: $normal_fontsize },
            header: { fontfile: $BOLD_FONT,    fontcolor: "white", fontsize: $header_fontsize },
            ranges: { fontfile: $BOLD_FONT,    fontcolor: "white", fontsize: $ranges_fontsize },
        },
        ranges: {
            cell_width: (50 * $options.scale.x),
            labels: ['8"', '16"', '24"', '32"', '40"', '48"', '96"'],
            pos: {
                x: ($name_x + ($normal_fontsize * 0.33) * $name_max_chars),
                y: $ranges_y,
            }
            background: {
                kind: "drawbox",
                options: {
                    x: 0,
                    y: $"($ranges_y)-h/2",
                    w: $options.canvas.w,
                    h: ($ranges_fontsize + 20 * $options.scale.y),
                    color: "0x555555",
                    t: "fill",
                },
            },
        },
        headers: {
            labels: [
                [field,                    short,  x                        ];
                [PS,                       PS,     (750  * $options.scale.x)],
                [B,                        B,      (805  * $options.scale.x)],
                [AMMUNITION,               AMMO,   (905  * $options.scale.x)],
                ["SAVING ROLL ATTRIBUTE",  ATTR,   (1060 * $options.scale.x)],
                ["NUMBER OF SAVING ROLLS", SR,     (1200 * $options.scale.x)],
            ],
            background: {
                kind: "drawbox",
                options: {
                    x: 0,
                    y: $"($start_y + $header_fontsize)-h/2",
                    w: $options.canvas.w,
                    h: $headers_background_h,
                    color: "0x333333",
                    t: "fill",
                },
            },
            max_chars: $header_max_chars,
        },
        traits: {
            x: ($options.canvas.w - (165 + 20) * $options.scale.x),
            max_chars: $traits_max_chars,
        },
        start_y: ($box.y + $box.h + $options.margins.top),
    }
}

def put-weapons-charts [equipments: table<name: string, stats: record>, options: record]: [
    nothing -> record<y: int, ts: table<kind: string, options: record>>
] {
    let header_transforms = [
        { field: "NAME", x: $options.name.x },
        { field: "RANGE", x: ($options.ranges.pos.x + ($options.ranges.labels | length) / 2 * $options.ranges.cell_width) },
        ...($options.headers.labels | select field x),
        { field: "TRAITS", x: $options.traits.x },
    ] | each { |h|
        # FIXME: no idea why this is IO call is required...
        print --no-newline ""
        let header_lines = fit-items-in-width ($h.field | split row " ") $options.headers.max_chars --separator " "
            | each { str join " " }

        $header_lines | enumerate | each { |l|
            ffmpeg-text $l.item {
                x: $h.x,
                y: (
                    $options.start_y +
                    (3 - ($header_lines | length)) / 2 * $options.fonts.header.fontsize +
                    $l.index * $options.fonts.header.fontsize
                ),
                alignment: $TEXT_ALIGNMENT.center,
            } $options.fonts.header
        }
    }
    | flatten
    let ranges_transforms = $options.ranges.labels | enumerate | each { |r|
        ffmpeg-text $r.item {
            x: (
                $options.ranges.pos.x +
                $options.ranges.cell_width / 2 +
                $r.index * $options.ranges.cell_width
            ),
            y: $options.ranges.pos.y,
            alignment: $TEXT_ALIGNMENT.center,
        } $options.fonts.ranges
    }

    let transforms = $equipments | enumerate | reduce --fold {
        y: ($options.ranges.pos.y + $options.ranges.background.options.h),
        last_y: ($options.ranges.pos.y + $options.ranges.background.options.h // 2),
        ts: [],
    } { |eq, acc|
        # FIXME: no idea why this is IO call is required...
        print --no-newline ""

        let name = fit-items-in-width ($eq.item.name | split row " ") $options.name.max_chars --separator " "
            | each { str join " " }
        let traits = fit-items-in-width ($eq.item.stats.traits | split row " ") $options.traits.max_chars --separator " "
            | each { str join " " }

        let y = if ($name | length) == ($traits | length) {
            { name: $acc.y, traits: $acc.y }
        } else if ($name | length) > ($traits | length) {
            let d = ($name | length) - ($traits | length)
            { name: $acc.y, traits: ($acc.y + $d / 2 * $options.fonts.normal.fontsize) }
        } else {
            let d = ($traits | length) - ($name | length)
            { name: ($acc.y + $d / 2 * $options.fonts.normal.fontsize), traits: $acc.y }
        }

        let name_lines = $name | enumerate | each { |t|
            ffmpeg-text $t.item {
                x: $options.name.x,
                y: ($y.name + $t.index * $options.fonts.normal.fontsize),
                alignment: $TEXT_ALIGNMENT.center,
            } $options.fonts.normal
        }
        let trait_lines = $traits | enumerate | each { |t|
            ffmpeg-text $t.item {
                x: $options.traits.x,
                y: ($y.traits + $t.index * $options.fonts.normal.fontsize),
                alignment: $TEXT_ALIGNMENT.center,
            } $options.fonts.normal
        }

        let range_y = $y.name + (($name | length) - 1) / 2 * $options.fonts.normal.fontsize
        let range_h = ([($name | length), ($traits | length)] | math max) * $options.fonts.normal.fontsize + $options.v_space * 0.75

        let background = {
            kind: "drawbox",
            options: {
                x: 0,
                y: $"($range_y)-h/2",
                w: $options.canvas.w,
                h: $range_h,
                color: (if ($eq.index mod 2) == 0 { "0xd0d0d0" } else { "0xc2c2c2" }),
                t: "fill",
            },
        }

        let ranges_boxes = $options.ranges.labels | enumerate | each { |it|
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
                    x: ($options.ranges.pos.x + $it.index * $options.ranges.cell_width),
                    y: $"($range_y)-h/2",
                    w: $options.ranges.cell_width,
                    h: $range_h,
                    color: $color, t: "fill",
                },
            }
        }

        let stats_boxes = $options.headers.labels | each { |s|
            let pos = {
                x: $s.x,
                y: $range_y,
                alignment: $TEXT_ALIGNMENT.center,
            }
            let text = $"($eq.item.stats | get $s.field)"
            ffmpeg-text $text $pos $options.fonts.normal
        }

        {
            y: (
                $acc.y +
                $options.v_space +
                ([($name | length), ($traits | length)] | math max) * $options.fonts.normal.fontsize
            ),
            last_y: ($range_y + $range_h // 2),
            ts: (
                $acc.ts ++
                [$background] ++
                $name_lines ++
                $ranges_boxes ++
                $stats_boxes ++
                $trait_lines
            ),
        }
    }

    {
        y: $transforms.last_y,
        ts: (
            [$options.headers.background] ++
            $header_transforms ++
            [$options.ranges.background] ++
            $ranges_transforms ++
            $transforms.ts
        ),
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
    color: string,
    output: path,
    modifiers: table<name: string, mod: record>,
    options: record,
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

    let version = $options.version
    let options = $options | merge (get-options $options)

    let weapons_transforms = put-weapons-charts $weapons $options

    let name_box_transforms = [
        { kind: "drawbox",  options: { ...$options.name.box, color: $"($color)@1.0", t: "fill" } },
        { kind: "drawbox",  options: { ...$options.name.box, color: "black@0.4",     t: $"($options.box_border)" } },
        (ffmpeg-text $troop.short_name $options.name.text.pos $options.name.text.font),
    ]

    let res = ffmpeg create ($options.base_image | ffmpeg options) --output (mktemp --tmpdir infinity-XXXXXXX.png)
        | ffmpeg mapply ($weapons_transforms.ts | each { ffmpeg options }) --output (mktemp --tmpdir infinity-XXXXXXX.png)
        | ffmpeg mapply ($name_box_transforms | each { ffmpeg options }) --output (mktemp --tmpdir infinity-XXXXXXX.png)
        | put-version $troop $version

    let out = $output | path parse | update stem { $in ++ ".2" } | path join
    cp $res $out
    log info $"\t(ansi purple)($out)(ansi reset)"
}
