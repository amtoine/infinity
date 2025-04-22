use log.nu [ "log info", "log warning" ]

const FONT_UPSTREAM = "https://download.gnome.org/sources/adwaita-fonts/48/adwaita-fonts-48.2.tar.xz"
const FONT_LOCAL = "/tmp/adwaita-fonts-48.2.tar.xz"

const STATS_DIR = "./troops/stats/"
const OUT_DIR = "./out/"

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
    "panoceania":    "0x66b6d7",
    "jsa":           "0xe79799",
    "nomads":        "0xdb6c72",
    "aleph":         "0xafa7bc",
    "mercenaries":   "0x88a5b7",
    "o-12":          "0xdece67",
    "combined-army": "0x9c96c9",
}

const SHOWCASE = [
    [name,                            color];
    ["panoceania/orc",                $COLORS.panoceania],
    ["jsa/shikami",                   $COLORS.jsa],
]

def list-troops [] {
    $STATS_DIR
        | path join "*/*.nuon"
        | into glob
        | ls $in
        | select name
        | update name {
            path parse
                | update parent { path split | skip 2 | path join }
                | reject extension
                | path join
        }
        | insert color {
            let faction = $in.name | path split | get 0
            $COLORS | get $faction
        }
}

def run [troops: table<name: string, color: string>, --stats, --charts] {
    use build_card.nu

    if ($troops | is-empty) {
        log warning "nothing to do"
        return
    }

    mkdir $OUT_DIR

    for t in $troops {
        let troop_file = { parent: $STATS_DIR, stem: $t.name, extension: "nuon" } | path join
        let output = { parent: $OUT_DIR, stem: ($t.name | str replace '/' '-'), extension: "png" } | path join

        log info $t.name
        build_card (open $troop_file) --color $t.color --output $output --stats=$stats --charts=$charts
    }
}

def "main showcase" [--stats, --charts] {
    run $SHOWCASE --stats=$stats --charts=$charts
    for s in $SHOWCASE {
        cp --verbose ($"($OUT_DIR)/($s.name | str replace '/' '-').*" | into glob) assets/
    }
}

def "main troops" [name: string = "", --stats, --charts] {
    run (list-troops | where name =~ $name) --stats=$stats --charts=$charts
}

def "main clean" [] {
    log info $"cleaning ((try { ls /tmp/infinity-*.png } catch {[]} | length) + (try { ls /tmp/ffmpeg-*.png } catch {[]} | length)) file\(s\)"
    rm --force /tmp/infinity-*.png  /tmp/ffmpeg-*.png
}

def "main viz" [name: string = ""] {
    use ffmpeg.nu [ "ffmpeg combine", VSTACKING ]

    let res = ls $OUT_DIR
        | where $it.name =~ $name
        | insert key {
            $in.name | path parse | get stem | split row '.' | reverse | skip 1 | reverse | str join "."
        }
        | group-by --to-table key
        | each {
            print $in.key
            let output = { parent: $nu.temp-path, stem: $in.key, extension: "png"} | path join
            $in.items.name | ffmpeg combine $VSTACKING --output $output
            $output
        }

    feh --image-bg '#aaaaaa' --draw-tinted --draw-exif --draw-filename --fullscreen ...$res
}

def "main pdf" [name: string = ""] {
    let _ = ls $OUT_DIR
        | where $it.name =~ $name
        | insert key {
            $in.name | path parse | get stem | split row '.' | reverse | skip 1 | reverse | str join "."
        }
        | group-by --to-table key
        | each {
            print $in.key
            let output = { parent: $nu.temp-path, stem: $in.key, extension: "pdf"} | path join
            img2pdf ...$in.items.name --output $output
        }
}

def "main archive" [] {
    let assets = list-troops
        | get name
        | each { str replace '/' '-' | $"($OUT_DIR)/($in)" | [ $"($in).1.png", $"($in).2.png" ] }
        | flatten

    ^tar czf $"infinity-trooper-assets-(git describe).tar.gz" ...$assets
    ^zip $"infinity-trooper-assets-(git describe).zip" ...$assets
}

def "main release" [] {
    main clean
    main troops
    main archive
}

def "main" [] {
    main clean
    main showcase
    main troops
    main viz
}
