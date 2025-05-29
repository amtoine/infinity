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
    log trace $"($cmd) ($args | str join ' ')"
    let ret = $in | ^$cmd ...$args | complete
    if $ret.exit_code != 0 {
        error make --unspanned { msg: $ret.stderr }
    }
}

export const ALIGNMENT = {
    top_left     : { x:    "", y:    "" },
    top          : { x: "w/2", y:    "" },
    top_right    : { x:   "w", y:    "" },
    left         : { x:    "", y: "h/2" },
    center       : { x: "w/2", y: "h/2" },
    right        : { x:   "w", y: "h/2" },
    bottom_left  : { x:    "", y:   "h" },
    bottom       : { x: "w/2", y:   "h" },
    bottom_right : { x:   "w", y:   "h" },
}

# from https://ffmpeg.org/ffmpeg-utils.html#toc-Color
const COLORS = {
    "AliceBlue"           : { r: 0xf0, g: 0xf8, b: 0xff, a: 0xff },
    "AntiqueWhite"        : { r: 0xfa, g: 0xeb, b: 0xd7, a: 0xff },
    "Aqua"                : { r: 0x00, g: 0xff, b: 0xff, a: 0xff },
    "Aquamarine"          : { r: 0x7f, g: 0xff, b: 0xd4, a: 0xff },
    "Azure"               : { r: 0xf0, g: 0xff, b: 0xff, a: 0xff },
    "Beige"               : { r: 0xf5, g: 0xf5, b: 0xdc, a: 0xff },
    "Bisque"              : { r: 0xff, g: 0xe4, b: 0xc4, a: 0xff },
    "Black"               : { r: 0x00, g: 0x00, b: 0x00, a: 0xff },
    "BlanchedAlmond"      : { r: 0xff, g: 0xeb, b: 0xcd, a: 0xff },
    "Blue"                : { r: 0x00, g: 0x00, b: 0xff, a: 0xff },
    "BlueViolet"          : { r: 0x8a, g: 0x2b, b: 0xe2, a: 0xff },
    "Brown"               : { r: 0xa5, g: 0x2a, b: 0x2a, a: 0xff },
    "BurlyWood"           : { r: 0xde, g: 0xb8, b: 0x87, a: 0xff },
    "CadetBlue"           : { r: 0x5f, g: 0x9e, b: 0xa0, a: 0xff },
    "Chartreuse"          : { r: 0x7f, g: 0xff, b: 0x00, a: 0xff },
    "Chocolate"           : { r: 0xd2, g: 0x69, b: 0x1e, a: 0xff },
    "Coral"               : { r: 0xff, g: 0x7f, b: 0x50, a: 0xff },
    "CornflowerBlue"      : { r: 0x64, g: 0x95, b: 0xed, a: 0xff },
    "Cornsilk"            : { r: 0xff, g: 0xf8, b: 0xdc, a: 0xff },
    "Crimson"             : { r: 0xdc, g: 0x14, b: 0x3c, a: 0xff },
    "Cyan"                : { r: 0x00, g: 0xff, b: 0xff, a: 0xff },
    "DarkBlue"            : { r: 0x00, g: 0x00, b: 0x8b, a: 0xff },
    "DarkCyan"            : { r: 0x00, g: 0x8b, b: 0x8b, a: 0xff },
    "DarkGoldenRod"       : { r: 0xb8, g: 0x86, b: 0x0b, a: 0xff },
    "DarkGray"            : { r: 0xa9, g: 0xa9, b: 0xa9, a: 0xff },
    "DarkGreen"           : { r: 0x00, g: 0x64, b: 0x00, a: 0xff },
    "DarkKhaki"           : { r: 0xbd, g: 0xb7, b: 0x6b, a: 0xff },
    "DarkMagenta"         : { r: 0x8b, g: 0x00, b: 0x8b, a: 0xff },
    "DarkOliveGreen"      : { r: 0x55, g: 0x6b, b: 0x2f, a: 0xff },
    "Darkorange"          : { r: 0xff, g: 0x8c, b: 0x00, a: 0xff },
    "DarkOrchid"          : { r: 0x99, g: 0x32, b: 0xcc, a: 0xff },
    "DarkRed"             : { r: 0x8b, g: 0x00, b: 0x00, a: 0xff },
    "DarkSalmon"          : { r: 0xe9, g: 0x96, b: 0x7a, a: 0xff },
    "DarkSeaGreen"        : { r: 0x8f, g: 0xbc, b: 0x8f, a: 0xff },
    "DarkSlateBlue"       : { r: 0x48, g: 0x3d, b: 0x8b, a: 0xff },
    "DarkSlateGray"       : { r: 0x2f, g: 0x4f, b: 0x4f, a: 0xff },
    "DarkTurquoise"       : { r: 0x00, g: 0xce, b: 0xd1, a: 0xff },
    "DarkViolet"          : { r: 0x94, g: 0x00, b: 0xd3, a: 0xff },
    "DeepPink"            : { r: 0xff, g: 0x14, b: 0x93, a: 0xff },
    "DeepSkyBlue"         : { r: 0x00, g: 0xbf, b: 0xff, a: 0xff },
    "DimGray"             : { r: 0x69, g: 0x69, b: 0x69, a: 0xff },
    "DodgerBlue"          : { r: 0x1e, g: 0x90, b: 0xff, a: 0xff },
    "FireBrick"           : { r: 0xb2, g: 0x22, b: 0x22, a: 0xff },
    "FloralWhite"         : { r: 0xff, g: 0xfa, b: 0xf0, a: 0xff },
    "ForestGreen"         : { r: 0x22, g: 0x8b, b: 0x22, a: 0xff },
    "Fuchsia"             : { r: 0xff, g: 0x00, b: 0xff, a: 0xff },
    "Gainsboro"           : { r: 0xdc, g: 0xdc, b: 0xdc, a: 0xff },
    "GhostWhite"          : { r: 0xf8, g: 0xf8, b: 0xff, a: 0xff },
    "Gold"                : { r: 0xff, g: 0xd7, b: 0x00, a: 0xff },
    "GoldenRod"           : { r: 0xda, g: 0xa5, b: 0x20, a: 0xff },
    "Gray"                : { r: 0x80, g: 0x80, b: 0x80, a: 0xff },
    "Green"               : { r: 0x00, g: 0x80, b: 0x00, a: 0xff },
    "GreenYellow"         : { r: 0xad, g: 0xff, b: 0x2f, a: 0xff },
    "HoneyDew"            : { r: 0xf0, g: 0xff, b: 0xf0, a: 0xff },
    "HotPink"             : { r: 0xff, g: 0x69, b: 0xb4, a: 0xff },
    "IndianRed"           : { r: 0xcd, g: 0x5c, b: 0x5c, a: 0xff },
    "Indigo"              : { r: 0x4b, g: 0x00, b: 0x82, a: 0xff },
    "Ivory"               : { r: 0xff, g: 0xff, b: 0xf0, a: 0xff },
    "Khaki"               : { r: 0xf0, g: 0xe6, b: 0x8c, a: 0xff },
    "Lavender"            : { r: 0xe6, g: 0xe6, b: 0xfa, a: 0xff },
    "LavenderBlush"       : { r: 0xff, g: 0xf0, b: 0xf5, a: 0xff },
    "LawnGreen"           : { r: 0x7c, g: 0xfc, b: 0x00, a: 0xff },
    "LemonChiffon"        : { r: 0xff, g: 0xfa, b: 0xcd, a: 0xff },
    "LightBlue"           : { r: 0xad, g: 0xd8, b: 0xe6, a: 0xff },
    "LightCoral"          : { r: 0xf0, g: 0x80, b: 0x80, a: 0xff },
    "LightCyan"           : { r: 0xe0, g: 0xff, b: 0xff, a: 0xff },
    "LightGoldenRodYellow": { r: 0xfa, g: 0xfa, b: 0xd2, a: 0xff },
    "LightGreen"          : { r: 0x90, g: 0xee, b: 0x90, a: 0xff },
    "LightGrey"           : { r: 0xd3, g: 0xd3, b: 0xd3, a: 0xff },
    "LightPink"           : { r: 0xff, g: 0xb6, b: 0xc1, a: 0xff },
    "LightSalmon"         : { r: 0xff, g: 0xa0, b: 0x7a, a: 0xff },
    "LightSeaGreen"       : { r: 0x20, g: 0xb2, b: 0xaa, a: 0xff },
    "LightSkyBlue"        : { r: 0x87, g: 0xce, b: 0xfa, a: 0xff },
    "LightSlateGray"      : { r: 0x77, g: 0x88, b: 0x99, a: 0xff },
    "LightSteelBlue"      : { r: 0xb0, g: 0xc4, b: 0xde, a: 0xff },
    "LightYellow"         : { r: 0xff, g: 0xff, b: 0xe0, a: 0xff },
    "Lime"                : { r: 0x00, g: 0xff, b: 0x00, a: 0xff },
    "LimeGreen"           : { r: 0x32, g: 0xcd, b: 0x32, a: 0xff },
    "Linen"               : { r: 0xfa, g: 0xf0, b: 0xe6, a: 0xff },
    "Magenta"             : { r: 0xff, g: 0x00, b: 0xff, a: 0xff },
    "Maroon"              : { r: 0x80, g: 0x00, b: 0x00, a: 0xff },
    "MediumAquaMarine"    : { r: 0x66, g: 0xcd, b: 0xaa, a: 0xff },
    "MediumBlue"          : { r: 0x00, g: 0x00, b: 0xcd, a: 0xff },
    "MediumOrchid"        : { r: 0xba, g: 0x55, b: 0xd3, a: 0xff },
    "MediumPurple"        : { r: 0x93, g: 0x70, b: 0xd8, a: 0xff },
    "MediumSeaGreen"      : { r: 0x3c, g: 0xb3, b: 0x71, a: 0xff },
    "MediumSlateBlue"     : { r: 0x7b, g: 0x68, b: 0xee, a: 0xff },
    "MediumSpringGreen"   : { r: 0x00, g: 0xfa, b: 0x9a, a: 0xff },
    "MediumTurquoise"     : { r: 0x48, g: 0xd1, b: 0xcc, a: 0xff },
    "MediumVioletRed"     : { r: 0xc7, g: 0x15, b: 0x85, a: 0xff },
    "MidnightBlue"        : { r: 0x19, g: 0x19, b: 0x70, a: 0xff },
    "MintCream"           : { r: 0xf5, g: 0xff, b: 0xfa, a: 0xff },
    "MistyRose"           : { r: 0xff, g: 0xe4, b: 0xe1, a: 0xff },
    "Moccasin"            : { r: 0xff, g: 0xe4, b: 0xb5, a: 0xff },
    "NavajoWhite"         : { r: 0xff, g: 0xde, b: 0xad, a: 0xff },
    "Navy"                : { r: 0x00, g: 0x00, b: 0x80, a: 0xff },
    "OldLace"             : { r: 0xfd, g: 0xf5, b: 0xe6, a: 0xff },
    "Olive"               : { r: 0x80, g: 0x80, b: 0x00, a: 0xff },
    "OliveDrab"           : { r: 0x6b, g: 0x8e, b: 0x23, a: 0xff },
    "Orange"              : { r: 0xff, g: 0xa5, b: 0x00, a: 0xff },
    "OrangeRed"           : { r: 0xff, g: 0x45, b: 0x00, a: 0xff },
    "Orchid"              : { r: 0xda, g: 0x70, b: 0xd6, a: 0xff },
    "PaleGoldenRod"       : { r: 0xee, g: 0xe8, b: 0xaa, a: 0xff },
    "PaleGreen"           : { r: 0x98, g: 0xfb, b: 0x98, a: 0xff },
    "PaleTurquoise"       : { r: 0xaf, g: 0xee, b: 0xee, a: 0xff },
    "PaleVioletRed"       : { r: 0xd8, g: 0x70, b: 0x93, a: 0xff },
    "PapayaWhip"          : { r: 0xff, g: 0xef, b: 0xd5, a: 0xff },
    "PeachPuff"           : { r: 0xff, g: 0xda, b: 0xb9, a: 0xff },
    "Peru"                : { r: 0xcd, g: 0x85, b: 0x3f, a: 0xff },
    "Pink"                : { r: 0xff, g: 0xc0, b: 0xcb, a: 0xff },
    "Plum"                : { r: 0xdd, g: 0xa0, b: 0xdd, a: 0xff },
    "PowderBlue"          : { r: 0xb0, g: 0xe0, b: 0xe6, a: 0xff },
    "Purple"              : { r: 0x80, g: 0x00, b: 0x80, a: 0xff },
    "Red"                 : { r: 0xff, g: 0x00, b: 0x00, a: 0xff },
    "RosyBrown"           : { r: 0xbc, g: 0x8f, b: 0x8f, a: 0xff },
    "RoyalBlue"           : { r: 0x41, g: 0x69, b: 0xe1, a: 0xff },
    "SaddleBrown"         : { r: 0x8b, g: 0x45, b: 0x13, a: 0xff },
    "Salmon"              : { r: 0xfa, g: 0x80, b: 0x72, a: 0xff },
    "SandyBrown"          : { r: 0xf4, g: 0xa4, b: 0x60, a: 0xff },
    "SeaGreen"            : { r: 0x2e, g: 0x8b, b: 0x57, a: 0xff },
    "SeaShell"            : { r: 0xff, g: 0xf5, b: 0xee, a: 0xff },
    "Sienna"              : { r: 0xa0, g: 0x52, b: 0x2d, a: 0xff },
    "Silver"              : { r: 0xc0, g: 0xc0, b: 0xc0, a: 0xff },
    "SkyBlue"             : { r: 0x87, g: 0xce, b: 0xeb, a: 0xff },
    "SlateBlue"           : { r: 0x6a, g: 0x5a, b: 0xcd, a: 0xff },
    "SlateGray"           : { r: 0x70, g: 0x80, b: 0x90, a: 0xff },
    "Snow"                : { r: 0xff, g: 0xfa, b: 0xfa, a: 0xff },
    "SpringGreen"         : { r: 0x00, g: 0xff, b: 0x7f, a: 0xff },
    "SteelBlue"           : { r: 0x46, g: 0x82, b: 0xb4, a: 0xff },
    "Tan"                 : { r: 0xd2, g: 0xb4, b: 0x8c, a: 0xff },
    "Teal"                : { r: 0x00, g: 0x80, b: 0x80, a: 0xff },
    "Thistle"             : { r: 0xd8, g: 0xbf, b: 0xd8, a: 0xff },
    "Tomato"              : { r: 0xff, g: 0x63, b: 0x47, a: 0xff },
    "Turquoise"           : { r: 0x40, g: 0xe0, b: 0xd0, a: 0xff },
    "Violet"              : { r: 0xee, g: 0x82, b: 0xee, a: 0xff },
    "Wheat"               : { r: 0xf5, g: 0xde, b: 0xb3, a: 0xff },
    "White"               : { r: 0xff, g: 0xff, b: 0xff, a: 0xff },
    "WhiteSmoke"          : { r: 0xf5, g: 0xf5, b: 0xf5, a: 0xff },
    "Yellow"              : { r: 0xff, g: 0xff, b: 0x00, a: 0xff },
    "YellowGreen"         : { r: 0x9a, g: 0xcd, b: 0x32, a: 0xff },
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
    let res = ffprobe -v quiet -print_format json -show_format -show_streams $in | from json
    if $res == {} {
        $res
    } else {
        $res | update streams { into record }
    }
}

export def "ffmpeg options" []: [ record<kind: string, options: record> -> string ] {
    let options = $in.options | items { |k, v| $"($k)=($v)" } | str join ":"
    $"($in.pre?)($in.kind)=($options)($in.post?)"
}

export def "ffmpeg pre" [options: record]: [ nothing -> string ] {
    let options = $options | items { |k, v| $"($k)=($v)" } | str join ","
    $"[1:v]($options)[ovrl],[0:v][ovrl]"
}

def output-path [output: string, --extension: string]: [ nothing -> path ] {
    $output
        | str replace --all "@auto" $"output.($extension)"
        | str replace --all "@rand" (random uuid | hash sha256)
        | str replace --all "@ext" $extension
        | path expand
}

export def "ffmpeg create" [
    transform: string,
    --output (-o): string = "@auto",
    --extension (-e): string = "png",
    --options: list<string> = $FFMPEG_OPTS,
]: [ nothing -> path ] {
    let output = output-path $output --extension $extension

    run-with-error ffmpeg ...$options -filter_complex $transform -frames:v 1 $output
    $output
}

def "parse color" [
    --span: record<start: int, end: int>
]: [ any -> record<r: int, g: int, b: int, a: int> ] {
    let input = $in
    match ($input | describe --detailed).type {
        "string" => {
            if ($COLORS | get --ignore-errors $input) != null {
                return ($COLORS | get $input)
            }

            $input | str-to-color --span $span
        },
        "record" => {
            let input = $input | default 0xff a

            let columns = $input | describe --detailed | get columns
            let error = if ("r" not-in $columns) or ("g" not-in $columns) or ("b" not-in $columns) { {
                msg: $"(ansi red_bold)invalid_record_color(ansi reset)",
                label: {
                    span: $span,
                    text: $"tried to parse color from (ansi cyan)($input)(ansi reset)",
                },
                help: $"record color should have fields (ansi cyan)r(ansi reset), (ansi cyan)r(ansi reset) and (ansi cyan)b(ansi reset)",
            } } else if ($columns.r != "int") or ($columns.g != "int") or ($columns.b != "int") or ($columns.a != "int") { {
                msg: $"(ansi red_bold)invalid_record_color(ansi reset)",
                label: {
                    span: $span,
                    text: $"tried to parse color from (ansi cyan)($input)(ansi reset)",
                },
                help: "record color should have integer fields",
            } } else {
                null
            }
            if $error != null {
                if $span == null {
                    error make { msg: $"($error.msg)\n\t($error.label.text)\n\t($error.help)"}
                } else {
                    error make $error
                }
            }

            $input
        },
        "int" => {
            if $input < 0 or $input > 0xffffffff {
                let error = {
                    msg: $"(ansi red_bold)invalid_int_color(ansi reset)",
                    label: {
                        span: $span,
                        text: $"tried to parse color from (ansi cyan)($input)(ansi reset) \(($input | format number | get lowerhex)\)",
                    },
                    help: $"int color should be between (ansi cyan)0(ansi reset) and (ansi cyan)(0xffffffff)(ansi reset)",
                }
                if $span == null {
                    error make { msg: $"($error.msg)\n\t($error.label.text)\n\t($error.help)"}
                } else {
                    error make $error
                }
            }

            $input | format number | get lowerhex | str-to-color
        },
        _ => {
            let error = {
                msg: $"(ansi red_bold)invalid_color(ansi reset)",
                label: {
                    span: $span,
                    text: $"tried to parse color from type '(ansi cyan)($input | describe)(ansi reset)'",
                },
                help: "color should be either a string, an int or a record",
            }
            if $span == null {
                error make { msg: $"($error.msg)\n\t($error.label.text)\n\t($error.help)"}
            } else {
                error make $error
            }
        }
    }
}

def "str-to-color" [
    --span: record<start: int, end: int>,
]: [ string -> record<r: int, g: int, b: int, a: int> ] {
    let input = $in

    let color = if ($input | str starts-with "#") {
        $input | str substring 1.. | str downcase
    } else if ($input | str starts-with "0x") {
        $input | str substring 2.. | str downcase
    } else {
        let error = {
            msg: $"(ansi red_bold)invalid_string_color(ansi reset)",
            label: {
                span: $span,
                text: $"tried to parse color from '(ansi cyan)($input)(ansi reset)'",
            },
            help: $"string color should start with '(ansi cyan)#(ansi reset)' or '(ansi cyan)0x(ansi reset)'",
        }
        if $span == null {
            error make { msg: $"($error.msg)\n\t($error.label.text)\n\t($error.help)"}
        } else {
            error make $error
        }
    }

    let rgba = match ($color | str length) {
        6 => { $color ++ "ff" },
        8 => $color,
        _ => {
            let error = {
                msg: $"(ansi red_bold)invalid_string_color(ansi reset)",
                label: {
                    span: $span,
                    text: $"tried to parse color from '(ansi cyan)($input)(ansi reset)'",
                },
                help: "string color should contain 6 (RGB) or 8 (RGBA) digits",
            }
            if $span == null {
                error make { msg: $"($error.msg)\n\t($error.label.text)\n\t($error.help)"}
            } else {
                error make $error
            }
        },
    }

    if ($rgba | split chars | any { |c| $c not-in ((seq char '0' '9') ++ (seq char 'a' 'f'))}) {
        let error = {
            msg: $"(ansi red_bold)invalid_string_color(ansi reset)",
            label: {
                span: $span,
                text: $"tried to parse color from '(ansi cyan)($input)(ansi reset)'",
            },
            help: "string color should contain valid hexadecimal digits",
        }
        if $span == null {
            error make { msg: $"($error.msg)\n\t($error.label.text)\n\t($error.help)"}
        } else {
            error make $error
        }
    }

    $rgba
        | split chars
        | window 2 --stride 2
        | each { str join "" | $"0x($in)" | into int }
        | { r: $in.0, g: $in.1, b: $in.2, a: $in.3 }
}

def "color-to-str" []: [ record<r: int, g: int, b: int, a: int> -> string ] {
    $in.a + $in.b * 0x100 + $in.g * 0x10000 + $in.r * 0x1000000
        | format number
        | get lowerhex
        | str substring 2..
        | fill --alignment right --width 8 --character '0'
        | $"0x($in)"
}

export def "ffmpeg blank" [
    color: any,
    width: int,
    height: int,
    --output (-o): string = "@auto",
    --extension (-e): string = "png",
    --options: list<string> = $FFMPEG_OPTS,
]: [ nothing -> path ] {
    let output = output-path $output --extension $extension
    let color = $color | parse color --span (metadata $color).span

    let color_option = {
        kind: "color",
        options: {
            c: ($color | color-to-str),
            s: $"($width)x($height)",
        },
    }
    let geq_option = {
        kind: "geq",
        options: {
            r: "'r(X,Y)'",
            g: "'g(X,Y)'",
            b: "'b(X,Y)'",
            a: $color.a,
        },
    }

    run-with-error ffmpeg ...[
        ...$options
        -f lavfi
        -i "nullsrc"
        -filter_complex $"($color_option | ffmpeg options),format=rgba,($geq_option | ffmpeg options)"
        -vframes 1
        $output
    ]

    $output
}

export def "ffmpeg apply" [
    transform: string,
    --output (-o): string = "@auto",
    --extension (-e): string = "png",
    --options: list<string> = $FFMPEG_OPTS,
]: [ path -> path ] {
    let output = output-path $output --extension $extension

    $in | run-with-error ffmpeg ...$options -i $in -vf $transform $output
    $output
}

export def "ffmpeg mapply" [
    transforms: list<string>,
    --output (-o): string = "@auto",
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
            ffmpeg create $it -o /tmp/@rand.@ext -e $extension
        } else {
            $acc | ffmpeg apply $it -o /tmp/@rand.@ext -e $extension
        }
    }

    {
        in: $"(ansi purple)($res)(ansi reset)",
        output: $"(ansi purple)($output)(ansi reset)",
    } | log trace $"cp ($in.in) ($in.output)"
    cp $res $output
    $output
}

export def "ffmpeg combine" [
    transform: string,
    --output (-o): string = "@auto",
    --extension (-e): string = "png",
    --options: list<string> = $FFMPEG_OPTS,
]: [ list<path> -> path ] {
    let output = output-path $output --extension $extension

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
