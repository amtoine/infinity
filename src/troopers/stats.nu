use common.nu [
    BOLD_FONT, REGULAR_FONT, BASE_IMAGE, CANVAS, DIRS,
    put-version, ffmpeg-text,
]

use std iter

const NAME_BOX = { x: 480, y: 80, w: (1560 - 480), h: (160 - 80) }
const NAME_OFFSET_X = 28
const NAME_POS = { x: $"($NAME_BOX.x)+($NAME_OFFSET_X)", y: $"($NAME_BOX.y)+($NAME_BOX.h / 2)-th/2" }
const NAME_FONT = { fontfile: $BOLD_FONT, fontcolor: "white", fontsize: 45 }

const ISC_POS = { x: ($NAME_BOX.x + $NAME_OFFSET_X), y: ($NAME_BOX.y - $NAME_OFFSET_X) }
const CLASSIFICATION_POS = { x: $"($NAME_BOX.x + $NAME_BOX.w - $NAME_OFFSET_X)-tw", y: $ISC_POS.y }
const ISC_FONT = { fontfile: $REGULAR_FONT, fontcolor: "black", fontsize: 30 }

################################################################################
###### EQUIPMENT BOXES #########################################################
################################################################################
const QR_CODE_SIZE = 4     # passed to --size
const QR_CODE_MARGIN = 1   # passed to --margin
const QR_CODE_WIDTH = 105  # the final width of the QR code
################################################################################

const NAME_2_BOX = { x: 810, y: 785, w: (1560 - ($QR_CODE_WIDTH + 10) - 810), h: (840 - 785) }
const NAME_2_OFFSET_X = 10
const NAME_2_POS = { x: $"($NAME_2_BOX.x)+($NAME_2_OFFSET_X)", y: $"($NAME_2_BOX.y)+($NAME_2_BOX.h / 2)-th/2" }
const NAME_2_FONT = { fontfile: $REGULAR_FONT, fontcolor: "white", fontsize: 30 }

const ICON_BOX = { x: 35, y: 35, w: (155 - 35), h: (155 - 35) }

const CHARACTERISTICS_BOX = { x: 35, y: 175, w: (120 - 35), h: null }
const CHARACTERISTICS_V_SPACE = 10
const CHARACTERISTICS_IMAGE_SIZE = 70 + 5
const CHARACTERISTICS_TYPE_POS = {
    x: $"($CHARACTERISTICS_BOX.x + $CHARACTERISTICS_BOX.w // 2)-tw/2",
    y: $"($CHARACTERISTICS_BOX.y + 25)-th/2",
}
const CHARACTERISTICS_TYPE_FONT = { fontfile: $BOLD_FONT, fontcolor: "white", fontsize: 30 }

const FACTION_POS = { x: 1455, y: 500 }

const STAT_KEYS_BOX = { x: 480, y: 180, w: (1560 - 480), h: (245 - 180) }
const STAT_VALS_BOX = {
    x: $STAT_KEYS_BOX.x,
    y: 265,
    w: $STAT_KEYS_BOX.w,
    h: $STAT_KEYS_BOX.h,
}
const STAT_H_SPACE = 108
const STAT_OFFSET_X = 60
const STAT_FONT = { fontfile: $REGULAR_FONT, fontcolor: "white", fontsize: 30 }

const MINI_OVERLAY = { kind: "overlay",  options: { x: "320-w/2", y: "H-h-50" } }
const QR_CODE_OVERLAY = { kind: "overlay",  options: { x: "1560-w", y: $"($NAME_2_BOX.y + $NAME_2_BOX.h)-h" } }

const ALLOWED_FACTIONS_OFFSET = { x: 50, y: 50 }
const ALLOWED_FACTIONS_IMAGE_SIZE = 70 + 10

################################################################################
###### EQUIPMENT BOXES #########################################################
################################################################################
const EQUIPMENT_BOXES_V_SPACE = 20
const EMPTY_EQUIPMENT_BOX_HEIGHT = 60
const FULL_EQUIPMENT_BOX_HEIGHT = 105

const CANVAS_MARGINS = { top: 0, left: 35, right: 0, bottom: 960 }

# the most bottom "equipment" box, i.e. the "peripheral" one, used as a base for
# the other "equipment" boxes
const EQUIPMENT_BOX = {
    x: $CANVAS_MARGINS.left,
    y: ($CANVAS_MARGINS.bottom - $FULL_EQUIPMENT_BOX_HEIGHT),
    w: (790 - $CANVAS_MARGINS.left),
    h: null,
}
# the horizontal offset of text in "equipment" boxes
const EQUIPMENT_OFFSET_X = 10
const EQUIPMENT_TITLE_POS = { x: $"($EQUIPMENT_BOX.x)+($EQUIPMENT_OFFSET_X)", y: $"($EQUIPMENT_BOX.y +  4 / 15 * $FULL_EQUIPMENT_BOX_HEIGHT)-th/2" }
const EQUIPMENT_POS =       { x: $"($EQUIPMENT_BOX.x)+($EQUIPMENT_OFFSET_X)", y: $"($EQUIPMENT_BOX.y + 11 / 15 * $FULL_EQUIPMENT_BOX_HEIGHT)-th/2" }
const EQUIPMENT_FONT_SIZE = 22
const EQUIPMENT_TITLE_FONT = { fontfile: $BOLD_FONT, fontcolor: "white", fontsize: ($EQUIPMENT_FONT_SIZE + 6) }
const EQUIPMENT_FONT = { fontfile: $REGULAR_FONT, fontcolor: "white", fontsize: $EQUIPMENT_FONT_SIZE }

# used to build lists of things dynamically
const LIST_SEPARATOR = ", "
const LIST_SEPARATOR_V_OFFSET = 10

# the horizontal space a character takes in the "equipment" lists
const EQUIPMENT_CHAR_SIZE = $EQUIPMENT_FONT.fontsize * 0.6
################################################################################

# the vertical row positions in the bottom base "equipment" box, i.e. the "peripheral" box
const BOTTOM_FIRST_ROW_Y = 885
const BOTTOM_SECOND_ROW_Y = 930

const MELEE_BOX = { x: 810, y: 855, w: (1335 - 810), h: (960 - 855) }
const MELEE_OFFSET_X = 10
const MELEE_WEAPONS_TITLE_POS = { x: $"($MELEE_BOX.x)+($MELEE_OFFSET_X)", y: $"($BOTTOM_FIRST_ROW_Y)-th/2" }
const MELEE_WEAPONS_POS = { x: $"($MELEE_BOX.x)+($MELEE_OFFSET_X)", y: $"($BOTTOM_SECOND_ROW_Y)-th/2" }
const MELEE_FONT_SIZE = 30
const MELEE_WEAPONS_TITLE_FONT  = { fontfile: $BOLD_FONT, fontcolor: "white", fontsize: ($MELEE_FONT_SIZE - 2) }
const MELEE_WEAPONS_FONT = { fontfile: $REGULAR_FONT, fontcolor: "white", fontsize: ($MELEE_FONT_SIZE - 8) }

const SWC_BOX = { x: 1355, y: 855, w: (1445 - 1355), h: (960 - 855) }
const SWC_TITLE_POS = { x: $"($SWC_BOX.x)+($SWC_BOX.w // 2)-tw/2", y: $"($BOTTOM_FIRST_ROW_Y)-th/2" }
const SWC_POS = { x: $"($SWC_BOX.x)+($SWC_BOX.w // 2)-tw/2", y: $"($BOTTOM_SECOND_ROW_Y)-th/2" }
const SWC_FONT_SIZE = 30
const SWC_TITLE_FONT = { fontfile: $BOLD_FONT, fontcolor: "white", fontsize: $SWC_FONT_SIZE }
const SWC_FONT = { fontfile: $REGULAR_FONT, fontcolor: "white", fontsize: $SWC_FONT_SIZE }

const C_BOX = { x: 1460, y: 855, w: (1560 - 1460), h: (960 - 855) }
const C_TITLE_POS = { x: $"($C_BOX.x)+($C_BOX.w // 2)-tw/2", y: $"($BOTTOM_FIRST_ROW_Y)-th/2" }
const C_POS = { x: $"($C_BOX.x)+($C_BOX.w // 2)-tw/2", y: $"($BOTTOM_SECOND_ROW_Y)-th/2" }
const C_FONT_SIZE = 30
const C_TITLE_FONT = { fontfile: $BOLD_FONT, fontcolor: "white", fontsize: $C_FONT_SIZE }
const C_FONT = { fontfile: $REGULAR_FONT, fontcolor: "white", fontsize: $C_FONT_SIZE }

const SPECIAL_SKILLS_BOX = { x: 1135, y: 350, w: (1560 - 1135), h: null }
const SPECIAL_SKILLS_OFFSET = { x: 10, y: 80 }
const SPECIAL_SKILLS_V_BASE = 100
const SPECIAL_SKILLS_V_SPACE = 30
const SPECIAL_SKILLS_TITLE_POS = { x: $"($SPECIAL_SKILLS_BOX.x)+($SPECIAL_SKILLS_OFFSET.x)", y: $"($SPECIAL_SKILLS_BOX.y)+30-th/2" }
const SPECIAL_SKILLS_TITLE_FONT = { fontfile: $BOLD_FONT,    fontcolor: "white", fontsize: 32 }
const SPECIAL_SKILLS_FONT       = { fontfile: $REGULAR_FONT, fontcolor: "white", fontsize: 18 }

# marks "spec" equipments or skill in bold
def equipment-or-skill-to-text [
    equipment_or_skill,  # string | record<name: string, mod?: string, spec?: bool>
    base_font: record<fontfile: path, fontcolor: string, fontsize: int>,
    pos: record<x: any, y: any>,
]: [ nothing -> record<transform: record, text: string> ] {
    let equipment_or_skill = match ($equipment_or_skill | describe --detailed).type {
        "string" => { name: $equipment_or_skill },
        "record" => $equipment_or_skill,
    }

    let text = if $equipment_or_skill.mod? == null {
        $equipment_or_skill.name
    } else {
        $"($equipment_or_skill.name) \(($equipment_or_skill.mod)\)"
    }
    let font = $base_font | if $equipment_or_skill.spec? == true {
        update fontfile $BOLD_FONT | update fontsize { $in * 1.10 }
    } else {
        $in
    }

    { transform: (ffmpeg-text $text $pos $font), text: $text }
}

def equipments-to-text [
    x: record<
        equipments: list<any>,
        box: record<x: int, y: int, w: int, h: int>,
        title_pos: record<x: any, y: any>,
        text_pos: record<x: any, y: any>,
    >
]: [ nothing -> list<record> ] {
    if $x.equipments == [] {
        return []
    }

    $x.equipments
        | iter intersperse $LIST_SEPARATOR
        | reduce --fold { transforms: [], pos: $x.text_pos } { |it, acc|
            let pos = if $it == $LIST_SEPARATOR {
                $acc.pos | update y { $"($in)+($LIST_SEPARATOR_V_OFFSET)" }
            } else {
                $acc.pos
            }
            let res = equipment-or-skill-to-text $it $EQUIPMENT_FONT $pos
            let next_pos = $acc.pos
                | update x { $"($in) + (($res.text | str length) * $EQUIPMENT_CHAR_SIZE)" }

            { transforms: ($acc.transforms | append $res.transform), pos: $next_pos }
        }
        | get transforms
}

export def gen-stats-page [
    troop: record<
        isc: string,
        name: string,
        short_name: string,
        faction: string,
        allowed_factions: list<string>,
        asset: string,
        classification: string,
        reference: string,
        type: string,
        characteristics: list<string>,
        stats: record<
            MOV: string,
            CC: int,
            BS: int,
            PH: int,
            WIP: int,
            ARM: int,
            BTS: int,
            VITA: int,
            S: int,
            AVA: int,
        >,
        special_skills: list<any>,
        weaponry: list<any>,
        equipment: list<any>,
        peripheral: list<any>,
        melee_weapons: list<any>,
        SWC: number,
        C: int
    >,
    color: string,
    output: path,
    modifiers: table<name: string, mod: record>,
] {
    # NOTE: this is required because of signature issues in Nushell
    let modifiers = $modifiers | transpose --header-row | into record

    # NOTE: because we assume the box will be full at the start
    const EQUIPMENT_BOX_DELTA_HEIGHT = $FULL_EQUIPMENT_BOX_HEIGHT - $EMPTY_EQUIPMENT_BOX_HEIGHT

    # first "equipment" box from bottom
    let peripheral = $troop.peripheral | if $in == [] {{
        equipments: $in,
        box: ($EQUIPMENT_BOX | update h $EMPTY_EQUIPMENT_BOX_HEIGHT | update y { $in + $EQUIPMENT_BOX_DELTA_HEIGHT }),
        title_pos: ($EQUIPMENT_TITLE_POS | update y { $"($in)+($EQUIPMENT_BOX_DELTA_HEIGHT)" }),
        text_pos: ($EQUIPMENT_POS | update y { $"($in)+($EQUIPMENT_BOX_DELTA_HEIGHT)" }),
    }} else {{
        equipments: $in,
        box: ($EQUIPMENT_BOX | update h $FULL_EQUIPMENT_BOX_HEIGHT),
        title_pos: $EQUIPMENT_TITLE_POS,
        text_pos: $EQUIPMENT_POS,
    }}

    # second "equipment" box from bottom
    let equipment = $troop.equipment | if $in == [] {{
        equipments: $in,
        box: ($peripheral.box | update y { $in - ($EQUIPMENT_BOXES_V_SPACE + $EMPTY_EQUIPMENT_BOX_HEIGHT) } | update h $EMPTY_EQUIPMENT_BOX_HEIGHT),
        title_pos: ($peripheral.title_pos | update y { $"($in)-($EQUIPMENT_BOXES_V_SPACE + $EMPTY_EQUIPMENT_BOX_HEIGHT)" }),
        text_pos: ($peripheral.text_pos | update y { $"($in)-($EQUIPMENT_BOXES_V_SPACE + $EMPTY_EQUIPMENT_BOX_HEIGHT)" }),
    }} else {{
        equipments: $in,
        box: ($peripheral.box | update y { $in - ($EQUIPMENT_BOXES_V_SPACE + $FULL_EQUIPMENT_BOX_HEIGHT) } | update h $FULL_EQUIPMENT_BOX_HEIGHT),
        title_pos: ($peripheral.title_pos | update y { $"($in)-($EQUIPMENT_BOXES_V_SPACE + $FULL_EQUIPMENT_BOX_HEIGHT)" }),
        text_pos: ($peripheral.text_pos | update y { $"($in)-($EQUIPMENT_BOXES_V_SPACE + $FULL_EQUIPMENT_BOX_HEIGHT)" }),
    }}

    # third and last "equipment" box from bottom
    let weaponry = $troop.weaponry | if $in == [] {{
        equipments: $in,
        box: ($equipment.box | update y { $in - ($EQUIPMENT_BOXES_V_SPACE + $EMPTY_EQUIPMENT_BOX_HEIGHT) } | update h $EMPTY_EQUIPMENT_BOX_HEIGHT),
        title_pos: ($equipment.title_pos | update y { $"($in)-($EQUIPMENT_BOXES_V_SPACE + $EMPTY_EQUIPMENT_BOX_HEIGHT)" }),
        text_pos: ($equipment.text_pos | update y { $"($in)-($EQUIPMENT_BOXES_V_SPACE + $EMPTY_EQUIPMENT_BOX_HEIGHT)" }),
    }} else {{
        equipments: $in,
        box: ($equipment.box | update y { $in - ($EQUIPMENT_BOXES_V_SPACE + $FULL_EQUIPMENT_BOX_HEIGHT) } | update h $FULL_EQUIPMENT_BOX_HEIGHT),
        title_pos: ($equipment.title_pos | update y { $"($in)-($EQUIPMENT_BOXES_V_SPACE + $FULL_EQUIPMENT_BOX_HEIGHT)" }),
        text_pos: ($equipment.text_pos | update y { $"($in)-($EQUIPMENT_BOXES_V_SPACE + $FULL_EQUIPMENT_BOX_HEIGHT)" }),
    }}

    let characteristics_box = $CHARACTERISTICS_BOX | update h (
        $CHARACTERISTICS_BOX.w // 2 +  # because text is twice larger
        (if ($troop.characteristics | is-empty) { 0 } else { $CHARACTERISTICS_V_SPACE }) +
        $CHARACTERISTICS_IMAGE_SIZE * ($troop.characteristics | length)
    )
    let special_skills_box = $SPECIAL_SKILLS_BOX | update h (
        $SPECIAL_SKILLS_V_BASE + $SPECIAL_SKILLS_V_SPACE * (($troop.special_skills | length) - 1)
    )

    let qrcode = mktemp --tmpdir infinity-XXXXXXX.png
    log info $"generating QR code in (ansi purple)($qrcode)(ansi reset)"
    qrencode --margin $QR_CODE_MARGIN --size $QR_CODE_SIZE -o $qrcode $troop.reference
    let qrcode = $qrcode
        | ffmpeg apply $"scale=($QR_CODE_WIDTH):($QR_CODE_WIDTH)" --output (mktemp --tmpdir infinity-XXXXXXX.png)

    let transforms = [
        (ffmpeg-text $"ISC: ($troop.isc)"  $ISC_POS            $ISC_FONT),
        (ffmpeg-text $troop.classification $CLASSIFICATION_POS $ISC_FONT),

        { kind: "drawbox",  options: { ...$NAME_BOX, color: $"($color)@1.0", t: "fill" } },
        { kind: "drawbox",  options: { ...$NAME_BOX, color: "black@0.4",     t: "5" } },
        (ffmpeg-text $troop.name $NAME_POS $NAME_FONT),

        { kind: "drawbox",  options: { ...$NAME_2_BOX, color: $"($color)@1.0", t: "fill" } },
        { kind: "drawbox",  options: { ...$NAME_2_BOX, color: "black@0.4",     t: "5" } },
        (ffmpeg-text $troop.short_name $NAME_2_POS $NAME_2_FONT),

        { kind: "drawbox",  options: { ...$ICON_BOX, color: "black@0.5", t: "fill" } },
        { kind: "drawbox",  options: { ...$ICON_BOX, color: "black@0.5", t: "5" } },

        { kind: "drawbox",  options: { ...$characteristics_box, color: "black@0.5", t: "fill" } },
        { kind: "drawbox",  options: { ...$characteristics_box, color: "black@0.5", t: "5" } },
        (ffmpeg-text $troop.type $CHARACTERISTICS_TYPE_POS $CHARACTERISTICS_TYPE_FONT),

        { kind: "drawbox",  options: { ...$STAT_KEYS_BOX, color: $"($color)@1.0", t: "fill" } },
        { kind: "drawbox",  options: { ...$STAT_KEYS_BOX, color: "black@0.4",     t: "5" } },

        { kind: "drawbox",  options: { ...$STAT_VALS_BOX, color: "black@0.5",     t: "fill" } },
        { kind: "drawbox",  options: { ...$STAT_VALS_BOX, color: "black@0.5",     t: "5" } },
        ...(
            $troop.stats | transpose k v | enumerate | each { |it|
                const MARTIAL_ARTS = [
                    [level, attack, opponent, burst      ];
                    [    1,      0,       -3, [0]        ],
                    [    2,     +3,       -3, [0]        ],
                    [    3,     +3,       -3, [+1SD]     ],
                    [    4,     +3,       -3, [+1B]      ],
                    [    5,     +3,       -3, [+1B, +1SD]],
                ]

                let stat = match $it.item.k {
                    "BS" => {
                        let skill = $modifiers."BS Attack"?
                        if $skill != null and $skill.k != "AMMO" {
                            let v = $skill.v | into int
                            match $skill.x? {
                                # NOTE: no "-" (see p.68 of the rulebook)
                                 "+" => $"($it.item.v)+($v)",
                                null => $"($it.item.v)->($v)",
                            }
                        }
                    },
                    "CC" => {
                        let cc_skill = $modifiers."CC Attack"?
                        let ma_skill = $modifiers."Martial Arts"?

                        let cc_value = if $cc_skill != null and $cc_skill.k == "" {
                            let v = $cc_skill.v | into int
                            match $cc_skill.x? {
                                # NOTE: no "-" (see p.68 of the rulebook)
                                 "+" => { $"($it.item.v)+($v)" },
                                null => { $"($it.item.v)->($v)" },
                            }
                        } else {
                            $it.item.v
                        }

                        if $ma_skill != null {
                            let art = $MARTIAL_ARTS | where level == $ma_skill.v | into record
                            $cc_value + $art.attack
                        } else {
                            $cc_value
                        }
                    },
                    "MOV" => {
                        let skill = $modifiers."Terrain"?
                        let mov = $it.item.v | parse "{f}-{s}" | into record | into int f s

                        if $skill != null {
                            match $skill.v {
                                "Total" => $"($mov.f)+1/($mov.s)",
                                _ => $"($mov.f)~1/($mov.s)",
                            }
                        } else {
                            $"($mov.f)/($mov.s)"
                        }
                    },
                    _ => null,
                }
                | default $it.item.v

                [
                    (ffmpeg-text $"($it.item.k)" { x: $"($STAT_KEYS_BOX.x)+($STAT_OFFSET_X)+($it.index)*($STAT_H_SPACE)-tw/2", y: $"($STAT_KEYS_BOX.y)+($STAT_KEYS_BOX.h / 2)-th/2" } $STAT_FONT),
                    (ffmpeg-text $"($stat)" { x: $"($STAT_VALS_BOX.x)+($STAT_OFFSET_X)+($it.index)*($STAT_H_SPACE)-tw/2", y: $"($STAT_VALS_BOX.y)+($STAT_VALS_BOX.h / 2)-th/2" } $STAT_FONT),
                ]
            } | flatten
        ),

        ...(
            if ($troop.special_skills | is-empty) {
                []
            } else {
                let box = [
                    { kind: "drawbox",  options: { ...$special_skills_box, color: "black@0.5", t: "fill" } },
                    { kind: "drawbox",  options: { ...$special_skills_box, color: "black@0.5", t: "5" } },
                    (ffmpeg-text "Special skills" $SPECIAL_SKILLS_TITLE_POS $SPECIAL_SKILLS_TITLE_FONT),
                ]
                let skills = $troop.special_skills | enumerate | each { |it|
                    let pos = {
                        x: $"($SPECIAL_SKILLS_BOX.x)+($SPECIAL_SKILLS_OFFSET.x)",
                        y: $"($SPECIAL_SKILLS_BOX.y)+($SPECIAL_SKILLS_OFFSET.y)+($SPECIAL_SKILLS_V_SPACE)*($it.index)-th/2",
                    }

                    [(equipment-or-skill-to-text $it.item $SPECIAL_SKILLS_FONT $pos).transform]
                }
                $box | append ($skills | flatten)
            }
        ),

        { kind: "drawbox",  options: { ...$weaponry.box, color: "black@0.5", t: "fill" } },
        { kind: "drawbox",  options: { ...$weaponry.box, color: "black@0.5", t: "5" } },
        (ffmpeg-text "WEAPONRY" $weaponry.title_pos $EQUIPMENT_TITLE_FONT),
        ...(equipments-to-text $weaponry),

        { kind: "drawbox",  options: { ...$equipment.box, color: "black@0.5", t: "fill" } },
        { kind: "drawbox",  options: { ...$equipment.box, color: "black@0.5", t: "5" } },
        (ffmpeg-text "EQUIPMENT" $equipment.title_pos $EQUIPMENT_TITLE_FONT),
        ...(equipments-to-text $equipment),

        { kind: "drawbox",  options: { ...$peripheral.box, color: "black@0.5", t: "fill" } },
        { kind: "drawbox",  options: { ...$peripheral.box, color: "black@0.5", t: "5" } },
        (ffmpeg-text "PERIPHERAL" $peripheral.title_pos $EQUIPMENT_TITLE_FONT),
        ...(equipments-to-text $peripheral),

        { kind: "drawbox",  options: { ...$MELEE_BOX, color: "black@0.5", t: "fill" } },
        { kind: "drawbox",  options: { ...$MELEE_BOX, color: "black@0.5", t: "5" } },
        (ffmpeg-text "MELEE WEAPONS" $MELEE_WEAPONS_TITLE_POS  $MELEE_WEAPONS_TITLE_FONT),
        (do {
            let text = $troop.melee_weapons | each { |it|
                match ($it | describe --detailed).type {
                    "string" => $it,
                    "record" => $"($it.name) \(($it.mod)\)",
                }
            } | str join ", "
            ffmpeg-text $text $MELEE_WEAPONS_POS $MELEE_WEAPONS_FONT
        }),

        { kind: "drawbox",  options: { ...$SWC_BOX, color: "black@0.5", t: "fill" } },
        { kind: "drawbox",  options: { ...$SWC_BOX, color: "black@0.5", t: "5" } },
        (ffmpeg-text "SWC"           $SWC_TITLE_POS  $SWC_TITLE_FONT),
        (ffmpeg-text $"($troop.SWC)" $SWC_POS        $SWC_FONT),

        { kind: "drawbox",  options: { ...$C_BOX, color: "black@0.5", t: "fill" } },
        { kind: "drawbox",  options: { ...$C_BOX, color: "black@0.5", t: "5" } },
        (ffmpeg-text "C"           $C_TITLE_POS  $C_TITLE_FONT),
        (ffmpeg-text $"($troop.C)" $C_POS        $C_FONT),
    ]

    let tmp = ffmpeg create ($BASE_IMAGE | ffmpeg options) --output (mktemp --tmpdir infinity-XXXXXXX.png)
        | [$in, ({ parent: $DIRS.minis, stem: $troop.asset, extension: "png" } | path join)]
            | ffmpeg combine ($MINI_OVERLAY | ffmpeg options) --output (mktemp --tmpdir infinity-XXXXXXX.png)
        | if $troop.faction != null {
            [$in, ({ parent: $DIRS.factions, stem: $troop.faction, extension: "png" } | path join)]
                | ffmpeg combine $"[1:v]format=rgba,colorchannelmixer=aa=0.5[ol];[0:v][ol]overlay=x=($FACTION_POS.x)-w/2:y=($FACTION_POS.y)-h/2" --output (mktemp --tmpdir infinity-XXXXXXX.png)
        } else {
            $in
        }
        | [$in, $qrcode] | ffmpeg combine ($QR_CODE_OVERLAY | ffmpeg options) --output (mktemp --tmpdir infinity-XXXXXXX.png)
        | ffmpeg mapply ($transforms | compact | each { ffmpeg options })

    let tmp = $troop.characteristics
        | enumerate
        | reduce --fold $tmp { |it, acc|
            [$acc, ({ parent: $DIRS.characteristics, stem: $it.item, extension: "png" } | path join)] | ffmpeg combine ({
                kind: "overlay",
                options: {
                    x: $"($characteristics_box.x + $characteristics_box.w // 2)-w/2",
                    y: $"($characteristics_box.y + $CHARACTERISTICS_IMAGE_SIZE)+(5)+($it.index * $CHARACTERISTICS_IMAGE_SIZE)-h/2",
                },
            } | ffmpeg options) --output (mktemp --tmpdir infinity-XXXXXXX.png)
        }
        | [$in, ({ parent: $DIRS.icons, stem: ($troop.asset | str replace --regex '\..*$' ''), extension: "png" } | path join) ] | ffmpeg combine ({
            kind: "overlay",
            options: { x: $"($ICON_BOX.x + $ICON_BOX.w // 2)-w/2", y: $"($ICON_BOX.y + $ICON_BOX.h // 2)-h/2" },
        } | ffmpeg options) --output (mktemp --tmpdir infinity-XXXXXXX.png)

    let tmp = $troop.allowed_factions
        | enumerate
        | reduce --fold $tmp { |it, acc|
            [$acc, ({ parent: $DIRS.allowed_factions, stem: $it.item, extension: "png" } | path join)] | ffmpeg combine ({
                kind: "overlay",
                options: {
                    x: $"($STAT_VALS_BOX.x)+($ALLOWED_FACTIONS_OFFSET.x)+($it.index * $ALLOWED_FACTIONS_IMAGE_SIZE)-w/2",
                    y: $"($STAT_VALS_BOX.y)+($STAT_VALS_BOX.h)+($ALLOWED_FACTIONS_OFFSET.y)-h/2",
                },
            } | ffmpeg options) --output (mktemp --tmpdir infinity-XXXXXXX.png)
        }

    let tmp = $tmp | put-version

    let out = $output | path parse | update stem { $in ++ ".1" } | path join
    cp $tmp $out
    log info $"\t(ansi purple)($out)(ansi reset)"
}
