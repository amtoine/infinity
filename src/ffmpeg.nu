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

export const FFMPEG_OPTS = [ -y -hide_banner -loglevel quiet ]

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
    $"($in.kind)=($options)"
}

export def "ffmpeg create" [
    transform: string,
    --output: path = "output.jpg",
    --options: list<string> = $FFMPEG_OPTS,
]: [ nothing -> path ] {
    {
        transform: $"(ansi yellow)($transform)(ansi reset)",
        output: $"(ansi purple)($output)(ansi reset)",
    } | log trace $"null --($in.transform)--> ($in.output)"

    try {
        ffmpeg ...$options -f lavfi -i $transform -frames:v 1 $output
    } catch { |e|
        error make --unspanned { msg: $e.msg }
    }
    $output
}

export def "ffmpeg blank" [
    color: string,
    width: int,
    height: int,
    --output: path = "output.jpg",
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
    | ffmpeg create $in --output $output --options $options
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
    } | log trace $"($in.in) --($in.transform)--> ($in.output)"

    $in | try {
        ffmpeg ...$options -i $in -vf $transform $output
    } catch { |e|
        error make --unspanned { msg: $e.msg }
    }
    $output
}

export def "ffmpeg mapply" [
    transforms: list<string>,
    --output: path = "output.jpg",
    --options: list<string> = $FFMPEG_OPTS,
]: [ any -> path ] {
    let input = $in

    let t = $input | describe --detailed
    match $t.type {
        "nothing" => {},
        "string" => {},
        _ => { error make --unspanned {
            msg: $"expected input to be either a (ansi green)path(ansi reset) or (ansi green)nothing(ansi reset), found (ansi red)($t.type)(ansi reset)"
        }},
    }

    $transforms | reduce --fold $input { |it, acc|
        let output = mktemp --tmpdir "ffmpeg-mapply-XXXXXXX.png"
        if $acc == null {
            ffmpeg create $it --output $output
        } else {
            $acc | ffmpeg apply $it --output $output
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
    --output: path = "output.jpg",
    --options: list<string> = $FFMPEG_OPTS,
]: [ list<path> -> path ] {
    {
        in: ($in | each { $'(ansi purple)($in)(ansi reset)' } | str join ', '),
        transform: $"(ansi yellow)($transform)(ansi reset)",
        output: $"(ansi purple)($output)(ansi reset)",
    } | log trace $"($in.in) --($in.transform)--> ($in.output)"

    $in | try {
        ffmpeg ...$options ...($in | each {[ "-i", $in ]} | flatten) -filter_complex $transform $output
    } catch { |e|
        error make --unspanned { msg: $e.msg }
    }
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
