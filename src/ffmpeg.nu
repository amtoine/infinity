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

use log.nu [ "log trace" ]

export const PADDING = "pad=width=iw:height=ih+64:y=32:color=white"
export const FLIPPING = "vflip,hflip"
export const HSTACKING = "[0][1]hstack=inputs=2"
export const VSTACKING = "[0][1]vstack=inputs=2"

export const FFMPEG_OPTS = [ -y -hide_banner -loglevel warning ]

def --wrapped run-with-error [cmd: string, ...args: string] {
    let ret = $in | ^$cmd ...$args | complete
    if $ret.exit_code != 0 {
        error make --unspanned { msg: $ret.stderr }
    }
}

export def "ffmpeg metadata" []: [
    path -> record<
        streams: record<index: int,
            codec_name: string,
            codec_long_name: string,
            codec_type: string,
            codec_tag_string: string,
            codec_tag: string,
            width: int,
            height: int,
            coded_width: int,
            coded_height: int,
            closed_captions: int,
            has_b_frames: int,
            sample_aspect_ratio: string,
            display_aspect_ratio: string,
            pix_fmt: string,
            level: int,
            color_range: string,
            refs: int,
            r_frame_rate: string,
            avg_frame_rate: string,
            time_base: string,
            disposition: record<
                default: int,
                dub: int,
                original: int,
                comment: int,
                lyrics: int,
                karaoke: int,
                forced: int,
                hearing_impaired: int,
                visual_impaired: int,
                clean_effects: int,
                attached_pic: int,
                timed_thumbnails: int,
            >,
        >,
        format: record<filename: string,
            nb_streams: int,
            nb_programs: int,
            format_name: string,
            format_long_name: string,
            size: string,
            probe_score: int>,
    >
] {
    ffprobe -v quiet -print_format json -show_format -show_streams $in | from json | update streams { into record }
}

export def "ffmpeg options" []: [ record<kind: string, options: record> -> string ] {
    let options = $in.options | items { |k, v| $"($k)=($v)" } | str join ":"
    $"($in.pre?)($in.kind)=($options)($in.post?)"
}

export def "ffmpeg pre" [options: record] {
    let options = $options | items { |k, v| $"($k)=($v)" } | str join ","
    $"[1:v]($options)[ovrl], [0:v][ovrl]"
}

def output-path [output: string, --extension: string]: [ nothing -> path ] {
    match $output {
        "@auto" | "" => { $"output.($extension)" | path expand },
        "@rand"      => { mktemp --tmpdir $"XXXXXXX.($extension)" },
        _            => { $output | path expand },
    }
}

export def "ffmpeg create" [
    transform: string,
    --output (-o): string = "",
    --extension (-e): string = "png",
    --options: list<string> = $FFMPEG_OPTS,
]: [ nothing -> path ] {
    let output = output-path $output --extension $extension

    {
        transform: $"(ansi yellow)($transform)(ansi reset)",
        output: $"(ansi purple)($output)(ansi reset)",
    } | log trace $"null --($in.transform)--> ($in.output)"

    run-with-error ffmpeg ...$options -filter_complex $transform -frames:v 1 $output
    $output
}

export def "ffmpeg blank" [
    color: string,
    width: int,
    height: int,
    --output (-o): string = "",
    --extension (-e): string = "png",
    --options: list<string> = $FFMPEG_OPTS,
]: [ nothing -> path ] {
    {
        kind: "color",
        options: {
            c: $color,
            s: $"($width)x($height)",
            d: 1,
        },
    }
    | ffmpeg options
    | ffmpeg create $in --output $output --extension $extension --options $options
}

export def "ffmpeg apply" [
    transform: string,
    --output (-o): string = "",
    --extension (-e): string = "png",
    --options: list<string> = $FFMPEG_OPTS,
]: [ path -> path ] {
    let output = output-path $output --extension $extension

    {
        in: $"(ansi purple)($in)(ansi reset)",
        transform: $"(ansi yellow)($transform)(ansi reset)",
        output: $"(ansi purple)($output)(ansi reset)",
    } | log trace $"($in.in) --($in.transform)--> ($in.output)"

    $in | run-with-error ffmpeg ...$options -i $in -vf $transform $output
    $output
}

export def "ffmpeg mapply" [
    transforms: list<string>,
    --output (-o): string = "",
    --extension (-e): string = "png",
    --options: list<string> = $FFMPEG_OPTS,
]: [ any -> path ] {
    let input = $in
    let output = output-path $output --extension $extension

    let t = $input | describe --detailed
    match $t.type {
        "nothing" => {},
        "string" => {},
        _ => { error make --unspanned {
            msg: $"expected input to be either a (ansi green)path(ansi reset) or (ansi green)nothing(ansi reset), found (ansi red)($t.type)(ansi reset)"
        }},
    }

    let res = $transforms | reduce --fold $input { |it, acc|
        if $acc == null {
            ffmpeg create $it -o @rand -e $extension
        } else {
            $acc | ffmpeg apply $it -o @rand -e $extension
        }
    }

    {
        in: $"(ansi purple)($res)(ansi reset)",
        output: $"(ansi purple)($output)(ansi reset)",
    } | log trace $"($in.in) --> ($in.output)"
    cp $res $output
    $output
}

export def "ffmpeg combine" [
    transform: string,
    --output (-o): string = "",
    --extension (-e): string = "png",
    --options: list<string> = $FFMPEG_OPTS,
]: [ list<path> -> path ] {
    let output = output-path $output --extension $extension

    {
        in: ($in | each { $'(ansi purple)($in)(ansi reset)' } | str join ', '),
        transform: $"(ansi yellow)($transform)(ansi reset)",
        output: $"(ansi purple)($output)(ansi reset)",
    } | log trace $"($in.in) --($in.transform)--> ($in.output)"

    $in | each {[ "-i", $in ]} | flatten | run-with-error ffmpeg ...[
        ...$options
        ...$in
        -filter_complex $transform
        $output
    ]

    $output
}

export def "ffmpeg transform text" [text: string, color: string, size: float, pos: record<x: int, y: int>]: [
    nothing -> record<kind: string, options: record>
] { {
    kind: "drawtext",
    options: {
        text: $text,
        fontcolor: $color,
        fontsize: $size,
        x: $pos.x,
        y: $pos.y,
    }
} }

export def "ffmpeg transform box" [rect: record<x: int, y: int, w: int, h: int>, color: string, t: string]: [
    nothing -> record<kind: string, options: record>
] { {
    kind: "drawbox",
    options: {
        x: $rect.x,
        y: $rect.y,
        w: $rect.w,
        h: $rect.h,
        color: $color,
        t: $t,
    }
} }
