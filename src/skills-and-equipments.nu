use common.nu [
    BOLD_FONT, REGULAR_FONT, BASE_IMAGE, CANVAS, CORVUS_BELLI_COLORS,
    put-version, ffmpeg-text, "parse modifier-from-skill", fit-items-in-width,
]

const CACHE =  "~/.cache/infinity/" | path expand

const SKILL_FONT = { fontfile: $REGULAR_FONT, fontcolor: "black", fontsize: 10 }
const SKILL_BOLD_FONT = { fontfile: $BOLD_FONT, fontcolor: "white", fontsize: 20 }
const SKILL_TYPE_FONT = { fontfile: $BOLD_FONT, fontcolor: "white", fontsize: 18 }

const SKILL_MARGIN = 20
const SKILL_BORDER = 5

export def generate-equipment-or-skill-card [equipment_or_skill: record]: [
    nothing -> record<asset: path, width: int>
]  {
    let eq_or_s = if ($equipment_or_skill.effects | describe --detailed).type == "record" {
        if $equipment_or_skill.mod? == null {
            $equipment_or_skill
                | update effects { items { |k, v| $"($k): ($v | str join ' ')" } }
        } else {
            $equipment_or_skill
                | update name { |it| $"($it.name) \(($it.mod)\)" }
                | update effects {
                    if $equipment_or_skill.mod in $in {
                        $in | get $equipment_or_skill.mod
                    } else {
                        $in.Trait
                    }
                }
        }
    } else {
        $equipment_or_skill
    }

    # the charts page is 4 cells wide, i.e. the width of
    # each skill card allows to fit exactly 4 of them horizontally
    let skill_max_chars = 60 * $eq_or_s.pos.w + (6 * ($eq_or_s.pos.w - 1))
    let skill_width = (
        $skill_max_chars * $SKILL_FONT.fontsize * 6 // 10 +
        20 +
        2 * $SKILL_BORDER +
        2 * ($eq_or_s.pos.w - 1)
    )

    let hash = [
        ($eq_or_s | to nuon),
        $SKILL_FONT,
        $SKILL_BOLD_FONT,
        $SKILL_TYPE_FONT,
        $skill_max_chars,
        $SKILL_MARGIN,
        $SKILL_BORDER,
        $skill_width,
    ]
    | str join ''
    | hash sha256
    let output = $CACHE | path join "assets/" $"($eq_or_s.stats_name | str replace --all ' ' '_')-($hash).png"

    if ($output | path exists) {
        log debug $"getting asset for '($eq_or_s.name)' from (ansi purple)($output | path parse | get stem)(ansi reset)"
        return { asset: $output, width: $skill_width }
    }

    mkdir ($output | path dirname)

    let description = fit-items-in-width ($eq_or_s.description | split row " ") $skill_max_chars --separator " "
    let requirements = $eq_or_s.requirements | each {
        # FIXME: no idea why this is IO call is required...
        print --no-newline ""
        fit-items-in-width ($in | split row " ") ($skill_max_chars - 2) --separator " " | each { str join " " }
    }
    let effects = $eq_or_s.effects | each { |it|
        # FIXME: no idea why this is IO call is required...
        print --no-newline ""
        match ($it | describe --detailed).type {
            "string" => {
                fit-items-in-width ($it | split row " ") ($skill_max_chars - 2) --separator " " | each { str join " " }
            },
            "list" => {
                $it | each { |it_2|
                    # FIXME: no idea why this is IO call is required...
                    print --no-newline ""
                    match ($it_2 | describe --detailed).type {
                        "string" => {
                            fit-items-in-width ($it_2 | split row " ") ($skill_max_chars - 4) --separator " " | each { str join " " }
                        },
                        "list" => {
                            $it_2 | each { |it_3|
                                # FIXME: no idea why this is IO call is required...
                                print --no-newline ""
                                fit-items-in-width ($it_3 | split row " ") ($skill_max_chars - 6) --separator " " | each { str join " " }
                            }
                        }
                    }
                }
            }
        }
    }
    let important = $eq_or_s.important | each {
        # FIXME: no idea why this is IO call is required...
        print --no-newline ""
        fit-items-in-width ($in | split row " ") ($skill_max_chars - 2) --separator " " | each { str join " " }
    }
    let remember = $eq_or_s.remember | each {
        # FIXME: no idea why this is IO call is required...
        print --no-newline ""
        fit-items-in-width ($in | split row " ") ($skill_max_chars - 2) --separator " " | each { str join " " }
    }

    let text_x = 10
    let text_y = 10

    let color = match $eq_or_s.type {
        "AUTOMATIC SKILL"
         | "AUTOMATIC EQUIPMENT"
         | "EQUIPMENT"           => $CORVUS_BELLI_COLORS.black,
        "BASIC SHORT SKILL"      => $CORVUS_BELLI_COLORS.blue,
        "DEPLOYMENT SKILL"       => $CORVUS_BELLI_COLORS.purple,
        "LONG SKILL"             => $CORVUS_BELLI_COLORS.red,
        "ARO"                    => $CORVUS_BELLI_COLORS.yellow,
        "SHORT SKILL"            => $CORVUS_BELLI_COLORS.green,
        "SHORT SKILL / ARO"      => $CORVUS_BELLI_COLORS.yellow_green,
        _                        => "0xffffff",
    }

    let description_y = $text_y + 2 * $SKILL_BOLD_FONT.fontsize + $SKILL_MARGIN
    let labels_y = $description_y + ($description | length) * $SKILL_FONT.fontsize + $SKILL_MARGIN // 2
    let requirements_y = $labels_y + ($SKILL_FONT.fontsize + $SKILL_MARGIN)
    let effects_y = if not ($requirements | is-empty) {
        $requirements_y + $SKILL_BOLD_FONT.fontsize + ($requirements | each { length } | math sum) * $SKILL_FONT.fontsize + $SKILL_MARGIN
    } else {
        $requirements_y
    }
    let important_y = $effects_y + $SKILL_BOLD_FONT.fontsize + (
        # TODO: find a better way to flatten these
        $effects | each { |subline|
            match ($subline | describe --detailed).type {
                "string" => 1,
                "list" => {
                    $subline | each { |subsubline|
                        match ($subsubline | describe --detailed).type {
                            "string" => 1,
                            "list" => {
                                $subsubline | each { |subsubsubline|
                                    match ($subsubsubline | describe --detailed).type {
                                        "string" => 1,
                                        "list" => { $subsubsubline | length },
                                    }
                                } | math sum
                            },
                        }
                    } | math sum
                },
            }
        } | math sum
    ) * $SKILL_FONT.fontsize + $SKILL_MARGIN
    let remember_y = if not ($important | is-empty) {
        $important_y + $SKILL_BOLD_FONT.fontsize + ($important | each { length } | math sum) * $SKILL_FONT.fontsize + $SKILL_MARGIN
    } else {
        $important_y
    }

    def section [items: list<any>, title: string, y: int, color: string]: [
        nothing -> table<kind: string, options: record>
    ] {
        if ($items | is-empty) {
            return []
        }

        let title_transform = ffmpeg-text $title { x: ($text_x + 5), y: $"($y)-th/2" } $SKILL_BOLD_FONT

        let box_transform = {
            kind: "drawbox",
            options: {
                x: $"($skill_width)/2-w/2",
                y: $"($y)-h/2",
                w: ($skill_width - 20),
                h: $SKILL_BOLD_FONT.fontsize,
                color: $color,
                t: "fill",
            },
        }

        let transforms = $items
                | reduce --fold { y: ($y + $SKILL_BOLD_FONT.fontsize), ts: [] } { |it, acc|
                    # FIXME: no idea why this is IO call is required...
                    print --no-newline ""
                    let res = $it
                        | enumerate
                        | each { |line|
                            match ($line.item | describe --detailed).type {
                                "string" => {
                                    if $line.index == 0 {
                                        $"-\\ ($line.item)"
                                    } else {
                                        $"\\ \\ ($line.item)"
                                    }
                                },
                                "list" => {
                                    $line.item | enumerate | each { |subline|
                                        match ($subline.item | describe --detailed).type {
                                            "string" => {
                                                if $subline.index == 0 {
                                                    $"\\ \\ -\\ ($subline.item)"
                                                } else {
                                                    $"\\ \\ \\ \\ ($subline.item)"
                                                }
                                            },
                                            "list" => {
                                                $subline.item | enumerate | each { |subsubline|
                                                    if $subsubline.index == 0 {
                                                        $"\\ \\ \\ \\ -\\ ($subsubline.item)"
                                                    } else {
                                                        $"\\ \\ \\ \\ \\ \\ ($subsubline.item)"
                                                    }
                                                }
                                            },
                                        }
                                    }
                                },
                            }
                        }
                    # TODO: find a better way to flatten these
                    let res = match ($res.0 | describe --detailed).type {
                        "list" => {
                            $res | each { |it|
                                match ($it.0 | describe --detailed).type {
                                    "list" => { $it | flatten },
                                    "string" => $it,
                                }
                            }
                            | flatten
                        },
                        "string" => $res,
                    }
                    | enumerate
                    | each {
                        let pos = {
                            x: ($text_x + 10),
                            y: ($acc.y + $in.index * $SKILL_FONT.fontsize),
                        }
                        ffmpeg-text $in.item $pos $SKILL_FONT
                    }

                    {
                        y: ($acc.y + ($res | length) * $SKILL_FONT.fontsize),
                        ts: ($acc.ts ++ $res),
                    }
                }
                | get ts

        [ $box_transform, $title_transform ] ++ $transforms
    }

    let transforms = [
        (ffmpeg-text $eq_or_s.name { x: $text_x, y: $text_y } $SKILL_BOLD_FONT),
        (ffmpeg-text $eq_or_s.type {
            x: $"($skill_width)-($SKILL_BORDER)-tw",
            y: $"(2 * ($SKILL_FONT.fontsize + $SKILL_MARGIN) - 5)-th",
        } $SKILL_TYPE_FONT),
        ...(
            $description
                | each { str join " " }
                | enumerate
                | each { |line|
                    let pos = {
                        x: $text_x,
                        y: ($description_y + $line.index * $SKILL_FONT.fontsize),
                    }
                    ffmpeg-text $line.item $pos $SKILL_FONT
                }
        ),
        (ffmpeg-text ($eq_or_s.labels | str join ", ") { x: $text_x, y: $labels_y } $SKILL_FONT),
        ...(section $requirements "REQUIREMENTS" $requirements_y "0x333333"),
        ...(section $effects      "EFFECTS"      $effects_y      "0x666666"),
        ...(section $important    "IMPORTANT"    $important_y    $CORVUS_BELLI_COLORS.red),
        ...(section $remember     "REMEMBER"     $remember_y     $CORVUS_BELLI_COLORS.yellow),
    ]
    | compact

    let border = {
        kind: "drawbox",
        options: {
            x: 0,
            y: 0,
            w: $skill_width,
            h: (($transforms | last).options.y + $SKILL_FONT.fontsize + 10),
            color: $color,
            t: $"($SKILL_BORDER)",
        },
    }

    let header_box = {
        kind: "drawbox",
        options: {
            x: 0,
            y: 0,
            w: $skill_width,
            h: (2 * ($SKILL_FONT.fontsize + $SKILL_MARGIN)),
            color: $color,
            t: "fill",
        },
    }

    let asset = ffmpeg create (
            $BASE_IMAGE
                | update options.s $"($border.options.w)x($border.options.h)"
                | ffmpeg options
        ) --output (mktemp --tmpdir infinity-XXXXXXX.png)
        | ffmpeg mapply (
            [$border, $header_box] ++ $transforms | each { ffmpeg options }
        ) --output $output

    { asset: $asset, width: $skill_width }
}
