use stl.nu
use std math
use geometry.nu [ "pt at-angle", "pt scale" ]

def main [diameter: number, height: number, --nb-sides: int = 100, --output (-o): path = "a.stl"] {
    seq 0 ($nb_sides - 1)
        | each { $in / $nb_sides * $math.tau }
        | each { pt at-angle $in
        | pt scale ($diameter / 2) }
        | stl extrude {
            points: $in,
            borders: [ (seq 0 ($nb_sides - 1)) ],
            convex_shapes:  [ (seq 0 ($nb_sides - 1)) ],
            h: $height,
        }
        | stl solid $in --output $output
}
