const FORMATS = {
    jumbo: { wi: 5.00, hi: 3.50, dpi: 200, margin: 40 },
}

const PARAMS = {
    ...$FORMATS.jumbo,
    troopers: [
        "aleph",
        "combined-army",
        "jsa",
        "mercenaries",
        "nomads",
        "o-12",
        "panoceania",
    ]
}

export def run [x: float = 1.0] {
    for t in $PARAMS.troopers {
        bash -c "rm -rf /tmp/*.png"
        nu make.nu troops ...[
            $t
            --stats
            --charts
            -w ($PARAMS.wi * $PARAMS.dpi * $x | into int)
            -h ($PARAMS.hi * $PARAMS.dpi * $x | into int)
            -m ($PARAMS.margin * $x | into int)
        ]
    }

    notify-send "done"
}

export def watch [out: path] {
    clear
    bash -c "rm -rf /tmp/*.png"

    "" | save --force $out
    loop {
        df
            | str replace --regex "Mounted on" "Mountpoint"
            | detect columns
            | rename filesystem size used avail used% mountpoint
            | update size { into int | $in * 1kb }
            | update used { into int | $in * 1kb }
            | update avail { into int | $in * 1kb }
            | where mountpoint == "/tmp"
            | into record
            | to nuon
            | tee { $"($in)\n" | save --append $out }
            | print $in
        sleep 500ms
    }
}

export def plot [plots: table<name: string, data: list<int>>] {
    $plots
        | each { |it|
            $it.data
                | enumerate
                | rename --column { index: x, item: y }
                | { name: $it.name, points: $in }
        }
        | save --force /tmp/graphs.json

    let avail = df
        | str replace --regex "Mounted on" "Mountpoint"
        | detect columns
        | rename filesystem size used avail used% mountpoint
        | update size { into int | $in * 1kb }
        | update used { into int | $in * 1kb }
        | update avail { into int | $in * 1kb }
        | where mountpoint == "/tmp"
        | into record
        | get avail
        | into int

    gplt plot --json-data-file /tmp/graphs.json ...[
        --y-ticks 0 (256 * 1024 * 1024) (512 * 1024 * 1024) (768 * 1024 * 1024) (1024 * 1024 * 1024) ((1024 + 256) * 1024 * 1024)
    ]
}
