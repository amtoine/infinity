import cv2
import numpy as np
import sys
import argparse
import pathlib

parser = argparse.ArgumentParser(
    prog="Image Diff",
    description="Computes the diff between 2 images"
)

parser.add_argument("im1", type=str, help="The \"base\" image.")
parser.add_argument("im2", type=str, help="The \"secondary\" image.")
parser.add_argument(
    "-o", "--output",
    type=str,
    default="/tmp/img-diff.png",
    help="Where to put the diff on the filesystem.",
)

args = parser.parse_args()

im1 = cv2.imread(args.im1)
im2 = cv2.imread(args.im2)

diff = (im1 - im2) / 2 + 128

pathlib.Path(args.output).parent.mkdir(parents=True, exist_ok=True)
cv2.imwrite(args.output, np.uint8(diff))
print(args.output)
