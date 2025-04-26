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

export def "ffmpeg-text" [text: string, position: record<x, y>, options: record] {
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
