#!/usr/bin/env -S uv run --script
# /// script
# requires-python = "==3.12"
# dependencies = ["shapely", "matplotlib", "numpy", "numpy-stl"]
# ///

from shapely import affinity
from shapely.geometry import Polygon
from shapely.ops import triangulate
import shapely

from math import tau, cos, sin, sqrt
import argparse
import matplotlib.pyplot as plt
import numpy as np
import stl


def extrude(polygon, holes, height):
    face = list(filter(
        lambda t: not any(shapely.equals(t.intersection(h), t) for h in holes),
        triangulate(polygon),
    ))

    triangles = np.append(
        np.array([
            np.append(
                np.array(t.exterior.coords[:-1]),
                np.zeros((3,1), dtype=np.int64) * (height),
                axis=1,
            )
            for t in face
        ]),
        np.array([
            np.append(
                np.array(t.exterior.coords[:-1]),
                np.ones((3,1), dtype=np.int64) * (height),
                axis=1,
            )
            for t in face
        ]),
        axis=0,
    )

    edge = np.array(polygon.exterior.coords)
    for a, b in list(zip(edge[:-1], edge[1:])):
        a, b, c, d = np.append(a, [0], axis=0), np.append(b, [0], axis=0), np.append(a, [height], axis=0), np.append(b, [height], axis=0)
        triangles = np.append(triangles, np.array([[a, b, c]]), axis=0)
        triangles = np.append(triangles, np.array([[b, c, d]]), axis=0)
    for hole in holes:
        edge = np.array(hole.exterior.coords)
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

    parser_cylinder = subparsers.add_parser("cylinder", help="create an STL cylinder")
    parser_cylinder.add_argument(      "--height",   type=float, required=True, help="in mm")
    parser_cylinder.add_argument("-r", "--radius",   type=float, required=True, help="in mm")
    parser_cylinder.add_argument("-n", "--nb-sides", type=int,   default=100)
    parser_cylinder.add_argument("-o", "--output",   default="a.stl")

    parser_small_decor = subparsers.add_parser("small-decor", help="create a small STL decor")
    parser_small_decor.add_argument("-l", "--length",    type=float, required=True, help="in mm")
    parser_small_decor.add_argument("-w", "--width",     type=float, required=True, help="in mm")
    parser_small_decor.add_argument("-t", "--thickness", type=float, required=True, help="in mm")
    parser_small_decor.add_argument("-a",                type=float, required=True, help="in mm")
    parser_small_decor.add_argument("-b",                type=float, required=True, help="in mm")
    parser_small_decor.add_argument("-x",                type=float, required=True, help="in mm")
    parser_small_decor.add_argument("-p", "--plate",     action="store_true")
    parser_small_decor.add_argument("-o", "--output", default="a.stl")

    args = parser.parse_args()

    if args.subcommand is None:
        parser.parse_args(["-h"])
        exit(0)

    if args.subcommand == "cylinder":
        polygon = Polygon([
            (args.radius * cos(alpha), args.radius * sin(alpha))
            for alpha in np.linspace(0, tau, args.nb_sides)
        ])

        save(extrude(polygon, [], args.height), output=args.output, scale=1.0)
    elif args.subcommand == "small-decor":
        scale = args.width / sqrt((1 - cos(tau / 3)) ** 2 + sin(tau / 3) ** 2)

        length    = args.length    / scale
        width     = args.width     / scale
        thickness = args.thickness / scale
        a         = args.a         / scale
        x         = args.x         / scale
        b         = args.b         / scale

        if args.plate:
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
                b = affinity.rotate(affinity.translate(base, xoff=-1.0), alpha, origin=(0, 0), use_radians=True)
                h = affinity.rotate(affinity.translate(hole, xoff=-1.0), alpha, origin=(0, 0), use_radians=True)
                polygon = polygon.union(b.difference(h))
                holes.append(h)

            save(extrude(polygon, holes, thickness), output=args.output, scale=scale)
        else:
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
            save(extrude(polygon, [], thickness), output=args.output, scale=scale)
    else:
        print("unreachable")
        exit(3)
