export def facet [
    a: record<x: number, y: number, z: number>,
    b: record<x: number, y: number, z: number>,
    c: record<x: number, y: number, z: number>,
]: [ nothing -> list<string> ] {
    [
        $"facet normal 0 0 0"
        $" outer loop"
        $"  vertex ($a.x) ($a.y) ($a.z)"
        $"  vertex ($b.x) ($b.y) ($b.z)"
        $"  vertex ($c.x) ($c.y) ($c.z)"
        $" endloop"
        $"endfacet"
    ]
}

export def solid [
    facets: list<list<record<x: number, y: number, z: number>>>,
    --output (-o): path = "a.stl",
    --name (-n): string = "my_solid",
] {
    [
        $"solid ($name)",
        ...($facets | each { facet $in.0 $in.1 $in.2 } | flatten),
        $"endsolid ($name)",
    ]
        | str join "\n"
        | save --force $output
}

# An example of a perfect cube with corner labeling:
#   .
#   .
#   .          H-------------------G
#   .         /                   /|
#   .        / |                 / |
#   .       /                   /  |
#   .      E-------------------F   |
#   .      |                   |   |
#   .      |   |               |   |
#   .      |                   |   |
#   .      |   |               |   |
#   .      |                   |   |
#   .      |   D  -  -  -  -  -| - C
#   .      |                   |  /
#   .      | /                 | /
#   .      |                   |/
#   .      A-------------------B
#   .
#   .
export def prism [
    a: record<x: number, y: number, z: number>,
    b: record<x: number, y: number, z: number>,
    c: record<x: number, y: number, z: number>,
    d: record<x: number, y: number, z: number>,
    e: record<x: number, y: number, z: number>,
    f: record<x: number, y: number, z: number>,
    g: record<x: number, y: number, z: number>,
    h: record<x: number, y: number, z: number>,
]: [ nothing -> list<list<record<x: number, y: number, z: number>>> ] {
    [
        [$a, $b, $c], # bottom.1
        [$c, $d, $a], # bottom.2
        [$e, $f, $g], # top.1
        [$g, $h, $e], # top.2
        [$a, $b, $f], # front.1
        [$f, $e, $a], # front.2
        [$d, $c, $g], # back.1
        [$g, $h, $d], # back.2
        [$a, $d, $h], # left.1
        [$h, $e, $a], # left.2
        [$b, $c, $g], # right.1
        [$g, $f, $b], # right.2
    ]
}

# - an example of shape, with height 0.1
#
#
#              7-----------------------6     ^
#              |                       |     | 0.5
#              |                       |     v
#          9---8                       5---4   ^
#          |                               |   |
#          |                               |   |
#          |                               |   | 1.0
#          |                               |   |
#         10--11                       2---3   v
#              |                       |     ^
#              |                       |     | 0.5
#   (-1, -1) = 0-----------------------1     v
#           <-> <---------------------> <->
#           0.5           2.0           0.5
#
#
# - the code
# ```
# [
#    { x: -1.0000, y: -1.0000 },
#    { x: +1.0000, y: -1.0000 },
#    { x: +1.0000, y: -0.5000 },
#    { x: +1.5000, y: -0.5000 },
#    { x: +1.5000, y: +0.5000 },
#    { x: +1.0000, y: +0.5000 },
#    { x: +1.0000, y: +1.0000 },
#    { x: -1.0000, y: +1.0000 },
#    { x: -1.0000, y: +0.5000 },
#    { x: -1.5000, y: +0.5000 },
#    { x: -1.5000, y: -0.5000 },
#    { x: -1.0000, y: -0.5000 },
# ] | stl extrude {
#     points: $in,
#     borders: [[ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11 ]],
#     convex_shapes: [
#         [ 0, 1, 6, 7 ],
#         [ 2, 3, 4, 5 ],
#         [ 8, 9, 10, 11 ],
#     ],
#     h: 0.1000,
# }
# ```
export def extrude [
    shape: record<
        points: list<record<x: number, y: number>>,
        borders: list<list<int>>,
        convex_shapes: list<list<int>>,
        h: float,
    >
]: [ nothing -> list<list<record<x: number, y: number, z: number>>> ] {
    let top_bottom = $shape.convex_shapes
        | each { |cs|
            $cs | skip 1 | window 2 | each { prepend $cs.0 }
        }
        | flatten
        | each { |f| $shape.points | select ...$f }

    [
        ...(
            $shape.borders | each { |border|
                $border
                    | zip ($border | skip 1 | append $border.0)
                    | each { |it|
                        #
                        #     C-------------------D
                        #     |                   |  ^
                        #     |                   |  |
                        #     |                   |  |  h
                        #     |                   |  |
                        #     |                   |  v
                        #     A-------------------B
                        #
                        let a = $shape.points | get $it.0 | insert z { 0.0000 }
                        let b = $shape.points | get $it.1 | insert z { 0.0000 }
                        let c = $shape.points | get $it.0 | insert z { $shape.h }  # extruded version of a
                        let d = $shape.points | get $it.1 | insert z { $shape.h }  # extruded version of b

                        [
                            [$a, $b, $c],
                            [$b, $d, $c],
                        ]
                    }
                    | flatten
                }
                | flatten
        ),
        ...($top_bottom | each { insert z { 0.0000 } }),
        ...($top_bottom | each { insert z { $shape.h } }),
    ]
}

#
#
#           +---------------------------------------+     ^
#           |                                       |     |
#           |                                       |     |
#       +---+                                       +---+ |
#     ^ |                                               | |
#   b | |                                               | | width
#     v |                                               | |
#       +---+                                       +---+ |
#           |                                       |     |
#           |                                       |     |
#           +---------------------------------------+     v
#        <-> <-------------------------------------> <->
#         a                  length                   a
#
#
export def bar-with-thingies [
    shape: record<
        length: float,
        width: float,
        a: float,
        b: float,
        h: float,
    >
]: [ nothing -> list<list<record<x: number, y: number, z: number>>> ] {
    let l = $shape.length
    let a = $shape.a
    let b = $shape.b
    let w = $shape.width
    let w_1 = ($w - $b) / 2
    let w_2 = ($w + $b) / 2

    [
       { x:       0.0 , y:  0.0 },
       { x:        $l , y:  0.0 },
       { x:        $l , y: $w_1 },
       { x: ($l + $a) , y: $w_1 },
       { x: ($l + $a) , y: $w_2 },
       { x:        $l , y: $w_2 },
       { x:        $l , y:   $w },
       { x:       0.0 , y:   $w },
       { x:       0.0 , y: $w_2 },
       { x: ($a * -1) , y: $w_2 },
       { x: ($a * -1) , y: $w_1 },
       { x:       0.0 , y: $w_1 },
    ] | extrude {
        points: $in,
        borders: [[ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11 ]],
        convex_shapes: [
            [ 0, 1, 6, 7 ],
            [ 2, 3, 4, 5 ],
            [ 8, 9, 10, 11 ],
        ],
        h: $shape.h,
    }
}
