## Troop cards

| Inspiration                                           | Mine (stat page)                   | Mine (charts page)                 |
|-------------------------------------------------------|------------------------------------|------------------------------------|
| ![](assets/4fb8339e-3d5d-4f70-9e3e-3f76bb449dd4.jpeg) | ![](assets/panoceania-orc.1.1.png) | ![](assets/panoceania-orc.1.2.png) |
| ![](assets/c10788ac-cffd-4494-8f02-d7eaafcc30fa.jpeg) | ![](assets/jsa-shikami.1.1.png)    | ![](assets/jsa-shikami.1.2.png)    |
| ![](assets/e3948ce6-e52d-4d15-be89-131ea8f03858.jpeg) |                                    |                                    |

> Sources:
> - [_New Infinity N5 Fireteam Rules; All You Need To Know! | Infinity N5 Week_ from _OnTableTop_][video-1]
> - [Getting started with Infinity N5 – The Infinity Institute][video-2]
>
> Screenshots of cards from these videos have been scaled to ratio 1.6, e.g. 1600x1000.

## Build cards
```nushell
nu make.nu
```

## Compare images
```nushell
use make.nu

let changes = {
    multi-profile-troopers : (make main compare "a9f44c1f234361d41e275f03ce74934413f13b97" "ee1a163a512f0100e0ddcac76a2901da7ec9bd4a" ""),
    fix                    : (make main compare "41032c8fcca55e71ae5fb76ffedf40d158544db2" "ed5894b1d2ef2e424dec029bb9dc5b0cb0f2400e" ""),
    cc-mod                 : (make main compare "ed5894b1d2ef2e424dec029bb9dc5b0cb0f2400e" "42b2b279967a4c0e7eed1185c9c9226f3661f4a8" ""),
    ffmpeg-colors          : (make main compare "42b2b279967a4c0e7eed1185c9c9226f3661f4a8" "a00c5f77e558479bbd8f5f93a81a0196916e2cde" ""),
}
```

## Credits
- statistics have been taken from the official [Infinity ARMY online tool][army]
- assets have been taken from the official [Infinity ARMY online tool][army]
- assets of miniatures have been taken from the official [Infinity online store][store]

[video-1]: https://youtu.be/DhcczP8GJhE
[video-2]: https://youtu.be/fX7fCxJVDd4
[army]: https://infinityuniverse.com/army/infinity
[store]: https://store.corvusbelli.com/en/infinity/wargame
