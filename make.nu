use log.nu [ "log info" ]
def "main git" [] {
    log info "git config diff.exif.textconv exiftool"
    git config diff.exif.textconv exiftool
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

def "main showcase" [] {
    use build_card.nu

    mkdir out/

    for t in $SHOWCASE {
        let troop_file = { parent: "troops", stem: $t.name, extension: "nuon" } | path join
        let output = { parent: "out", stem: ($t.name | str replace '/' '-'), extension: "png" } | path join

        log info $t.name
        build_card (open $troop_file) --color $t.color --output $output
    }
}

def "main troops" [name: string = ""] {
    use build_card.nu

    mkdir out/

    for t in ($TROOPS | where name =~ $name) {
        let troop_file = { parent: "troops", stem: $t.name, extension: "nuon" } | path join
        let output = { parent: "out", stem: ($t.name | str replace '/' '-'), extension: "png" } | path join

        log info $t.name
        build_card (open $troop_file) --color $t.color --output $output
    }
}

def "main" [] {}
