use common.nu [
    BOLD_FONT, REGULAR_FONT, BASE_IMAGE, CANVAS, CORVUS_BELLI_COLORS,
    put-version, ffmpeg-text, "parse modifier-from-skill", fit-items-in-width,
]

const CACHE =  "~/.cache/infinity/" | path expand

const PARAMETERS = {
    font: { fontfile: $REGULAR_FONT, fontcolor: "black", fontsize: 10 },
    bold_font: { fontfile: $BOLD_FONT, fontcolor: "white", fontsize: 20 },
    type_font: { fontfile: $BOLD_FONT, fontcolor: "white", fontsize: 18 },
    margin: 20,
    border: 5,
    text: { x: 10, y: 10 },
    max_chars: 60,
}

export def generate-equipment-or-skill-card [equipment_or_skill: record, parameters = $PARAMETERS]: [
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

    let width = (
        $parameters.max_chars * $parameters.font.fontsize * 6 // 10 +
        20 +
        2 * $parameters.border
    )

    let hash = [ ($eq_or_s | to nuon), ($parameters | to nuon), $width, ] | str join '' | hash sha256
    let output = $CACHE | path join "assets/" $"($eq_or_s.stats_name | str replace --all ' ' '_')-($hash).png"

    if ($output | path exists) {
        log debug $"getting asset for '($eq_or_s.name)' from (ansi purple)($output | path parse | get stem)(ansi reset)"
        return { asset: $output, width: $width }
    }

    mkdir ($output | path dirname)

    let description = fit-items-in-width ($eq_or_s.description | split row " ") $parameters.max_chars --separator " "
    let requirements = $eq_or_s.requirements | each {
        # FIXME: no idea why this is IO call is required...
        print --no-newline ""
        fit-items-in-width ($in | split row " ") ($parameters.max_chars - 2) --separator " " | each { str join " " }
    }
    let effects = $eq_or_s.effects | each { |it|
        # FIXME: no idea why this is IO call is required...
        print --no-newline ""
        match ($it | describe --detailed).type {
            "string" => {
                fit-items-in-width ($it | split row " ") ($parameters.max_chars - 2) --separator " " | each { str join " " }
            },
            "list" => {
                $it | each { |it_2|
                    # FIXME: no idea why this is IO call is required...
                    print --no-newline ""
                    match ($it_2 | describe --detailed).type {
                        "string" => {
                            fit-items-in-width ($it_2 | split row " ") ($parameters.max_chars - 4) --separator " " | each { str join " " }
                        },
                        "list" => {
                            $it_2 | each { |it_3|
                                # FIXME: no idea why this is IO call is required...
                                print --no-newline ""
                                fit-items-in-width ($it_3 | split row " ") ($parameters.max_chars - 6) --separator " " | each { str join " " }
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
        fit-items-in-width ($in | split row " ") ($parameters.max_chars - 2) --separator " " | each { str join " " }
    }
    let remember = $eq_or_s.remember | each {
        # FIXME: no idea why this is IO call is required...
        print --no-newline ""
        fit-items-in-width ($in | split row " ") ($parameters.max_chars - 2) --separator " " | each { str join " " }
    }

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

    let description_y = $parameters.text.y + 2 * $parameters.bold_font.fontsize + $parameters.margin
    let labels_y = $description_y + ($description | length) * $parameters.font.fontsize + $parameters.margin // 2
    let requirements_y = $labels_y + ($parameters.font.fontsize + $parameters.margin)
    let effects_y = if not ($requirements | is-empty) {
        $requirements_y + $parameters.bold_font.fontsize + ($requirements | each { length } | math sum) * $parameters.font.fontsize + $parameters.margin
    } else {
        $requirements_y
    }
    let important_y = $effects_y + $parameters.bold_font.fontsize + (
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
    ) * $parameters.font.fontsize + $parameters.margin
    let remember_y = if not ($important | is-empty) {
        $important_y + $parameters.bold_font.fontsize + ($important | each { length } | math sum) * $parameters.font.fontsize + $parameters.margin
    } else {
        $important_y
    }

    def section [items: list<any>, title: string, y: int, color: string]: [
        nothing -> table<kind: string, options: record>
    ] {
        if ($items | is-empty) {
            return []
        }

        let title_transform = ffmpeg-text $title { x: (1.5 * $parameters.text.x), y: $"($y)-th/2" } $parameters.bold_font

        let box_transform = {
            kind: "drawbox",
            options: {
                x: $"($width)/2-w/2",
                y: $"($y)-h/2",
                w: ($width - 20),
                h: $parameters.bold_font.fontsize,
                color: $color,
                t: "fill",
            },
        }

        let transforms = $items
                | reduce --fold { y: ($y + $parameters.bold_font.fontsize), ts: [] } { |it, acc|
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
                            x: ($parameters.text.x + 10),
                            y: ($acc.y + $in.index * $parameters.font.fontsize),
                        }
                        ffmpeg-text $in.item $pos $parameters.font
                    }

                    {
                        y: ($acc.y + ($res | length) * $parameters.font.fontsize),
                        ts: ($acc.ts ++ $res),
                    }
                }
                | get ts

        [ $box_transform, $title_transform ] ++ $transforms
    }

    let transforms = [
        (ffmpeg-text $eq_or_s.name { x: $parameters.text.x, y: $parameters.text.y } $parameters.bold_font),
        (ffmpeg-text $eq_or_s.type {
            x: $"($width)-($parameters.border)-tw",
            y: $"(2 * ($parameters.font.fontsize + $parameters.margin) - 5)-th",
        } $parameters.type_font),
        ...(
            $description
                | each { str join " " }
                | enumerate
                | each { |line|
                    let pos = {
                        x: $parameters.text.x,
                        y: ($description_y + $line.index * $parameters.font.fontsize),
                    }
                    ffmpeg-text $line.item $pos $parameters.font
                }
        ),
        (ffmpeg-text ($eq_or_s.labels | str join ", ") { x: $parameters.text.x, y: $labels_y } $parameters.font),
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
            w: $width,
            h: (($transforms | last).options.y + $parameters.font.fontsize + 10),
            color: $color,
            t: $"($parameters.border)",
        },
    }

    let header_box = {
        kind: "drawbox",
        options: {
            x: 0,
            y: 0,
            w: $width,
            h: (2 * ($parameters.font.fontsize + $parameters.margin)),
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

    { asset: $asset, width: $width }
}
