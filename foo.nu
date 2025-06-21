use stl.nu
use std math

def "pt at-angle" [alpha: number, --modulus: number = 1.0]: [
    nothing -> record<x: number, y: number>
] {{
    x: ($modulus * ($alpha | math cos)),
    y: ($modulus * ($alpha | math sin)),
}}

def "pt rotate" [alpha: number]: [
    record<x: number, y: number> -> record<x: number, y: number>
] {
    let c = $alpha | math cos
    let s = $alpha | math sin
    {
        x: ($in.x * $c - $in.y * $s),
        y: ($in.x * $s + $in.y * $c),
    }
}

def "pt shift" [shift: record<x: number, y: number>]: [
    record<x: number, y: number> -> record<x: number, y: number>
] {{
    x: ($in.x + $shift.x),
    y: ($in.y + $shift.y),
}}

def "pt scale" [scale: number]: [
    record<x: number, y: number> -> record<x: number, y: number>
    record<x: number, y: number, z: number> -> record<x: number, y: number, z: number>
] {
    let input = $in
    let cols = $in | columns
    $cols | reduce --fold $input { |it, acc|
        $acc | update $it { $in * $scale }
    }
}

def main [
    length    : number,
    width     : number,
    thickness : number,
    b         : number,
] {
    let scale = $math.tau / 3 | {
        c: ($in | math cos),
        s: ($in | math sin),
    }
        | (1 - $in.c) ** 2 + ($in.s) ** 2
        | math sqrt
        | $width / $in

    # > [!note] this should be equilateral :eyes:
    #
    #   1.
    #   .....
    #   ........
    #   ...........
    #   ..............
    #   ..4..3...........
    #   ...  ...............
    #   ...  .................0
    #   ...  ...............
    #   ..5..6...........
    #   ..............
    #   ...........
    #   ........
    #   .....
    #   2.
    #
    let points = [
        (pt at-angle (0 * $math.tau / 3) --modulus 1.00),
        (pt at-angle (1 * $math.tau / 3) --modulus 1.30),
        (pt at-angle (2 * $math.tau / 3) --modulus 1.30),

        { x: (($math.tau / 3 | math cos) + ($thickness / $scale) / 2) , y: (+1.0 * $b / 2) },
        { x: (($math.tau / 3 | math cos) - ($thickness / $scale) / 2) , y: (+1.0 * $b / 2) },
        { x: (($math.tau / 3 | math cos) - ($thickness / $scale) / 2) , y: (-1.0 * $b / 2) },
        { x: (($math.tau / 3 | math cos) + ($thickness / $scale) / 2) , y: (-1.0 * $b / 2) },
    ]

    [
        (1 / 12)
        (3 / 12)
        (5 / 12)
    ]
        | each { |a|
            $points
                | each { pt shift { x: -1.0, y: 0.0 } | pt rotate ($a * $math.tau) }
                | stl extrude {
                    points: $in,
                    borders: [
                        [ 0, 1, 2 ],
                        [ 3, 4, 5, 6 ],
                    ],
                    convex_shapes:  [
                        [0, 3, 1],
                        [1, 3, 4],
                        [1, 4, 5, 2],
                        [2, 5, 6],
                        [0, 2, 6],
                        [0, 3, 6],
                    ],
                    h: ($thickness / $scale),
                }
        }
        | flatten
        | each { each { pt scale $scale } }
        | stl solid $in --output plate.stl

    stl bar-with-thingies {
        length : $length,
        width  : $width,
        a      : ($thickness * 5),
        b      : ($b * $scale),
        h      : $thickness,
    }
        | stl solid $in --output long.stl
}
