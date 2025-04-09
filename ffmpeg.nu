export-env {
    const VERSION = {
        "version": "0.102.0",
        "commit_hash": "1aa2ed1947a0b891398558fcf4e4289849cc5a1d",
    }
    if (version | select version commit_hash) != $VERSION {
        print $"(ansi yellow_bold)Warning(ansi reset): unexpected version"
        print $"    expected (ansi green)($VERSION.version)@($VERSION.commit_hash)(ansi reset)"
        print $"    found    (ansi red)((version).version)@((version).commit_hash)(ansi reset)"
    }
}

export const PADDING = "pad=width=iw:height=ih+64:y=32:color=white"
export const FLIPPING = "vflip,hflip"
export const STACKING = "[0][1]hstack=inputs=2"

export const FFMPEG_OPTS = [ -y -hide_banner -loglevel quiet ]

def "log info" [msg: string] {
    print $"[(ansi cyan)INFO(ansi reset)] ($msg)"
}

export def "ffmpeg blank" [
    color: string,
    width: int,
    height: int,
    --output: path = "output.jpg",
    --options: list<string> = $FFMPEG_OPTS,
]: [ nothing -> path ] {
    ffmpeg ...$options -f lavfi -i $"color=c=($color):s=($width)x($height):d=1" -frames:v 1 $output
    $output
}

export def "ffmpeg apply" [
    transform: string,
    --output: path = "output.jpg",
    --options: list<string> = $FFMPEG_OPTS,
]: [ path -> path ] {
    {
        in: $"(ansi purple)($in)(ansi reset)",
        transform: $"(ansi yellow)($transform)(ansi reset)",
        output: $"(ansi purple)($output)(ansi reset)",
    } | log info $"($in.in) --($in.transform)--> ($in.output)"

    ffmpeg ...$options -i $in -vf $transform $output
    $output
}

export def "ffmpeg combine" [
    transform: string,
    --output: path = "output.jpg",
    --options: list<string> = $FFMPEG_OPTS,
]: [ list<path> -> path ] {
    {
        in: ($in | each { $'(ansi purple)($in)(ansi reset)' } | str join ', '),
        transform: $"(ansi yellow)($transform)(ansi reset)",
        output: $"(ansi purple)($output)(ansi reset)",
    } | log info $"($in.in) --($in.transform)--> ($in.output)"

    ffmpeg ...$options ...($in | each {[ "-i", $in ]} | flatten) -filter_complex $transform $output
    $output
}
