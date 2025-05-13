use ../common.nu [
    BOLD_FONT, REGULAR_FONT, BASE_COLOR, CANVAS, DIRS, SCALE
    put-version, ffmpeg-text,
]

use std iter

const CANVAS_MARGINS = {
    top: (35 * $SCALE),
    left: (35 * $SCALE),
    right: (($CANVAS.w - 40) * $SCALE),
    bottom: (($CANVAS.h - 40) * $SCALE),
}

const BASE_IMAGE = { kind: "color", options: {
    c: $BASE_COLOR,
    s: $"($CANVAS.w * $SCALE)x($CANVAS.h * $SCALE)",
    d: 1,
} }

const FACTION_POS = {
    x: ($CANVAS_MARGINS.right - 105 * $SCALE),
    y: ($CANVAS.h * $SCALE // 2),
}
const MINI_OVERLAY = { kind: "overlay",  options: {
    x: $"(320 * $SCALE)-w/2",
    y: $"($CANVAS.h * $SCALE)-(50 * $SCALE)-h",
} }

const BOX_BORDER = 5 * $SCALE

################################################################################
###### ICON and CHARACTERISTICS BOXES ##########################################
################################################################################
const ICON_BOX = {
    x: $CANVAS_MARGINS.left,
    y: $CANVAS_MARGINS.top,
    w: (155 * $SCALE - $CANVAS_MARGINS.left),
    h: (155 * $SCALE - $CANVAS_MARGINS.top),
}

const CHARACTERISTICS_BOX = {
    x: $CANVAS_MARGINS.left,
    y: ($ICON_BOX.y + $ICON_BOX.h + 20 * $SCALE),
    w: (120 * $SCALE - $CANVAS_MARGINS.left),
    h: null,
}
# space between the trooper type and the first characteristics asset
const CHARACTERISTICS_V_SPACE = 5 * $SCALE
# size of a characteristics asset
const CHARACTERISTICS_IMAGE_SIZE = 70 * $SCALE
const CHARACTERISTICS_TYPE_POS = {
    x: $"($CHARACTERISTICS_BOX.x + $CHARACTERISTICS_BOX.w // 2)-tw/2",
    y: $"($CHARACTERISTICS_BOX.y + 25 * $SCALE)-th/2",
}
const CHARACTERISTICS_TYPE_FONT = { fontfile: $BOLD_FONT, fontcolor: "white", fontsize: (30 * $SCALE) }
################################################################################

################################################################################
###### TOP #####################################################################
################################################################################
const NAME_BOX = {
    x: (480 * $SCALE),
    y: ($CANVAS_MARGINS.top + 45 * $SCALE),
    w: ($CANVAS_MARGINS.right - 480 * $SCALE),
    h: (160 * $SCALE - ($CANVAS_MARGINS.top + 45 * $SCALE)),
}
const NAME_OFFSET_X = 28 * $SCALE
const NAME_POS = { x: $"($NAME_BOX.x)+($NAME_OFFSET_X)", y: $"($NAME_BOX.y)+($NAME_BOX.h / 2)-th/2" }
const NAME_FONT = { fontfile: $BOLD_FONT, fontcolor: "white", fontsize: (45 * $SCALE) }

const ISC_FONT = { fontfile: $REGULAR_FONT, fontcolor: "black", fontsize: (30 * $SCALE) }
const ISC_POS = { x: ($NAME_BOX.x + $NAME_OFFSET_X), y: ($NAME_BOX.y - $ISC_FONT.fontsize) }
const CLASSIFICATION_POS = { x: $"($NAME_BOX.x + $NAME_BOX.w - $NAME_OFFSET_X)-tw", y: $ISC_POS.y }

const STAT_KEYS_BOX = {
    x: $NAME_BOX.x,
    y: ($NAME_BOX.y + $NAME_BOX.h + 20 * $SCALE),
    w: ($CANVAS_MARGINS.right - $NAME_BOX.x),
    h: (245 * $SCALE - ($NAME_BOX.y + $NAME_BOX.h + 20 * $SCALE)),
}
const STAT_VALS_BOX = {
    x: $STAT_KEYS_BOX.x,
    y: ($STAT_KEYS_BOX.y + $STAT_KEYS_BOX.h + 20 * $SCALE),
    w: $STAT_KEYS_BOX.w,
    h: $STAT_KEYS_BOX.h,
}
# horizontal space between stats
const STAT_H_SPACE = 108 * $SCALE
# horizontal offset for the first stat (MOV)
const STAT_OFFSET_X = 60 * $SCALE
const STAT_FONT = { fontfile: $REGULAR_FONT, fontcolor: "white", fontsize: (30 * $SCALE) }

# offset to the bottom-left corner of the "stat values" box
const ALLOWED_FACTIONS_OFFSET = {
    x: (50 * $SCALE),
    y: (50 * $SCALE),
}
const ALLOWED_FACTIONS_IMAGE_SIZE = 70 * $SCALE
const ALLOWED_FACTIONS_IMAGE_H_SPACE = 10 * $SCALE

const SPECIAL_SKILLS_BOX = {
    x: ($CANVAS_MARGINS.right - 425 * $SCALE),
    y: ($STAT_VALS_BOX.y + $STAT_VALS_BOX.h + 20 * $SCALE),
    w: (425 * $SCALE),
    h: null,
}
# offset for the first special skill
const SPECIAL_SKILLS_OFFSET = {
    x: (10 * $SCALE),
    y: (80 * $SCALE),
}
# the base height for the "special skill" box
const SPECIAL_SKILLS_V_BASE = 100 * $SCALE
# the vertical space between two special skills
const SPECIAL_SKILLS_V_SPACE = 30 * $SCALE
const SPECIAL_SKILLS_TITLE_POS = {
    x: $"($SPECIAL_SKILLS_BOX.x)+($SPECIAL_SKILLS_OFFSET.x)",
    y: $"($SPECIAL_SKILLS_BOX.y)+(30 * $SCALE)-th/2",
}
const SPECIAL_SKILLS_TITLE_FONT = { fontfile: $BOLD_FONT,    fontcolor: "white", fontsize: (32 * $SCALE) }
const SPECIAL_SKILLS_FONT       = { fontfile: $REGULAR_FONT, fontcolor: "white", fontsize: (18 * $SCALE) }
###### END TOP #################################################################

################################################################################
###### BOTTOM ##################################################################
################################################################################
const EQUIPMENT_BOXES_V_SPACE = 20 * $SCALE
const EMPTY_EQUIPMENT_BOX_HEIGHT = 60 * $SCALE
const FULL_EQUIPMENT_BOX_HEIGHT = 105 * $SCALE

# the most bottom "equipment" box, i.e. the "peripheral" one, used as a base for
# the other "equipment" boxes
const EQUIPMENT_BOX = {
    x: $CANVAS_MARGINS.left,
    y: ($CANVAS_MARGINS.bottom - $FULL_EQUIPMENT_BOX_HEIGHT),
    w: (790 * $SCALE - $CANVAS_MARGINS.left),
    h: null,
}
# the horizontal offset of text in "equipment" boxes
const EQUIPMENT_OFFSET_X = 10 * $SCALE
const EQUIPMENT_TITLE_POS = { x: $"($EQUIPMENT_BOX.x)+($EQUIPMENT_OFFSET_X)", y: $"($EQUIPMENT_BOX.y +  4 / 15 * $FULL_EQUIPMENT_BOX_HEIGHT)-th/2" }
const EQUIPMENT_POS =       { x: $"($EQUIPMENT_BOX.x)+($EQUIPMENT_OFFSET_X)", y: $"($EQUIPMENT_BOX.y + 11 / 15 * $FULL_EQUIPMENT_BOX_HEIGHT)-th/2" }
const EQUIPMENT_FONT_SIZE = 22 * $SCALE
const EQUIPMENT_TITLE_FONT = { fontfile: $BOLD_FONT, fontcolor: "white", fontsize: ($EQUIPMENT_FONT_SIZE + 6 * $SCALE) }
const EQUIPMENT_FONT = { fontfile: $REGULAR_FONT, fontcolor: "white", fontsize: $EQUIPMENT_FONT_SIZE }

# used to build lists of things dynamically
const LIST_SEPARATOR = ", "
const LIST_SEPARATOR_V_OFFSET = 10 * $SCALE
# the horizontal space a character takes in the "equipment" lists
const EQUIPMENT_CHAR_SIZE = $EQUIPMENT_FONT.fontsize * 0.6

# the vertical row positions in the bottom base "equipment" box, i.e. the "peripheral" box
const BOTTOM_FIRST_ROW_Y = 885 * $SCALE
const BOTTOM_SECOND_ROW_Y = 930 * $SCALE

const MELEE_BOX = {
    x: ($EQUIPMENT_BOX.x + $EQUIPMENT_BOX.w + 20 * $SCALE),
    y: ($CANVAS_MARGINS.bottom - $FULL_EQUIPMENT_BOX_HEIGHT),
    w: (1335 * $SCALE - ($EQUIPMENT_BOX.x + $EQUIPMENT_BOX.w + 20 * $SCALE)),
    h: $FULL_EQUIPMENT_BOX_HEIGHT,
}
# the horizontal offset of text in "melee" box
const MELEE_OFFSET_X = 10 * $SCALE
const MELEE_WEAPONS_TITLE_POS = { x: $"($MELEE_BOX.x)+($MELEE_OFFSET_X)", y: $"($MELEE_BOX.y +  4 / 15 * $FULL_EQUIPMENT_BOX_HEIGHT)-th/2" }
const MELEE_WEAPONS_POS =       { x: $"($MELEE_BOX.x)+($MELEE_OFFSET_X)", y: $"($MELEE_BOX.y + 11 / 15 * $FULL_EQUIPMENT_BOX_HEIGHT)-th/2" }
const MELEE_FONT_SIZE = 22 * $SCALE
const MELEE_WEAPONS_TITLE_FONT  = { fontfile: $BOLD_FONT, fontcolor: "white", fontsize: ($MELEE_FONT_SIZE + 6 * $SCALE) }
const MELEE_WEAPONS_FONT = { fontfile: $REGULAR_FONT, fontcolor: "white", fontsize: $MELEE_FONT_SIZE }

const SWC_BOX = {
    x: ($MELEE_BOX.x + $MELEE_BOX.w + 20 * $SCALE),
    y: ($CANVAS_MARGINS.bottom - $FULL_EQUIPMENT_BOX_HEIGHT),
    w: (1445 * $SCALE - ($MELEE_BOX.x + $MELEE_BOX.w + 20 * $SCALE)),
    h: $FULL_EQUIPMENT_BOX_HEIGHT,
}
const SWC_TITLE_POS = { x: $"($SWC_BOX.x)+($SWC_BOX.w // 2)-tw/2", y: $"($SWC_BOX.y +  4 / 15 * $FULL_EQUIPMENT_BOX_HEIGHT)-th/2" }
const SWC_POS =       { x: $"($SWC_BOX.x)+($SWC_BOX.w // 2)-tw/2", y: $"($SWC_BOX.y + 11 / 15 * $FULL_EQUIPMENT_BOX_HEIGHT)-th/2" }
const SWC_FONT_SIZE = 30 * $SCALE
const SWC_TITLE_FONT = { fontfile: $BOLD_FONT, fontcolor: "white", fontsize: $SWC_FONT_SIZE }
const SWC_FONT = { fontfile: $REGULAR_FONT, fontcolor: "white", fontsize: $SWC_FONT_SIZE }

const C_BOX = {
    x: ($SWC_BOX.x + $SWC_BOX.w + 15 * $SCALE),
    y: ($CANVAS_MARGINS.bottom - $FULL_EQUIPMENT_BOX_HEIGHT),
    w: ($CANVAS_MARGINS.right - ($SWC_BOX.x + $SWC_BOX.w + 15 * $SCALE)),
    h: $FULL_EQUIPMENT_BOX_HEIGHT,
}
const C_TITLE_POS = { x: $"($C_BOX.x)+($C_BOX.w // 2)-tw/2", y: $"($C_BOX.y +  4 / 15 * $FULL_EQUIPMENT_BOX_HEIGHT)-th/2" }
const C_POS =       { x: $"($C_BOX.x)+($C_BOX.w // 2)-tw/2", y: $"($C_BOX.y + 11 / 15 * $FULL_EQUIPMENT_BOX_HEIGHT)-th/2" }
const C_FONT_SIZE = 30 * $SCALE
const C_TITLE_FONT = { fontfile: $BOLD_FONT, fontcolor: "white", fontsize: $C_FONT_SIZE }
const C_FONT = { fontfile: $REGULAR_FONT, fontcolor: "white", fontsize: $C_FONT_SIZE }

const QR_CODE_SIZE = 4              # passed to --size
const QR_CODE_MARGIN = 1            # passed to --margin
const QR_CODE_WIDTH = 105 * $SCALE  # the final width of the QR code

const NAME_2_BOX = {
    x: ($EQUIPMENT_BOX.x + $EQUIPMENT_BOX.w + 20 * $SCALE),
    y: ($MELEE_BOX.y - 15 * $SCALE - 55 * $SCALE),
    w: ($CANVAS_MARGINS.right - ($QR_CODE_WIDTH + 10 * $SCALE) - ($EQUIPMENT_BOX.x + $EQUIPMENT_BOX.w + 20 * $SCALE)),
    h: (55 * $SCALE),
}
# the horizontal offset of text in "name 2" box
const NAME_2_OFFSET_X = 10 * $SCALE
const NAME_2_POS = { x: $"($NAME_2_BOX.x)+($NAME_2_OFFSET_X)", y: $"($NAME_2_BOX.y)+($NAME_2_BOX.h / 2)-th/2" }
const NAME_2_FONT = { fontfile: $REGULAR_FONT, fontcolor: "white", fontsize: (30 * $SCALE) }

const QR_CODE_OVERLAY = { kind: "overlay",  options: {
    x: $"($CANVAS_MARGINS.right)-w",
    y: $"($NAME_2_BOX.y + $NAME_2_BOX.h)-h",
} }
###### END BOTTOM ##############################################################

# marks "spec" equipments or skill in bold
def equipment-or-skill-to-text [
    equipment_or_skill,  # string | record<name: string, mod?: string, spec?: bool>
    base_font: record<fontfile: path, fontcolor: string, fontsize: number>,
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
        box: record<x: number, y: number, w: number, h: number>,
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
        faction: any, # string or null
        allowed_factions: list<string>,
        asset: string,
        classification: string,
        reference: string,
        type: string,
        characteristics: list<string>,
        stats: record,
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
        (if ($troop.characteristics | is-empty) { 0 } else { 2 * $CHARACTERISTICS_V_SPACE }) +
        ($CHARACTERISTICS_IMAGE_SIZE + $CHARACTERISTICS_V_SPACE) * ($troop.characteristics | length)
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
        { kind: "drawbox",  options: { ...$NAME_BOX, color: "black@0.4",     t: $"($BOX_BORDER)" } },
        (ffmpeg-text $troop.name $NAME_POS $NAME_FONT),

        { kind: "drawbox",  options: { ...$NAME_2_BOX, color: $"($color)@1.0", t: "fill" } },
        { kind: "drawbox",  options: { ...$NAME_2_BOX, color: "black@0.4",     t: $"($BOX_BORDER)" } },
        (ffmpeg-text $troop.short_name $NAME_2_POS $NAME_2_FONT),

        { kind: "drawbox",  options: { ...$ICON_BOX, color: "black@0.5", t: "fill" } },
        { kind: "drawbox",  options: { ...$ICON_BOX, color: "black@0.5", t: $"($BOX_BORDER)" } },

        { kind: "drawbox",  options: { ...$characteristics_box, color: "black@0.5", t: "fill" } },
        { kind: "drawbox",  options: { ...$characteristics_box, color: "black@0.5", t: $"($BOX_BORDER)" } },
        (ffmpeg-text $troop.type $CHARACTERISTICS_TYPE_POS $CHARACTERISTICS_TYPE_FONT),

        { kind: "drawbox",  options: { ...$STAT_KEYS_BOX, color: $"($color)@1.0", t: "fill" } },
        { kind: "drawbox",  options: { ...$STAT_KEYS_BOX, color: "black@0.4",     t: $"($BOX_BORDER)" } },

        { kind: "drawbox",  options: { ...$STAT_VALS_BOX, color: "black@0.5",     t: "fill" } },
        { kind: "drawbox",  options: { ...$STAT_VALS_BOX, color: "black@0.5",     t: $"($BOX_BORDER)" } },
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
                        if $skill != null and $skill.k == "" {
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
                    (ffmpeg-text $"($stat)"      { x: $"($STAT_VALS_BOX.x)+($STAT_OFFSET_X)+($it.index)*($STAT_H_SPACE)-tw/2", y: $"($STAT_VALS_BOX.y)+($STAT_VALS_BOX.h / 2)-th/2" } $STAT_FONT),
                ]
            } | flatten
        ),

        ...(
            if ($troop.special_skills | is-empty) {
                []
            } else {
                let box = [
                    { kind: "drawbox",  options: { ...$special_skills_box, color: "black@0.5", t: "fill" } },
                    { kind: "drawbox",  options: { ...$special_skills_box, color: "black@0.5", t: $"($BOX_BORDER)" } },
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
        { kind: "drawbox",  options: { ...$weaponry.box, color: "black@0.5", t: $"($BOX_BORDER)" } },
        (ffmpeg-text "WEAPONRY" $weaponry.title_pos $EQUIPMENT_TITLE_FONT),
        ...(equipments-to-text $weaponry),

        { kind: "drawbox",  options: { ...$equipment.box, color: "black@0.5", t: "fill" } },
        { kind: "drawbox",  options: { ...$equipment.box, color: "black@0.5", t: $"($BOX_BORDER)" } },
        (ffmpeg-text "EQUIPMENT" $equipment.title_pos $EQUIPMENT_TITLE_FONT),
        ...(equipments-to-text $equipment),

        { kind: "drawbox",  options: { ...$peripheral.box, color: "black@0.5", t: "fill" } },
        { kind: "drawbox",  options: { ...$peripheral.box, color: "black@0.5", t: $"($BOX_BORDER)" } },
        (ffmpeg-text "PERIPHERAL" $peripheral.title_pos $EQUIPMENT_TITLE_FONT),
        ...(equipments-to-text $peripheral),

        { kind: "drawbox",  options: { ...$MELEE_BOX, color: "black@0.5", t: "fill" } },
        { kind: "drawbox",  options: { ...$MELEE_BOX, color: "black@0.5", t: $"($BOX_BORDER)" } },
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
        { kind: "drawbox",  options: { ...$SWC_BOX, color: "black@0.5", t: $"($BOX_BORDER)" } },
        (ffmpeg-text "SWC"           $SWC_TITLE_POS  $SWC_TITLE_FONT),
        (ffmpeg-text $"($troop.SWC)" $SWC_POS        $SWC_FONT),

        { kind: "drawbox",  options: { ...$C_BOX, color: "black@0.5", t: "fill" } },
        { kind: "drawbox",  options: { ...$C_BOX, color: "black@0.5", t: $"($BOX_BORDER)" } },
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
                    # FIXME: the first vertical offset is a bit magical
                    y: $"($characteristics_box.y + 2 * $CHARACTERISTICS_V_SPACE + $CHARACTERISTICS_IMAGE_SIZE)+($it.index * ($CHARACTERISTICS_IMAGE_SIZE + $CHARACTERISTICS_V_SPACE))-h/2",
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
                    x: $"($STAT_VALS_BOX.x)+($ALLOWED_FACTIONS_OFFSET.x)+($it.index * ($ALLOWED_FACTIONS_IMAGE_SIZE + $ALLOWED_FACTIONS_IMAGE_H_SPACE))-w/2",
                    y: $"($STAT_VALS_BOX.y)+($STAT_VALS_BOX.h)+($ALLOWED_FACTIONS_OFFSET.y)-h/2",
                },
            } | ffmpeg options) --output (mktemp --tmpdir infinity-XXXXXXX.png)
        }

    let tmp = $tmp | put-version $troop

    let out = $output | path parse | update stem { $in ++ ".1" } | path join
    cp $tmp $out
    log info $"\t(ansi purple)($out)(ansi reset)"
}
