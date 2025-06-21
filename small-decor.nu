use stl.nu
use std math
use geometry.nu [ "pt at-angle", "pt scale", "pt shift", "pt rotate" ]

def main [
    length    : number,
    width     : number,
    thickness : number,
    a         : number,
    b         : number,
    x         : number,
] {
    let scale = $math.tau / 3 | {
        c: ($in | math cos),
        s: ($in | math sin),
    }
        | (1 - $in.c) ** 2 + ($in.s) ** 2
        | math sqrt
        | $width / $in

    # let y = (1 + ($math.tau / 3 | math cos | math abs) + ($x / $scale)) * ($math.tau / 12 | math tan)
    let y = (
        ($math.tau / 3 | math sin) *
        (1 + ($math.tau / 3 | math cos | math abs) + ($x / $scale)) /
        (1 + ($math.tau / 3 | math cos | math abs))
    )

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
        { x: (($math.tau / 3 | math cos) - ($x / $scale)), y: ($y * +1) },
        { x: (($math.tau / 3 | math cos) - ($x / $scale)), y: ($y * -1) },

        { x: (($math.tau / 3 | math cos) + ($thickness / $scale) / 2) , y: (+1.0 * ($b / $scale) / 2) },
        { x: (($math.tau / 3 | math cos) - ($thickness / $scale) / 2) , y: (+1.0 * ($b / $scale) / 2) },
        { x: (($math.tau / 3 | math cos) - ($thickness / $scale) / 2) , y: (-1.0 * ($b / $scale) / 2) },
        { x: (($math.tau / 3 | math cos) + ($thickness / $scale) / 2) , y: (-1.0 * ($b / $scale) / 2) },
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
        | stl solid $in --output small-plate.stl

    stl bar-with-thingies {
        length : $length,
        width  : $width,
        a      : $a,
        b      : $b,
        h      : $thickness,
    }
        | stl solid $in --output small-longside.stl
}
