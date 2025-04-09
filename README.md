## Troop cards

These have been inspired by

- Panoceania | Orc (seen in [_New Infinity N5 Fireteam Rules; All You Need To Know! | Infinity N5 Week_ from _OnTableTop_][video-1])
![Panoceania | Orc](assets/4fb8339e-3d5d-4f70-9e3e-3f76bb449dd4.jpeg)
- JSA | Shikami (seen in [Getting started with Infinity N5 – The Infinity Institute][video-2])
![JSA | Shikami](assets/c10788ac-cffd-4494-8f02-d7eaafcc30fa.jpeg)
- Combi rifle (seen in [_New Infinity N5 Fireteam Rules; All You Need To Know! | Infinity N5 Week_ from _OnTableTop_][video-1])
![Combi rifle](assets/e3948ce6-e52d-4d15-be89-131ea8f03858.jpeg)

They have been scaled to ratio 1.6, e.g. 1600x1000.

```bash
use ffmpeg.nu *

let troop = open troops/panoceania/orc.nuon

let blank = ffmpeg blank white 1600 1000 --output (mktemp --tmpdir XXXXXXX.png)
let res = [$blank, $troop.skin] | ffmpeg combine "[1:v]scale=iw*0.5:ih*0.5[ovrl];[0:v][ovrl]overlay=50:50" --output (mktemp --tmpdir XXXXXXX.png)
let res = [$res, $troop.icon] | ffmpeg combine "[1:v]scale=iw*0.5:ih*0.5[ovrl];[0:v][ovrl]overlay=50:50" --output (mktemp --tmpdir XXXXXXX.png)
let res = $troop.hi | enumerate | reduce --fold $res { |it, acc|
    let filter = $"[1:v]scale=iw*0.5:ih*0.5[ovrl];[0:v][ovrl]overlay=50:(50 + $it.index * 50)"
    [$acc, $it.item] | ffmpeg combine $filter --output (mktemp --tmpdir XXXXXXX.png)
}

feh $res
```

[video-1]: https://youtu.be/DhcczP8GJhE
[video-2]: https://youtu.be/fX7fCxJVDd4
