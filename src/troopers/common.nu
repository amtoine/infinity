use ../log.nu [ "log warning", "log error" ]

const ASSETS_DIR = "./troops/assets/"
export const DIRS = {
    minis:            ($ASSETS_DIR | path join "minis"),
    factions:         ($ASSETS_DIR | path join "factions" "940"),
    allowed_factions: ($ASSETS_DIR | path join "factions" "70")
    characteristics:  ($ASSETS_DIR | path join "characteristics"),
    icons:            ($ASSETS_DIR | path join "icons"),
}

export const CANVAS = { w: 1600, h: 1000 }
export const BASE_IMAGE = { kind: "color", options: { c: "0xDDDDDD", s: $"($CANVAS.w)x($CANVAS.h)", d: 1 } }

export const BOLD_FONT = "./adwaita-fonts-48.2/mono/AdwaitaMono-Bold.ttf"
export const REGULAR_FONT = "./adwaita-fonts-48.2/mono/AdwaitaMono-Regular.ttf"

const VERSION_POS = { x: $"($CANVAS.w)-tw-2", y: $"($CANVAS.h)-th-2" }
const VERSION_FONT = { fontfile: $REGULAR_FONT, fontsize: 15, fontcolor: "black"}

export def "ffmpeg-text" [
    text: string, position: record<x: string, y: string>, options: record
]: [
    nothing -> record<kind: string, options: record<text: string, x: string, y: string>>
] {
    let text = $text
        | str replace --all ":" "\\:"
        | str replace --all "," "\\,"
        | str replace --all "[" "\\["
        | str replace --all "]" "\\]"
        | $"'($in)'"
    { kind: "drawtext", options: { text: $text, ...$position, ...$options } }
}

export def "put-version" []: [ path -> path ] {
    let versions = open versions.json
    let version_text = $"(git describe) [Army: ($versions.army), Rules: ($versions.rules)]"
    let out = mktemp --tmpdir infinity-XXXXXXX.png
    $in | ffmpeg apply ((ffmpeg-text $version_text $VERSION_POS $VERSION_FONT) | ffmpeg options) --output $out
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
