use log.nu [ "log info", "log warning" ]

const FONT_UPSTREAM = "https://download.gnome.org/sources/adwaita-fonts/48/adwaita-fonts-48.2.tar.xz"
const FONT_LOCAL = "/tmp/adwaita-fonts-48.2.tar.xz"

def "main git" [] {
    log info "git config diff.exif.textconv exiftool"
    git config diff.exif.textconv exiftool
}

def "main font" [] {
    log info $"curl -fLo ($FONT_LOCAL) ($FONT_UPSTREAM)"
    curl -fLo $FONT_LOCAL $FONT_UPSTREAM

    log info $"tar xvf ($FONT_LOCAL)"
    tar xvf $FONT_LOCAL
}

const COLORS = {
    "panoceania":  "0x66b6d7",
    "jsa":         "0xe79799",
    "nomads":      "0xdb6c72",
    "aleph":       "0xafa7bc",
    "mercenaries": "0x88a5b7",
    "o-12":        "0xdece67",
}

const SHOWCASE = [
    [name,                            color];
    ["panoceania/orc",                $COLORS.panoceania],
    ["jsa/shikami",                   $COLORS.jsa],
]

const TROOPS = [
    [name,                            color];
    ["nomads/tunguska-cheerkiller.1", $COLORS.nomads],
    ["nomads/tunguska-cheerkiller.2", $COLORS.nomads],
    ["nomads/tunguska-cheerkiller.3", $COLORS.nomads],
    ["nomads/tunguska-grenzer",       $COLORS.nomads],
    ["aleph/danavas",                 $COLORS.aleph],
    ["aleph/marut-karkata",           $COLORS.aleph],
    ["mercenaries/digger",            $COLORS.mercenaries],
    ["o-12/starmada-bronze",          $COLORS.o-12],
    ["o-12/starmada-nyoka.1",         $COLORS.o-12],
    ["o-12/starmada-nyoka.2",         $COLORS.o-12],
    ["o-12/starmada-nyoka.3",         $COLORS.o-12],
]

def run [troops: table<name: string, color: string>, --stats, --charts] {
    use build_card.nu

    if ($troops | is-empty) {
        log warning "nothing to do"
        return
    }

    mkdir out/

    for t in $troops {
        let troop_file = { parent: "troops/stats", stem: $t.name, extension: "nuon" } | path join
        let output = { parent: "out", stem: ($t.name | str replace '/' '-'), extension: "png" } | path join

        log info $t.name
        build_card (open $troop_file) --color $t.color --output $output --stats=$stats --charts=$charts
    }
}

def "main showcase" [--stats, --charts] {
    run $SHOWCASE --stats=$stats --charts=$charts
}

def "main troops" [name: string = "", --stats, --charts] {
    run ($TROOPS | where name =~ $name) --stats=$stats --charts=$charts
}

def "main viz" [] {
    use ffmpeg.nu [ "ffmpeg combine", VSTACKING ]

    let res = ls out/
        | get name
        | group-by --to-table { path parse | get stem | split row '.' | reverse | skip 1 | reverse | str join "." }
        | each {
            let output = mktemp --tmpdir "XXXXXXX.png"
            $in.items | ffmpeg combine $VSTACKING --output $output
            print $in.closure_0
            $output
        }

    feh --image-bg '#aaaaaa' --draw-tinted --draw-exif --draw-filename --fullscreen ...$res
}

def "main" [] {}
