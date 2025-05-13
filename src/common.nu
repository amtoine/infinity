use log.nu [ "log warning", "log error" ]

const ASSETS_DIR = "./troops/assets/"
export const DIRS = {
    minis:            ($ASSETS_DIR | path join "minis"),
    factions:         ($ASSETS_DIR | path join "factions" "940"),
    allowed_factions: ($ASSETS_DIR | path join "factions" "70")
    characteristics:  ($ASSETS_DIR | path join "characteristics"),
    icons:            ($ASSETS_DIR | path join "icons"),
}

export const BASE_COLOR = "0xffffff"

export const BOLD_FONT = "./adwaita-fonts-48.2/mono/AdwaitaMono-Bold.ttf"
export const REGULAR_FONT = "./adwaita-fonts-48.2/mono/AdwaitaMono-Regular.ttf"

export const TEXT_ALIGNMENT = {
    top_left     : { x:     "", y:     "" },
    top          : { x: "tw/2", y:     "" },
    top_right    : { x:   "tw", y:     "" },
    left         : { x:     "", y: "th/2" },
    center       : { x: "tw/2", y: "th/2" },
    right        : { x:   "tw", y: "th/2" },
    bottom_left  : { x:     "", y:   "th" },
    bottom       : { x: "tw/2", y:   "th" },
    bottom_right : { x:   "tw", y:   "th" },
}

export def get-options [w: int, h: int, margin: int, debug: bool]: [
    nothing -> record<
        canvas: record<w: int, h: int>,
        margins: record<top: float, bottom: float, left: float, right: float>,
        debug_margin: bool,
        version: record<
            pos: record<
                x: float,
                y: float,
                alignment: record<x: string, y: string>,
            >,
            font: record<fontfile: path, fontsize: float, fontcolor: string>,
        >,
    >
] { {
    canvas: { w: $w, h: $h },
    margin: $margin,
    debug_margin: $debug,
    margins: {
        top    : (0.035 * $h),
        bottom : (0.965 * $h),
        left   : (0.035 * $w),
        right  : (0.965 * $w),
    },
    version: {
        pos: {
            x: (0.99875 * $w + $margin),
            y: (0.99875 * $h + $margin),
            alignment: $TEXT_ALIGNMENT.bottom_right,
        },
        font: { fontfile: $REGULAR_FONT, fontsize: (15 / 1600 * $w), fontcolor: "black" },
    }
} }

export const BASE_COLOR = "0xffffff"

export const BOLD_FONT = "./adwaita-fonts-48.2/mono/AdwaitaMono-Bold.ttf"
export const REGULAR_FONT = "./adwaita-fonts-48.2/mono/AdwaitaMono-Regular.ttf"

export const CORVUS_BELLI_COLORS = {
    green:  "0x76ac5d",
    blue:   "0x59b9d1",
    yellow: "0xea9931",
    yellow_green: "0xbaff25",
    red:    "0xdc3e4c",
    black:  "0x231f20",
    gray:   "0xcdd5de",
    purple: "0x5e3198",
}


export def "ffmpeg-text" [
    text: string,
    position: record<
        x: number,
        y: number,
        alignment: record<x: string, y: string>,
    >,
    options: record,
]: [
    nothing -> record<kind: string, options: record<text: string, x: string, y: string>>
] {
    let text = $text
        | str replace --all ":" "\\:"
        | str replace --all "," "\\,"
        | str replace --all "[" "\\["
        | str replace --all "]" "\\]"
        | $"'($in)'"
    let alignment = if $position.alignment == null {
        { x: "", y: "", }
    } else {{
        x: (if $position.alignment.x == "" { "" } else { $"-($position.alignment.x)" }),
        y: (if $position.alignment.y == "" { "" } else { $"-($position.alignment.y)" }),
    }}
    let pos = {
        x: $"($position.x)($alignment.x)",
        y: $"($position.y)($alignment.y)",
    }

    { kind: "drawtext", options: { text: $text, ...$pos, ...$options } }
}

export def "put-version" [
    trooper: record,
    version: record<
        pos: record<x: float, y: float, alignment: record>,
        font: record<fontfile: path, fontsize: float, fontcolor: string>,
    >,
]: [ path -> path ] {
    let versions = open versions.json
        | insert trooper { $trooper | to nuon | hash sha256 | str substring 0..7 }
        | items { |k, v| $"($k | str title-case): ($v)" }
    let version_text = $"(git describe) [($versions | str join ', ')]"

    let out = mktemp --tmpdir infinity-XXXXXXX.png
    $in | ffmpeg apply ((ffmpeg-text $version_text $version.pos $version.font) | ffmpeg options) --output $out
}

const KV_MODIFIER_FMT           = '^(?<k>.*)=(?<v>.*)$'
const ATTR_MODIFIER_FMT         = '^(?<x>[+-])(?<v>\d+)(?<k>.*)$'
const ATTR_MODIFIER_INV_FMT     = '^(?<k>.*)(?<x>[+-])(?<v>\d+)$'
const MARTIAL_ARTS_MODIFIER_FMT = '^L(?<v>\d+)$'

# - extra output
# ```
# [ERROR] could not parse modifier 'foo' of skill 'invalid'
# [WARNING] skipping modifier '+2K' of skill 'delta-non-B'
# [WARNING] skipping modifier '-2B' of skill 'delta-negative'
# [WARNING] skipping modifier 'K+2' of skill 'inv-delta-non-B'
# [WARNING] skipping modifier 'B-2' of skill 'inv-delta-negative'
# ```
# - the test
# ```nushell
# use std assert
#
# const TEST_CASES = [
#     [                 name,             mod,                                  expected ];
#
#     [              "empty",            null,                                      null ],
#     [            "invalid",           "foo",                                      null ],
#     [          "key-value",           "K=V", {         k: "K",    v: "V"             } ],
#     [            "delta-B",           "+2B", { x: "+", k: "B",    v: "2"             } ],
#     [        "delta-non-B",           "+2K",                                      null ],
#     [     "delta-negative",           "-2B",                                      null ],
#     [        "inv-delta-B",           "B+2", { x: "+", k: "B",    v: "2"             } ],
#     [    "inv-delta-non-B",           "K+2",                                      null ],
#     [ "inv-delta-negative",           "B-2",                                      null ],
#     [       "martial-arts",            "L2", {                    v: 2               } ],
#     [            "Terrain", "<terrain-mod>", {                    v: "<terrain-mod>" } ],
#     [           "Whatever",            "T2", {         k: "AMMO", v: "T2"            } ],
#     [                   "",            "T2", {         k: "AMMO", v: "T2"            } ],
# ]
#
# for t in $TEST_CASES {
#     let actual = { name: $t.name, mod: $t.mod } | common parse modifier-from-skill
#     assert equal $actual $t.expected
# }
# ```
export def "parse modifier-from-skill" []: [ record<name: string, mod: any> -> record ] {
    let skill = $in
    let mod = $skill.mod? | default ""

    let res = $mod | parse --regex $KV_MODIFIER_FMT | into record
    if $res != {} {
        return $res
    }

    let res = $mod | parse --regex $ATTR_MODIFIER_FMT | into record
    if $res != {} {
        # NOTE: see p.68 of the rulebook
        if $res.k != "B" or $res.x == "-" {
            log warning $"skipping modifier '($mod)' of skill '($skill.name)'"
            return null
        } else {
            return $res
        }
    }

    let res = $mod | parse --regex $ATTR_MODIFIER_INV_FMT | into record
    if $res != {} {
        # NOTE: see p.68 of the rulebook
        if $res.k != "B" or $res.x == "-" {
            log warning $"skipping modifier '($mod)' of skill '($skill.name)'"
            return null
        } else {
            return $res
        }
    }

    let res = $mod | parse --regex $MARTIAL_ARTS_MODIFIER_FMT | into record
    if $res != {} {
        return ($res | into int v)
    }

    if $skill.name == "Terrain" {
        return { v: $mod }
    }

    if $skill.mod == "T2" {
        return { k: "AMMO", v: "T2" }
    }

    if $skill.mod != null {
        log error $"could not parse modifier '($mod)' of skill '($skill.name)'"
    }
    return null
}

export def fit-items-in-width [
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

