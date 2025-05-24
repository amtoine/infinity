use . log [ "log info", "log warning" ]
use . ffmpeg *

const FONT_UPSTREAM = "https://download.gnome.org/sources/adwaita-fonts/48/adwaita-fonts-48.2.tar.xz"
const FONT_LOCAL = "/tmp/adwaita-fonts-48.2.tar.xz"

const STATS_DIR = "./troops/stats/"
const OUT_DIR = "./out/"

export const FORMATS = {
    jumbo: { wi: 5.00, hi: 3.50 },
    poker: { wi: 3.50, hi: 2.50 },
}

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

# build the "troops" cards from NUON "trooper" files in the `troops/stats/` directory
def "main troops" [
    name: string = "",
    --width (-w): int,
    --height (-h): int,
    --margin (-m): int,
    --debug,
    --stats,
    --charts,
] {
    use . troopers build-trooper-card

    let troops = list-troops | where name =~ $name
    let canvas = { w: $width, h: $height }

    if ($troops | is-empty) {
        log warning "nothing to do"
        return
    }

    mkdir $OUT_DIR

    let total = $troops | length

    for t in ($troops | enumerate) {
        let troop_file = {
            parent: $STATS_DIR,
            stem: $t.item.name,
            extension: "nuon",
        } | path join
        let output = {
            parent: $OUT_DIR,
            stem: ($t.item.name | str replace '/' '-'),
            extension: "png",
        } | path join

        {
            current: (
                $t.index + 1
                    | fill --alignment "right" --width ($total | into string | str length) --character ' '
            ),
            total: $total,
            content: $t.item.name,
        } | log info $"\(($in.current) / ($in.total)\) ($in.content)"
        (build-trooper-card (open $troop_file)
            --canvas $canvas
            --margin $margin
            --debug=$debug
            --color $t.item.color
            --output $output
            --stats=$stats
            --charts=$charts
        )
    }
}

export def "main fmt-troop" [format: record, ...troopers: string, --dpi: float, --margin: float = 0.00] {
    for t in $troopers {
        bash -c "rm -rf /tmp/*.png"
        (main troops
            $t
            --stats
            --charts
            -w ($format.wi * $dpi | into int)
            -h ($format.hi * $dpi | into int)
            -m ($format.wi * $dpi * $margin | into int)
        )
    }
    notify-send "done"
}

# build the "showcase" cards and copy them to the the `assets/` directory
def "main showcase" [] {
    let troopers = ["jsa/shikami", "panoceania/orc"]
    main fmt-troop $FORMATS.poker ...$troopers --dpi 500 --margin 0.00

    let dirty = not (git status --short --untracked-files=no | lines | is-empty)
    let rev = git rev-parse HEAD | if $dirty {
        $"($in)-dirty"
    } else {
        $in
    }

    for t in $troopers {
        cp --verbose ($"($OUT_DIR)/($rev)-($t | str replace '/' '-').1.*.png" | into glob) assets/
    }
}

# clean all PNG building files
def "main clean" [] {
    log info $"cleaning ((try { ls /tmp/infinity-*.png } catch {[]} | length) + (try { ls /tmp/ffmpeg-*.png } catch {[]} | length)) file\(s\)"
    rm --force /tmp/infinity-*.png  /tmp/ffmpeg-*.png
}

def batch-transform-pairs [
    name: string, transform: closure, extension: string
]: [
    nothing -> list<path>
] {
    let todo = ls $OUT_DIR
        | where $it.name =~ $name
        | insert key {
            $in.name
                | path parse
                | get stem
                | split row '.'
                | reverse
                | skip 1
                | reverse
                | str join "."
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
            let output = {
                parent: $nu.temp-path,
                stem: $in.item.key,
                extension: $extension
            } | path join
            do $transform $in.item.items.name $output
            $output
        }
}

# combine pairs of cards into single PNGs and view them
def "main viz" [name: string = ""] {
    use . ffmpeg [ "ffmpeg combine", VSTACKING ]

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
        | each {
            str replace '/' '-'
                | $"($OUT_DIR)/($in)"
                | [ $"($in).1.png", $"($in).2.png" ]
        }
        | flatten

    ^tar czf $"archives/infinity-trooper-assets-(git describe).tar.gz" ...$assets
    ^zip $"archives/infinity-trooper-assets-(git describe).zip" ...$assets
}

def "main skill-cards" [] {
    use . skills-and-equipments

    let equipments = ls equipments/*.nuon | get name
    let skills = ls skills/*.nuon | get name

    let todo = $equipments ++ $skills
        | where ($it | path parse).stem != "__blank"
        | each {
            open $in
                | insert pos { w: 4 }
                | insert stats_name { $in.name | str upcase }
        }

    let total = $todo | length
    let width = $todo | each { $in.name | str length } | math max

    $todo
        | enumerate
        | each {
            {
                current: (
                    $in.index + 1
                        | fill --alignment "right" --width ($total | into string | str length) --character ' '
                ),
                total: $total,
                content: ($in.item.name | fill --alignment "left" --width $width --character ' '),
            } | print --no-newline $"[($in.current) / ($in.total)] ($in.content)\r"
            skills-and-equipments generate-equipment-or-skill-card $in.item
        }
        | get asset
}

const MAKEPLAYINGCARDS_EXTENSION = "jpg"

def "makeplayingcards fetch" [
    id: string,
    side: string,
    index: int,
    --output: string = "output.@ext",
]: [ nothing -> path ] {
    let output = $output
        | str replace --all "@auto" $"($id)_($side)_($index)"
        | str replace --all "@rand" (random uuid | hash sha256)
        | str replace --all "@ext" $MAKEPLAYINGCARDS_EXTENSION
    let url = {
        scheme: https,
        host: "www.makeplayingcards.com",
        path: $"//PreviewFiles/Share/($id)($side)($index).($MAKEPLAYINGCARDS_EXTENSION)",
    }

    mkdir ($output | path dirname)

    print --no-newline $"($index) ($side)\t"
    http get ($url | url join) | save --force $output

    let metadata = $output | ffmpeg metadata
    if $metadata == {} or ($metadata.streams | select width height) == { width: 0, height: 0 } {
        print $"(ansi red_bold)not an image(ansi reset)"
        null
    } else {
        print $"(ansi green)ok(ansi reset)"
        $output
    }
}

def "main makeplayingcards.com fetch" [
    id: string,
    ...cards: string,
    --viewer: record<
        cmd: string,
        args: list<string>,
    > = {
        cmd: feh,
        args: [ --image-bg, '#aaaaaa', --draw-tinted, --draw-exif, --draw-filename, --fullscreen ],
    },
] {
    $cards | into int | each { |card|
        let front = makeplayingcards fetch $id "FRONT" $card --output mpc/@auto.@ext
        let back  = makeplayingcards fetch $id  "BACK" $card --output mpc/@auto.@ext
        match [$front, $back] {
            [null, null] => {},
            [null,    _] => {
                let dims = $back | ffmpeg metadata | get streams | select width height
                let front = ffmpeg blank "0xffffff" $dims.width $dims.height -o @rand
                [$front, $back] | ffmpeg combine $VSTACKING --output @rand
            },
            [   _, null] => {
                let dims = $front | ffmpeg metadata | get streams | select width height
                let back = ffmpeg blank "0xffffff" $dims.width $dims.height -o @rand
                [$front, $back] | ffmpeg combine $VSTACKING --output @rand
            },
            [   _,    _] => {
                [$front, $back] | ffmpeg combine $VSTACKING --output @rand
            },
        }
    }
    | flatten
    | ^$viewer.cmd ...$viewer.args ...$in
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

def "main inspect" [] {
    ls $OUT_DIR --short-names
        | get name
        | parse --regex "(?<hash>[0-9a-fA-F]*)-(?<dirty>dirty-)?(?<filename>.*)"
        | update dirty { not ($in == "") }
        | to json
}
