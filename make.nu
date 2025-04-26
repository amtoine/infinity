use log.nu [ "log info", "log warning" ]

const FONT_UPSTREAM = "https://download.gnome.org/sources/adwaita-fonts/48/adwaita-fonts-48.2.tar.xz"
const FONT_LOCAL = "/tmp/adwaita-fonts-48.2.tar.xz"

const STATS_DIR = "./troops/stats/"
const OUT_DIR = "./out/"

# configure Git
def "main git" [] {
    log info "git config diff.exif.textconv exiftool"
    git config diff.exif.textconv exiftool
}

# install required fonts
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
    [name,             color];
    ["panoceania/orc", $COLORS.panoceania],
    ["jsa/shikami",    $COLORS.jsa],
]

def list-troops []: [ nothing -> table<name: string, color: string> ] {
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

    let total = $troops | length

    for t in ($troops | enumerate) {
        let troop_file = { parent: $STATS_DIR, stem: $t.item.name, extension: "nuon" } | path join
        let output = { parent: $OUT_DIR, stem: ($t.item.name | str replace '/' '-'), extension: "png" } | path join

        {
            current: (
                $t.index + 1
                    | fill --alignment "right" --width ($total | into string | str length) --character ' '
            ),
            total: $total,
            content: $t.item.name,
        } | log info $"\(($in.current) / ($in.total)\) ($in.content)"
        build_card (open $troop_file) --color $t.item.color --output $output --stats=$stats --charts=$charts
    }
}

# build the "showcase" cards and copy them to the the `assets/` directory
def "main showcase" [--stats, --charts] {
    run $SHOWCASE --stats=$stats --charts=$charts
    for s in $SHOWCASE {
        cp --verbose ($"($OUT_DIR)/($s.name | str replace '/' '-').*" | into glob) assets/
    }
}

# build the "troops" cards from NUON "trooper" files in the `troops/stats/` directory
def "main troops" [name: string = "", --stats, --charts] {
    run (list-troops | where name =~ $name) --stats=$stats --charts=$charts
}

# clean all PNG building files
def "main clean" [] {
    log info $"cleaning ((try { ls /tmp/infinity-*.png } catch {[]} | length) + (try { ls /tmp/ffmpeg-*.png } catch {[]} | length)) file\(s\)"
    rm --force /tmp/infinity-*.png  /tmp/ffmpeg-*.png
}

def batch-transform-pairs [name: string, transform: closure, extension: string]: [ nothing -> list<path> ] {
    let todo = ls $OUT_DIR
        | where $it.name =~ $name
        | insert key {
            $in.name | path parse | get stem | split row '.' | reverse | skip 1 | reverse | str join "."
        }
    let total = ($todo | length) / 2
    let width = $todo | each { $in.key | str length } | math max

    $todo
        | group-by --to-table key
        | enumerate
        | each {
            {
                current: (
                    $in.index + 1
                        | fill --alignment "right" --width ($total | into string | str length) --character ' '
                ),
                total: $total,
                content: ($in.item.key | fill --alignment "left" --width $width --character ' '),
            } | print --no-newline $"[($in.current) / ($in.total)] ($in.content)\r"
            let output = { parent: $nu.temp-path, stem: $in.item.key, extension: $extension } | path join
            do $transform $in.item.items.name $output
            $output
        }
}

# combine pairs of cards into single PNGs and view them
def "main viz" [name: string = ""] {
    use ffmpeg.nu [ "ffmpeg combine", VSTACKING ]

    feh --image-bg '#aaaaaa' --draw-tinted --draw-exif --draw-filename --fullscreen ...(
        batch-transform-pairs $name { |x, out| $x | ffmpeg combine $VSTACKING --output $out } "png"
    )
}

# combine pairs of cards into single PDFs
def "main pdf" [name: string = ""] {
    let _ = batch-transform-pairs $name { |x, out| img2pdf ...$x --output $out } "pdf"
}

# archive the trooper cards
def "main archive" [] {
    let assets = list-troops
        | get name
        | each { str replace '/' '-' | $"($OUT_DIR)/($in)" | [ $"($in).1.png", $"($in).2.png" ] }
        | flatten

    ^tar czf $"archives/infinity-trooper-assets-(git describe).tar.gz" ...$assets
    ^zip $"archives/infinity-trooper-assets-(git describe).zip" ...$assets
}

# run all that is required for a release
def "main release" [] {
    main clean
    main troops
    main archive
}

# the default target
def "main" [] {
    main clean
    main showcase
    main troops
    main viz
}
