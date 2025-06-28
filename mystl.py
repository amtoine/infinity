#!/usr/bin/env -S uv run --script
# /// script
# requires-python = "==3.12"
# dependencies = ["shapely", "matplotlib", "numpy", "numpy-stl", "PyQt5==5.15.10"]
# ///

from shapely import affinity
from shapely.geometry import Polygon
from shapely.ops import triangulate
import shapely

from math import tau, cos, sin, sqrt, tan
import argparse
from argparse import RawTextHelpFormatter
import numpy as np
import stl
from functools import reduce


def poly_round(polygon: Polygon, precision: int):
    return Polygon([(round(x, precision), round(y, precision)) for (x, y) in polygon.exterior.coords])


def extrude(polygon, holes, chamfers, height, visualize: bool = False, ensure_contained: bool = False):
    poly_without_chamfers = polygon if len(chamfers) == 0 else reduce(lambda acc, it: acc.difference(it), [polygon] + chamfers)
    face_triangles = list(filter(
        lambda t: not any(shapely.equals(t.intersection(h), t) for h in holes) and (not ensure_contained or polygon.contains(t)),
        triangulate(poly_without_chamfers),
    ))
    for c in chamfers:
        face_triangles += triangulate(c)

    if visualize:
        import matplotlib.pyplot as plt
        from shapely.plotting import plot_polygon, plot_points
        _, ax = plt.subplots()
        for triangle in face_triangles:
            plot_polygon(triangle, ax=ax, add_points=False, color="red")
        plot_polygon(Polygon(polygon.exterior.coords), ax=ax, add_points=False, facecolor=None, edgecolor="blue", linewidth=5)
        for hole in holes:
            plot_polygon(Polygon(hole.exterior.coords), ax=ax, add_points=False, facecolor="white", edgecolor="grey", linewidth=5)
        plot_points(polygon, ax=ax, color="black")
        plt.axis("equal")
        plt.show()


    face_mesh = np.array([
        np.append(
            np.array(t.exterior.coords[:-1]),
            np.zeros((3,1), dtype=np.int64),
            axis=1,
        )
        for t in face_triangles
    ])

    triangles = np.append(
        face_mesh,
        face_mesh + np.array([0, 0, height]),
        axis=0,
    )

    low_points = []
    for c in chamfers:
        low_points += c.exterior.coords[:2]
    for pt in low_points:
        triangles[np.all(abs(triangles[:,:,0:2] - pt) < 1e-5, axis=2),2] = 0

    edges = [np.array(polygon.exterior.coords)]
    for hole in holes:
        edges.append(np.array(hole.exterior.coords))

    for edge in edges:
        for a, b in list(zip(edge[:-1], edge[1:])):
            if chamfers == []:
                ha = height
                hb = height
            else:
                ha = 0 if np.any(np.all(abs(np.array(low_points) - a) == 0, axis=1)) else height
                hb = 0 if np.any(np.all(abs(np.array(low_points) - b) == 0, axis=1)) else height
            a, b, c, d = np.append(a, [0], axis=0), np.append(b, [0], axis=0), np.append(a, [ha], axis=0), np.append(b, [hb], axis=0)
            triangles = np.append(triangles, np.array([[a, b, c]]), axis=0)
            triangles = np.append(triangles, np.array([[b, c, d]]), axis=0)

    return triangles


def save(triangles, scale=1.0, output="a.stl"):
    mesh = stl.mesh.Mesh(np.zeros(triangles.shape[0], dtype=stl.mesh.Mesh.dtype))
    for i, triangle in enumerate(triangles):
        mesh.vectors[i] = triangle * scale
    mesh.save(output)


def add_options_to_parser(parser, options, **kwargs):
    for (short, long) in options:
        if short is None:
            flags = [long]
        elif long is None:
            flags = [short]
        else:
            flags = [short, long]
        parser.add_argument(*flags, **kwargs)


def check_positive_args(parser, options, args):
    for (short, long) in options:
        if short is None:
            name, val = long, vars(args)[long.lstrip('-').replace('-', '_')]
        elif long is None:
            name, val = short, vars(args)[short.lstrip('-').replace('-', '_')]
        else:
            name, val = long, vars(args)[long.lstrip('-').replace('-', '_')]
        if val <= 0:
            parser.error(f"{name} must be strictly positive, found {val}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(formatter_class=RawTextHelpFormatter)
    subparsers = parser.add_subparsers(dest="subcommand")

    common_options = [
        { "args": ["-v", "--visualize"]   , "kwargs": { "action": "store_true" }        , "cylinder_kwargs": {                  } , "small_decor_kwargs": {                                                          } , "medium_decor_kwargs": {                                                          } },
        { "args": ["-o", "--output"]      , "kwargs": { "default": "a.stl" }            , "cylinder_kwargs": {                  } , "small_decor_kwargs": { "help": "@part will be replaced by the name of the part" } , "medium_decor_kwargs": { "help": "@part will be replaced by the name of the part" } },
        { "args": ["-m", "--hole-margin"] , "kwargs": { "default": 0.4, "type": float } , "cylinder_kwargs": { "help": "unused" } , "small_decor_kwargs": {                                                          } , "medium_decor_kwargs": {                                                          } },
    ]

    CYLINDER_MEASUREMENTS = [
        [ None, "--height" ],
        [ "-r", "--radius" ],
    ]

    parser_cylinder = subparsers.add_parser("cylinder", help="create an STL cylinder")
    add_options_to_parser(parser_cylinder, CYLINDER_MEASUREMENTS, type=float, required=True, help="in mm")
    parser_cylinder.add_argument("-n", "--nb-sides", type=int, default=100)
    for opt in common_options:
        parser_cylinder.add_argument(*opt["args"], **opt["kwargs"], **opt["cylinder_kwargs"])

    SMALL_DECOR_MEASUREMENTS = [
        [ "-l", "--length"    ],
        [ "-w", "--width"     ],
        [ "-t", "--thickness" ],
        [ "-a", None          ],
        [ "-b", None          ],
        [ "-x", None          ],
    ]

    SMALL_DECOR_HELP = [
        "PLATE:                                                                ",
        "                                                                      ",
        "    > this is a 3-rd of the full plate                                ",
        "                                                                      ",
        "             thickness                                                ",
        "              <----->                                                 ",
        "              |     |                                                 ",
        "           .  |     |                                                 ",
        "           ...|.    |                                                 ",
        "           ...|..*--+-------------------------------------^           ",
        "           ...|.....|...                                  |           ",
        "           ...|.....|.......                              |           ",
        "           ...|.....|...........                          |           ",
        "      ^-------*     *...............                      |           ",
        "      |    ...       ...................                  |           ",
        "      |    ...       .......................              |           ",
        "      |    ...       ...........................          |           ",
        "    b |    ...       ...............................      |  width    ",
        "      |    ...       ...........................          |           ",
        "      |    ...       .......................              |           ",
        "      |    ...       ...................                  |           ",
        "      v-------*  *   ...............                      |           ",
        "           ......|..............                          |           ",
        "           ......|..........                              |           ",
        "           ......|......                                  |           ",
        "           ......|..                                      |           ",
        "           ......*----------------------------------------v           ",
        "           *     |                                                    ",
        "           |     |                                                    ",
        "           <----->                                                    ",
        "              x                                                       ",
        "                                                                      ",
        " SIDE:                                                                ",
        "                                                                      ",
        "                               length                                 ",
        "              <--------------------------------------->               ",
        "              |                                       |               ",
        "              |                                       |               ",
        "              *.......................................*--------^      ",
        "              .........................................        |      ",
        "              .........................................        |      ",
        "     ^----*................................................    |      ",
        "     |    .................................................    |      ",
        "   b |    .................................................    | width",
        "     |    .................................................    |      ",
        "     v----*...*.......................................*...*    |      ",
        "          |   |.......................................|   |    |      ",
        "          |   |.......................................|   |    |      ",
        "          |   |.......................................+---+----v      ",
        "          |   |                                       |   |           ",
        "          |   |                                       |   |           ",
        "          <--->                                       <--->           ",
        "            a                                           a             ",
        "                                                                      ",
    ]

    parser_small_decor = subparsers.add_parser(
        "small-decor",
        help="create a small STL decor",
        description="\n".join(SMALL_DECOR_HELP),
        formatter_class=RawTextHelpFormatter,
    )
    add_options_to_parser(parser_small_decor, SMALL_DECOR_MEASUREMENTS, type=float, required=True, help="in mm")
    for opt in common_options:
        parser_small_decor.add_argument(*opt["args"], **opt["kwargs"], **opt["small_decor_kwargs"])

    MEDIUM_DECOR_MEASUREMENTS = [
        [ None  , "--height"    ],
        [ "-w"  , "--width"     ],
        [ "-t"  , "--thickness" ],
        [ "-x"  , None          ],
        [ "-y"  , None          ],
        [ "-a"  , None          ],
        [ "-b"  , None          ],
        [ "-z"  , None          ],
        [ "-c"  , None          ],
        [ "-l1" , None          ],
        [ "-l2" , None          ],
        [ "-l3" , None          ],
        [ "-h1" , None          ],
        [ "-h2" , None          ],
        [ "-h3" , None          ],
    ]

    MEDIUM_DECOR_HELP = [
        "PLATE:                                                                                   ",
        "                                                                                         ",
        "    > this is a 6-rd of the full plate                                                   ",
        "                                                                                         ",
        "                *----------------------------------------------^                         ",
        "                .....                                          |                         ",
        "                ........                                       |                         ",
        "                .............                                  |                         ",
        "                .................                              |                         ",
        "                .....................                          |                         ",
        "      ^---*..............................                      |                         ",
        "      |   ...................................                  |                         ",
        "      |   .......................................              |                         ",
        "      |   ...........................................          |                         ",
        "    y |   ...............................................      |  width                  ",
        "      |   ...........................................          |                         ",
        "      |   .......................................              |                         ",
        "      |   ...................................                  |                         ",
        "      v---*.....*........................                      |                         ",
        "          |     |....................                          |                         ",
        "          |     |................                              |                         ",
        "          |     |............                                  |                         ",
        "          |     |........                                      |                         ",
        "          |     |....                                          |                         ",
        "          |     +----------------------------------------------v                         ",
        "          |     |                                                                        ",
        "          <----->                                                                        ",
        "             x                                                                           ",
        "                                                                                         ",
        " SIDE:                                                                                   ",
        "                                                                                         ",
        "                              width                                                      ",
        "                  <--------------------------->                                          ",
        "                  |                           |                                          ",
        "                  |             y             |                                          ",
        "                  |      <-------------->     |                                          ",
        "                  |      |              |     |                                          ",
        "                  |      |              |     |                                          ",
        "                  *......|..............|.....*-----^                                    ",
        "                  .......|..............|......     |                                    ",
        "                  .......|..............|......     | z                                  ",
        "               ^---------*..............*......     |                                    ",
        "               |  ........              .......     |                                    ",
        "     thickness |  ........              *--------^--v                                    ",
        "               |  ........              .......  |                                       ",
        "               b---------*.....................  |                                       ",
        "                  .............................  |                                       ",
        "                  .............................  |                                       ",
        "                  .............................  | height                                ",
        "                  .............................  |                                       ",
        "                  .............................  |                                       ",
        "               ^--------------*   .............  |                                       ",
        "               |  .............   .............  |                                       ",
        "             a |  .............   .............  |                                       ",
        "               |  .............   .............  |                                       ",
        "               v--*...........*   *...........*--v                                       ",
        "                  |           |   |                                                      ",
        "                  |           |   |                                                      ",
        "                  <----------->   |                                                      ",
        "                        b     |   |                                                      ",
        "                              <--->                                                      ",
        "                            thickness                                                    ",
        "                                                                                         ",
        " COVER:                                                                                  ",
        "                                                                                         ",
        "    > there will be quarters of circles in the 3 lx/hx corners if --rounded is raised    ",
        "                                                                                         ",
        "                                                             l3                          ",
        "                                                     <---------------->                  ",
        "                                                     |                |                  ",
        "                                           l2        |                |                  ",
        "                                    <---------------->                |                  ",
        "                                    |                |                |                  ",
        "                          l1        |                |                |                  ",
        "                 <------------------>                |                |                  ",
        "                 |                  |                |                |                  ",
        "                 |                  |                |                |                  ",
        "                 *..................+----------------+----------------+--------------^   ",
        "                 ...................|                |                |              |   ",
        "                 ...................|                |                |              | h1",
        "                 ...................|                |                |              |   ",
        "                 ...................*----------------+----------------+---------^----v   ",
        "                 ....................................|                |         |        ",
        "   ^----*........*...................................|                |         | h2     ",
        "   |    .........|...................................|                |         |        ",
        "   |    .........|...................................*----------------+----^----v        ",
        " a |    .........|.....................................................    |             ",
        "   |    .........|.....................................................    | h3          ",
        "   |    .........|.....................................................    |             ",
        "   v----*........|....................................................*----v             ",
        "        |        |                                                                       ",
        "        |        |                                                                       ",
        "        <-------->                                                                       ",
        "            c                                                                            ",
    ]

    parser_medium_decor = subparsers.add_parser(
        "medium-decor",
        help="create a medium STL decor",
        description="\n".join(MEDIUM_DECOR_HELP),
        formatter_class=RawTextHelpFormatter,
    )
    add_options_to_parser(parser_medium_decor, MEDIUM_DECOR_MEASUREMENTS, type=float, required=True, help="in mm")
    parser_medium_decor.add_argument("--rounded", action="store_true")
    for opt in common_options:
        parser_medium_decor.add_argument(*opt["args"], **opt["kwargs"], **opt["medium_decor_kwargs"])

    args = parser.parse_args()

    if args.subcommand is None:
        parser.parse_args(["-h"])
        exit(0)

    if args.subcommand == "cylinder":
        check_positive_args(parser, CYLINDER_MEASUREMENTS, args)
        polygon = Polygon([
            (args.radius * cos(alpha), args.radius * sin(alpha))
            for alpha in np.linspace(0, tau, args.nb_sides)
        ])

        save(
            extrude(polygon, [], [], args.height, args.visualize),
            output=args.output,
            scale=1.0,
        )
    elif args.subcommand == "small-decor":
        check_positive_args(parser, SMALL_DECOR_MEASUREMENTS + [(None, "--hole-margin")], args)
        if args.b >= args.width:
            parser.error("\n".join([
                f"condition `b < width` for SIDE unsatisfied",
                f"     -b     : {args.b:9.3f}",
                f"    --width : {args.width:9.3f}",
                f"  lhs = {args.b:9.3f}",
                f"  rhs = {args.width:9.3f}",
            ]))
        if args.b + 2 * args.hole_margin >= args.width:
            parser.error("\n".join([
                f"condition `b + 2 hole_margin < width` for PLATE unsatisfied",
                f"     -b           : {args.b:9.3f}",
                f"    --hole-margin : {args.hole_margin:9.3f}",
                f"    --width       : {args.width:9.3f}",
                f"  lhs = {args.b + 2 * args.hole_margin:9.3f}",
                f"  rhs = {args.width:9.3f}",
            ]))
        if args.x <= args.thickness / 2 + args.hole_margin:
            parser.error("\n".join([
                f"condition `x > thickness / 2 + hole_margin` for PLATE unsatisfied",
                f"     -x           : {args.x:9.3f}",
                f"    --thickness   : {args.thickness:9.3f}",
                f"    --hole-margin : {args.hole_margin:9.3f}",
                f"  lhs = {args.x:9.3f}",
                f"  rhs = {args.thickness / 2 + args.hole_margin:9.3f}",
            ]))

        unit_triangle_side_length = sqrt((1 - cos(tau / 3)) ** 2 + sin(tau / 3) ** 2)
        scale = args.width / unit_triangle_side_length

        length    = args.length      / scale
        width     = args.width       / scale
        thickness = args.thickness   / scale
        a         = args.a           / scale
        x         = args.x           / scale
        b         = args.b           / scale
        margin    = args.hole_margin / scale
        chamfer   = thickness * tan(tau / 12) / 2

        beta = 1 + abs(cos(tau / 3))
        z = (beta - thickness / 2) / beta
        if args.b + 2 * args.hole_margin >= args.width * z:
            parser.error("\n".join([
                f"condition `b + 2 * hole_margin < width * z` for PLATE unsatisfied",
                f"     -b           : {args.b:9.3f}",
                f"    --hole-margin : {args.hole_margin:9.3f}",
                f"    --width       : {args.width:9.3f}",
                f"      z           : {z:9.3f}",
                f"  lhs = {args.b + 2 * args.hole_margin:9.3f}",
                f"  rhs = {args.width * z:9.3f}",
            ]))

        if chamfer * scale > (args.width - args.b) / 2:
            parser.error("\n".join([
                f"condition `chamfer <= (width - b) / 2` for SIDE unsatisfied",
                f"     chamfer : {chamfer * scale:9.3f}",
                f"    --width  : {args.width:9.3f}",
                f"     -b      : {args.b:9.3f}",
                f"  lhs = {chamfer * scale:9.3f}",
                f"  rhs = {(args.width - args.b) / 2:9.3f}",
            ]))

        ### plate
        # y = (1 + abs(cos(tau / 3)) + x) * tan(tau / 12)
        y = sin(tau / 3) * (1 + abs(cos(tau / 3)) + x) / (1 + abs(cos(tau / 3)))

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
        base = Polygon([
            (cos(0)           , sin(0)),
            (cos(tau / 3) - x ,  y    ),
            (cos(tau / 3) - x , -y    ),
        ])
        hole = Polygon([
            (cos(tau / 3) + (thickness / 2 + margin) ,  (b / 2 + margin)),
            (cos(tau / 3) - (thickness / 2 + margin) ,  (b / 2 + margin)),
            (cos(tau / 3) - (thickness / 2 + margin) , -(b / 2 + margin)),
            (cos(tau / 3) + (thickness / 2 + margin) , -(b / 2 + margin)),
        ])

        polygon, holes = Polygon([]), []
        for alpha in [-tau / 12, -3 * tau / 12, -5 * tau / 12]:
            _b = affinity.rotate(affinity.translate(base, xoff=-1.0), alpha, origin=(0, 0), use_radians=True)
            _h = affinity.rotate(affinity.translate(hole, xoff=-1.0), alpha, origin=(0, 0), use_radians=True)
            polygon = polygon.union(poly_round(_b, precision=5).difference(_h))
            holes.append(_h)

        save(
            extrude(polygon, holes, [], thickness, args.visualize, ensure_contained=False),
            output=args.output.replace("@part", "plate"),
            scale=scale,
        )

        ### side
        l, w = length, width

        w_1 = (w - b) / 2
        w_2 = (w + b) / 2

        #
        #
        #           +---------------------------------------+     ^
        #           *                                       *     |
        #           |                                       |     |
        #       +---+                                       +---+ |
        #     ^ |                                               | |
        #   b | |                                               | | width
        #     v |                                               | |
        #       +---+                                       +---+ |
        #           |                                       |     |
        #           *                                       *     |
        #           +---------------------------------------+     v
        #        <-> <-------------------------------------> <->
        #         a                  length                   a
        #
        #
        z = chamfer
        polygon = Polygon([
           (0.0   , -z   + margin),  #
           (l     , -z   + margin),  #
           (l     ,  z   + margin),  # chamfer
           (l     , w_1  ),
           (l + a , w_1  ),
           (l + a , w_2  ),
           (l     , w_2  ),
           (l     , w - z - margin),  # chamfer
           (l     , w + z - margin),  #
           (0.0   , w + z - margin),  #
           (0.0   , w - z - margin),  # chamfer
           (0.0   , w_2  ),
           (-a    , w_2  ),
           (-a    , w_1  ),
           (0.0   , w_1  ),
           (0.0   ,   z   + margin),  # chamfer
        ])

        chamfers = [
            Polygon([
                (0.0 , -z + margin),
                (l   , -z + margin),
                (l   ,  z + margin),
                (0.0 ,  z + margin),
            ]),
            Polygon([
                (l   , w + z - margin),
                (0.0 , w + z - margin),
                (0.0 , w - z - margin),
                (l   , w - z - margin),
            ]),
        ]

        save(
            extrude(polygon, [], chamfers, thickness, args.visualize, ensure_contained=True),
            output=args.output.replace("@part", "side"),
            scale=scale,
        )
    elif args.subcommand == "medium-decor":
        check_positive_args(parser, MEDIUM_DECOR_MEASUREMENTS + [(None, "--hole-margin")], args)
        if args.y >= args.width:
            parser.error("\n".join([
                f"condition `y < width` for PLATE unsatisfied",
                f"     -y     : {args.y:9.3f}",
                f"    --width : {args.width:9.3f}",
                f"  lhs = {args.y:9.3f}",
                f"  rhs = {args.width:9.3f}",
            ]))
        if args.z <= args.thickness / 2 + args.hole_margin:
            parser.error("\n".join([
                f"condition `z > thickness / 2 + hole_margin` for SIDE unsatisfied",
                f"     -z           : {args.z:9.3f}",
                f"    --thickness   : {args.thickness:9.3f}",
                f"    --hole-margin : {args.hole_margin:9.3f}",
                f"  lhs = {args.z:9.3f}",
                f"  rhs = {args.thickness / 2 + args.hole_margin:9.3f}",
            ]))
        if args.y + 2 * args.hole_margin >= args.width:
            parser.error("\n".join([
                f"condition `y + 2 * hole_margin < width` for SIDE unsatisfied",
                f"     -y           : {args.y:9.3f}",
                f"    --hole-margin : {args.hole_margin:9.3f}",
                f"    --width       : {args.width:9.3f}",
                f"  lhs = {args.y + 2 * args.hole_margin:9.3f}",
                f"  rhs = {args.width:9.3f}",
            ]))
        if args.a + args.hole_margin >= args.height - (args.thickness / 2 + args.hole_margin):
            parser.error("\n".join([
                f"condition `a + hole_margin < height - (thickness / 2 + hole_margin)` for SIDE unsatisfied",
                f"     -a           : {args.a:9.3f}",
                f"    --hole-margin : {args.hole_margin:9.3f}",
                f"    --height      : {args.height:9.3f}",
                f"    --thickness   : {args.thickness:9.3f}",
                f"  lhs = {args.a + args.hole_margin:9.3f}",
                f"  rhs = {args.height - (args.thickness / 2 + args.hole_margin):9.3f}",
            ]))
        if args.b <= args.hole_margin:
            parser.error("\n".join([
                f"condition `b > hole_margin` for SIDE unsatisfied",
                f"     -b           : {args.b:9.3f}",
                f"    --hole-margin : {args.hole_margin:9.3f}",
                f"  lhs = {args.b:9.3f}",
                f"  rhs = {args.hole_margin:9.3f}",
            ]))
        if args.b + args.thickness + args.hole_margin >= args.width:
            parser.error("\n".join([
                f"condition `b + thickness + hole_margin < width` for SIDE unsatisfied",
                f"     -b           : {args.b:9.3f}",
                f"    --thickness   : {args.thickness:9.3f}",
                f"    --hole-margin : {args.hole_margin:9.3f}",
                f"    --width       : {args.width:9.3f}",
                f"  lhs = {args.b + args.thickness + args.hole_margin:9.3f}",
                f"  rhs = {args.width:9.3f}",
            ]))
        if args.a > args.h1 + args.h2 + args.h3:
            parser.error("\n".join([
                f"condition `l1 >= h1` for COVER with unsatisfied",
                f"    -a  : {args.a:9.3f}",
                f"    -h1 : {args.h1:9.3f}",
                f"    -h2 : {args.h2:9.3f}",
                f"    -h3 : {args.h3:9.3f}",
                f"  lhs = {args.a:9.3f}",
                f"  rhs = {args.h1 + args.h2 + args.h3:9.3f}",
            ]))
        if args.rounded:
            if args.l1 < args.h1:
                parser.error("\n".join([
                    f"condition `l1 >= h1` for COVER with --rounded unsatisfied",
                    f"    -l1 : {args.l1:9.3f}",
                    f"    -h1 : {args.h1:9.3f}",
                f"  lhs = {args.l1:9.3f}",
                f"  rhs = {args.h1:9.3f}",
                ]))
            if args.l2 < args.h2:
                parser.error("\n".join([
                    f"condition `l2 >= h2` for COVER with --rounded unsatisfied",
                    f"    -l2 : {args.l2:9.3f}",
                    f"    -h2 : {args.h2:9.3f}",
                f"  lhs = {args.l2:9.3f}",
                f"  rhs = {args.h2:9.3f}",
                ]))
            if args.l3 < args.h3:
                parser.error("\n".join([
                    f"condition `l3 >= h3` for COVER with --rounded unsatisfied",
                    f"    -l3 : {args.l3:9.3f}",
                    f"    -h3 : {args.h3:9.3f}",
                f"  lhs = {args.l3:9.3f}",
                f"  rhs = {args.h3:9.3f}",
                ]))

        scale = args.width / sqrt((1 - cos(tau / 3)) ** 2 + sin(tau / 3) ** 2)

        width     = args.width       / scale
        thickness = args.thickness   / scale
        x         = args.x           / scale
        y         = args.y           / scale
        # > [!note] this should be equilateral :eyes:
        #
        #               1.
        #               .....
        #               ........
        #               ...........
        #               ..............
        #         3.....2................
        #      ^  ..........................
        #   y  |  ............................0
        #      v  ..........................
        #         4.....5................
        #               ..............
        #               ...........
        #               ........
        #               .....
        #               6.
        #          <--->
        #            x
        #
        base = Polygon([
            (cos(0 * tau / 3)     ,  sin(0 * tau / 3)),
            (cos(1 * tau / 3)     ,  sin(1 * tau / 3)),
            (cos(1 * tau / 3)     ,  y / 2),
            (cos(1 * tau / 3) - x ,  y / 2),
            (cos(2 * tau / 3) - x , -y / 2),
            (cos(2 * tau / 3)     , -y / 2),
            (cos(1 * tau / 3)     ,  sin(2 * tau / 3)),
        ])

        PRECISION = 5

        polygon = Polygon([])
        for alpha in [0, 2 * tau / 12, 4 * tau / 12, 6 * tau / 12, 8 * tau / 12, 10 * tau / 12]:
            _b = affinity.rotate(affinity.translate(base, xoff=-1.0), alpha, origin=(0, 0), use_radians=True)
            polygon = polygon.union(poly_round(_b, precision=5))

        save(
            extrude(polygon, [], [], thickness, args.visualize, ensure_contained=True),
            output=args.output.replace("@part", "plate"),
            scale=scale,
        )

        ### side
        w, h = args.width, args.height
        a    = args.a
        b    = args.b
        c    = args.thickness
        d    = args.thickness
        e    = args.y
        z    = args.z
        chamfer = c / tan(tau / 6)
        margin  = args.hole_margin

        if chamfer > args.b - args.hole_margin:
            parser.error("\n".join([
                f"condition `chamfer <= b - hole_margin` for SIDE unsatisfied",
                f"     chamfer      : {chamfer:9.3f}",
                f"     -b           : {args.b:9.3f}",
                f"    --hole-margin : {args.hole_margin:9.3f}",
                f"  lhs = {chamfer:9.3f}",
                f"  rhs = {args.b - args.hole_margin:9.3f}",
            ]))
        if args.width - chamfer <= args.b + args.thickness + args.hole_margin:
            parser.error("\n".join([
                f"condition `width - chamfer > b + thickness + hole_margin` for SIDE unsatisfied",
                f"    --width       : {args.width:9.3f}",
                f"     chamfer      : {chamfer:9.3f}",
                f"     -b           : {args.b:9.3f}",
                f"    --thickness   : {args.thickness:9.3f}",
                f"    --hole-margin : {args.hole_margin:9.3f}",
                f"  lhs = {args.width - chamfer:9.3f}",
                f"  rhs = {args.b + args.thickness + args.hole_margin:9.3f}",
            ]))
        #
        #
        #                              width
        #                   <------------------------->
        #                                e = y
        #                             <------>
        #                  7*-------------------------*6
        #                  |                           | ^
        #                  |                           | | z
        #                  |        11--------10       | |
        #                ^ |         |        |        | v
        #  thickness = d | |         |        |        | ^
        #                v |         |        |        | |
        #                  |         8--------9        | |
        #                  |                           | |
        #                  |                           | |
        #                  |                           | | height
        #                  |                           | |
        #                  |           2---3           | |
        #                ^ |           |   |           | |
        #              a | |           |   |           | |
        #                v |           |   |           | v
        #                  0*----------1   4----------*5
        #                   <---------> <->
        #                        b       c = thickness
        #
        polygon = Polygon([
           (0.0             , 0.0       ), #
           (chamfer         , 0.0       ), # chamfer
           (b     - margin  , 0.0       ),
           (b     - margin  , a + margin),
           (b + c + margin  , a + margin),
           (b + c + margin  , 0.0       ),
           (w - chamfer     , 0.0       ), # chamfer
           (w               , 0.0       ), #
           (w               , h + z     ), #
           (w - chamfer     , h + z     ), # chamfer
           (chamfer         , h + z     ), # chamfer
           (0.0             , h + z     ), #
        ])
        hole = Polygon([
            (w / 2 - (e / 2 + margin), h - (d / 2 + margin)),
            (w / 2 + (e / 2 + margin), h - (d / 2 + margin)),
            (w / 2 + (e / 2 + margin), h + (d / 2 + margin)),
            (w / 2 - (e / 2 + margin), h + (d / 2 + margin)),
        ])
        chamfers = [
            Polygon([
                (0.0         , 0.0  ),
                (0.0         , h + z),
                (chamfer     , h + z),
                (chamfer     , 0.0  ),
            ]),
            Polygon([
                (w           , 0.0  ),
                (w           , h + z),
                (w - chamfer , h + z),
                (w - chamfer , 0.0  ),
            ]),
        ]

        save(
            extrude(polygon.difference(hole), [hole], chamfers, args.thickness, args.visualize, ensure_contained=True),
            output=args.output.replace("@part", "side"),
            scale=1.0,
        )

        ### cover
        a      = args.a
        c      = args.c
        l1, h1 = args.l1, args.h1
        l2, h2 = args.l2, args.h2
        l3, h3 = args.l3, args.h3
        #
        #                                                             l3
        #                                                     <---------------->
        #                                                     |                |
        #                                           l2        |                |
        #                                    <---------------->                |
        #                                    |                |                |
        #                          l1        |                |                |
        #                 <------------------>                |                |
        #                 |                  |                |                |
        #                 |                  |                |                |
        #                 *..................+----------------+----------------+--------------^
        #                 ...................|                |                |              |
        #                 ...................|                |                |              | h1
        #                 ...................|                |                |              |
        #                 ...................*----------------+----------------+---------^----v
        #                 ....................................|                |         |
        #   ^----*........*...................................|                |         | h2
        #   |    .........|...................................|                |         |
        #   |    .........|...................................*----------------+----^----v
        # a |    .........|.....................................................    |
        #   |    .........|.....................................................    | h3
        #   |    .........|.....................................................    |
        #   v----*........|....................................................*----v
        #        |        |
        #        |        |
        #        <-------->
        #            c
        #
        vertices = []
        vertices.append((0.0              , 0.0))
        vertices.append((c + l1 + l2 + l3 , 0.0))
        if args.rounded:
            cx, cy = (c + l1 + l2 + l3 - h3, 0.0)
            for alpha in np.linspace(0, tau / 4, 30):
                vertices.append((cx + h3 * cos(alpha), cy + h3 * sin(alpha)))
        else:
           vertices.append((c + l1 + l2 + l3, h3))
        vertices.append((c + l1 + l2, h3))
        if args.rounded:
            cx, cy = (c + l1 + l2 - h2, h3)
            for alpha in np.linspace(0, tau / 4, 30):
                vertices.append((cx + h2 * cos(alpha), cy + h2 * sin(alpha)))
        else:
            vertices.append((c + l1 + l2, h3 + h2))
        vertices.append((c + l1, h3 + h2))
        if args.rounded:
            cx, cy = (c + l1 - h1, h3 + h2)
            for alpha in np.linspace(0, tau / 4, 30):
                vertices.append((cx + h1 * cos(alpha), cy + h1 * sin(alpha)))
        else:
            vertices.append((c + l1, h3 + h2 + h1))
        vertices.append((c   , h3 + h2 + h1))
        vertices.append((c   , a           ))
        vertices.append((0.0 , a           ))

        save(
            extrude(Polygon(vertices), [], [], args.thickness, args.visualize, ensure_contained=True),
            output=args.output.replace("@part", "cover"),
            scale=1.0,
        )
    else:
        print("unreachable")
        exit(3)
