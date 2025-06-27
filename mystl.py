#!/usr/bin/env -S uv run --script
# /// script
# requires-python = "==3.12"
# dependencies = ["shapely", "matplotlib", "numpy", "numpy-stl", "PyQt5==5.15.10"]
# ///

from shapely import affinity
from shapely.geometry import Polygon
from shapely.ops import triangulate
import shapely

from math import tau, cos, sin, sqrt
import argparse
import numpy as np
import stl


def poly_round(polygon: Polygon, precision: int):
    return Polygon([(round(x, precision), round(y, precision)) for (x, y) in polygon.exterior.coords])


def extrude(polygon, holes, height, visualize: bool = False, ensure_contained: bool = False):
    face_triangles = list(filter(
        lambda t: not any(shapely.equals(t.intersection(h), t) for h in holes) and (not ensure_contained or polygon.contains(t)),
        triangulate(polygon),
    ))

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

    edges = [np.array(polygon.exterior.coords)]
    for hole in holes:
        edges.append(np.array(hole.exterior.coords))

    for edge in edges:
        for a, b in list(zip(edge[:-1], edge[1:])):
            a, b, c, d = np.append(a, [0], axis=0), np.append(b, [0], axis=0), np.append(a, [height], axis=0), np.append(b, [height], axis=0)
            triangles = np.append(triangles, np.array([[a, b, c]]), axis=0)
            triangles = np.append(triangles, np.array([[b, c, d]]), axis=0)

    return triangles


def save(triangles, scale=1.0, output="a.stl"):
    mesh = stl.mesh.Mesh(np.zeros(triangles.shape[0], dtype=stl.mesh.Mesh.dtype))
    for i, triangle in enumerate(triangles):
        mesh.vectors[i] = triangle * scale
    mesh.save(output)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    subparsers = parser.add_subparsers(dest="subcommand")

    common_options = [
        { "args": ["-v", "--visualize"] , "kwargs": { "action": "store_true" } , "cylinder_kwargs": {} , "small_decor_kwargs": {}                                                           , "medium_decor_kwargs": {}                                                           },
        { "args": ["-o", "--output"]    , "kwargs": { "default": "a.stl" }     , "cylinder_kwargs": {} , "small_decor_kwargs": { "help": "@part will be replaced by the name of the part" } , "medium_decor_kwargs": { "help": "@part will be replaced by the name of the part" } },
    ]

    parser_cylinder = subparsers.add_parser("cylinder",                         help="create an STL cylinder")
    parser_cylinder.add_argument(      "--height",   type=float, required=True, help="in mm")
    parser_cylinder.add_argument("-r", "--radius",   type=float, required=True, help="in mm")
    parser_cylinder.add_argument("-n", "--nb-sides", type=int,   default=100)
    for opt in common_options:
        parser_cylinder.add_argument(*opt["args"], **opt["kwargs"], **opt["cylinder_kwargs"])

    parser_medium_decor = subparsers.add_parser("small-decor",                         help="create a small STL decor")
    parser_medium_decor.add_argument("-l", "--length",    type=float, required=True,   help="in mm")
    parser_medium_decor.add_argument("-w", "--width",     type=float, required=True,   help="in mm")
    parser_medium_decor.add_argument("-t", "--thickness", type=float, required=True,   help="in mm")
    parser_medium_decor.add_argument("-a",                type=float, required=True,   help="in mm")
    parser_medium_decor.add_argument("-b",                type=float, required=True,   help="in mm")
    parser_medium_decor.add_argument("-x",                type=float, required=True,   help="in mm")
    for opt in common_options:
        parser_medium_decor.add_argument(*opt["args"], **opt["kwargs"], **opt["small_decor_kwargs"])

    parser_medium_decor = subparsers.add_parser("medium-decor",                        help="create a medium STL decor")
    parser_medium_decor.add_argument(      "--height",    type=float, required=True,   help="in mm")
    parser_medium_decor.add_argument("-w", "--width",     type=float, required=True,   help="in mm")
    parser_medium_decor.add_argument("-t", "--thickness", type=float, required=True,   help="in mm")
    parser_medium_decor.add_argument("-x",                type=float, required=True,   help="in mm")
    parser_medium_decor.add_argument("-y",                type=float, required=True,   help="in mm")
    parser_medium_decor.add_argument("-a",                type=float, required=True,   help="in mm")
    parser_medium_decor.add_argument("-b",                type=float, required=True,   help="in mm")
    parser_medium_decor.add_argument("-z",                type=float, required=True,   help="in mm")
    for opt in common_options:
        parser_medium_decor.add_argument(*opt["args"], **opt["kwargs"], **opt["medium_decor_kwargs"])

    args = parser.parse_args()

    if args.subcommand is None:
        parser.parse_args(["-h"])
        exit(0)

    if args.subcommand == "cylinder":
        polygon = Polygon([
            (args.radius * cos(alpha), args.radius * sin(alpha))
            for alpha in np.linspace(0, tau, args.nb_sides)
        ])

        save(
            extrude(polygon, [], args.height, args.visualize),
            output=args.output,
            scale=1.0,
        )
    elif args.subcommand == "small-decor":
        scale = args.width / sqrt((1 - cos(tau / 3)) ** 2 + sin(tau / 3) ** 2)

        length    = args.length    / scale
        width     = args.width     / scale
        thickness = args.thickness / scale
        a         = args.a         / scale
        x         = args.x         / scale
        b         = args.b         / scale

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
            (cos(tau / 3) + thickness / 2 ,  b / 2),
            (cos(tau / 3) - thickness / 2 ,  b / 2),
            (cos(tau / 3) - thickness / 2 , -b / 2),
            (cos(tau / 3) + thickness / 2 , -b / 2),
        ])

        polygon, holes = Polygon([]), []
        for alpha in [-tau / 12, -3 * tau / 12, -5 * tau / 12]:
            _b = affinity.rotate(affinity.translate(base, xoff=-1.0), alpha, origin=(0, 0), use_radians=True)
            _h = affinity.rotate(affinity.translate(hole, xoff=-1.0), alpha, origin=(0, 0), use_radians=True)
            polygon = polygon.union(_b.difference(_h))
            holes.append(_h)

        save(
            extrude(polygon, holes, thickness, args.visualize, ensure_contained=False),
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
        polygon = Polygon([
           (0.0   , 0.0),
           (l     , 0.0),
           (l     , w_1),
           (l + a , w_1),
           (l + a , w_2),
           (l     , w_2),
           (l     , w  ),
           (0.0   , w  ),
           (0.0   , w_2),
           (-a    , w_2),
           (-a    , w_1),
           (0.0   , w_1),
        ])

        save(
            extrude(polygon, [], thickness, args.visualize, ensure_contained=True),
            output=args.output.replace("@part", "side"),
            scale=scale,
        )
    elif args.subcommand == "medium-decor":
        scale = args.width / sqrt((1 - cos(tau / 3)) ** 2 + sin(tau / 3) ** 2)

        width     = args.width     / scale
        thickness = args.thickness / scale
        x         = args.x         / scale
        y         = args.y         / scale
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
            extrude(polygon, [], thickness, True, ensure_contained=True),
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
        #
        #
        #                              width
        #                   <------------------------->
        #                                e = y
        #                             <------>
        #                  7---------------------------6
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
        #                  0-----------1   4-----------5
        #                   <---------> <->
        #                        b       c = thickness
        #
        polygon = Polygon([
           (0.0   , 0.0  ),
           (b     , 0.0  ),
           (b     , a    ),
           (b + c , a    ),
           (b + c , 0.0  ),
           (w     , 0.0  ),
           (w     , h + z),
           (0.0   , h + z),
        ])
        hole = Polygon([
            (w / 2 - e / 2, h - d / 2),
            (w / 2 + e / 2, h - d / 2),
            (w / 2 + e / 2, h + d / 2),
            (w / 2 - e / 2, h + d / 2),
        ])

        save(
            extrude(polygon.difference(hole), [hole], args.thickness, args.visualize, ensure_contained=True),
            output=args.output.replace("@part", "side"),
            scale=1.0,
        )
    else:
        print("unreachable")
        exit(3)
