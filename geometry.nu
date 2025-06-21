export def "pt at-angle" [alpha: number, --modulus: number = 1.0]: [
    nothing -> record<x: number, y: number>
] {{
    x: ($modulus * ($alpha | math cos)),
    y: ($modulus * ($alpha | math sin)),
}}

export def "pt rotate" [alpha: number]: [
    record<x: number, y: number> -> record<x: number, y: number>
] {
    let c = $alpha | math cos
    let s = $alpha | math sin
    {
        x: ($in.x * $c - $in.y * $s),
        y: ($in.x * $s + $in.y * $c),
    }
}

export def "pt shift" [shift: record<x: number, y: number>]: [
    record<x: number, y: number> -> record<x: number, y: number>
] {{
    x: ($in.x + $shift.x),
    y: ($in.y + $shift.y),
}}

export def "pt scale" [scale: number]: [
    record<x: number, y: number> -> record<x: number, y: number>
    record<x: number, y: number, z: number> -> record<x: number, y: number, z: number>
] {
    let input = $in
    let cols = $in | columns
    $cols | reduce --fold $input { |it, acc|
        $acc | update $it { $in * $scale }
    }
}
