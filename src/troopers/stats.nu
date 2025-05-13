use ../common.nu [
    BOLD_FONT, REGULAR_FONT, BASE_COLOR, DIRS, TEXT_ALIGNMENT,
    put-version, ffmpeg-text,
]

use std iter

def get-options [options: record] {
    ################################################################################
    ###### icon and characteristics boxes ##########################################
    ################################################################################
    let icon_box = {
        x: $options.margins.left,
        y: $options.margins.top,
        w: (155 * $options.scale.x - $options.margins.left),
        h: (155 * $options.scale.y - $options.margins.top),
    }

    let characteristics_box = {
        x: $options.margins.left,
        y: ($icon_box.y + $icon_box.h + 20 * $options.scale.x),
        w: (120 * $options.scale.x - $options.margins.left),
        h: null,
    }
    # space between the trooper type and the first characteristics asset
    let characteristics_v_space = 5 * $options.scale.y
    # size of a characteristics asset
    let characteristics_image_size = 70 * $options.scale.x
    let characteristics_type_pos = {
        x: ($characteristics_box.x + $characteristics_box.w // 2),
        y: ($characteristics_box.y + 25 * $options.scale.y),
        alignment: $TEXT_ALIGNMENT.center,
    }
    let characteristics_type_font = { fontfile: $BOLD_FONT, fontcolor: "white", fontsize: (30 * $options.scale.x) }
    ################################################################################

    ################################################################################
    ###### top #####################################################################
    ################################################################################
    let name_box = {
        x: (480 * $options.scale.x),
        y: ($options.margins.top + 45 * $options.scale.y),
        w: ($options.margins.right - 480 * $options.scale.x),
        h: (160 * $options.scale.y - ($options.margins.top + 45 * $options.scale.y)),
    }
    let name_offset_x = 28 * $options.scale.x
    let name_pos = {
        x: ($name_box.x + $name_offset_x)
        y: ($name_box.y + $name_box.h / 2),
        alignment: $TEXT_ALIGNMENT.left,
    }
    let name_font = { fontfile: $BOLD_FONT, fontcolor: "white", fontsize: (45 * $options.scale.x) }

    let isc_font = { fontfile: $REGULAR_FONT, fontcolor: "black", fontsize: (30 * $options.scale.x) }
    let isc_pos = {
        x: ($name_box.x + $name_offset_x),
        y: ($name_box.y - $isc_font.fontsize),
        alignment: $TEXT_ALIGNMENT.top_left,
    }
    let classification_pos = {
        x: ($name_box.x + $name_box.w - $name_offset_x),
        y: $isc_pos.y,
        alignment: $TEXT_ALIGNMENT.top_right,
    }

    let stat_keys_box = {
        x: $name_box.x,
        y: ($name_box.y + $name_box.h + 20 * $options.scale.y),
        w: ($options.margins.right - $name_box.x),
        h: (245 * $options.scale.y - ($name_box.y + $name_box.h + 20 * $options.scale.y)),
    }
    let stat_vals_box = {
        x: $stat_keys_box.x,
        y: ($stat_keys_box.y + $stat_keys_box.h + 20 * $options.scale.y),
        w: $stat_keys_box.w,
        h: $stat_keys_box.h,
    }
    # horizontal space between stats
    let stat_h_space = 108 * $options.scale.x
    # horizontal offset for the first stat (mov)
    let stat_offset_x = 60 * $options.scale.x
    let stat_font = { fontfile: $REGULAR_FONT, fontcolor: "white", fontsize: (30 * $options.scale.x) }

    # offset to the bottom-left corner of the "stat values" box
    let allowed_factions_offset = {
        x: (50 * $options.scale.x),
        y: (50 * $options.scale.y),
    }
    let allowed_factions_image_size = 70 * $options.scale.x
    let allowed_factions_image_h_space = 10 * $options.scale.x

    let special_skills_box = {
        x: ($options.margins.right - 425 * $options.scale.x),
        y: ($stat_vals_box.y + $stat_vals_box.h + 20 * $options.scale.y),
        w: (425 * $options.scale.x),
        h: null,
    }
    # offset for the first special skill
    let special_skills_offset = {
        x: (10 * $options.scale.x),
        y: (80 * $options.scale.y),
    }
    # the base height for the "special skill" box
    let special_skills_v_base = 100 * $options.scale.y
    # the vertical space between two special skills
    let special_skills_v_space = 30 * $options.scale.y
    let special_skills_title_pos = {
        x: ($special_skills_box.x + $special_skills_offset.x),
        y: ($special_skills_box.y + 30 * $options.scale.y),
        alignment: $TEXT_ALIGNMENT.left,
    }
    let special_skills_title_font = { fontfile: $BOLD_FONT,    fontcolor: "white", fontsize: (32 * $options.scale.x) }
    let special_skills_font       = { fontfile: $REGULAR_FONT, fontcolor: "white", fontsize: (18 * $options.scale.x) }
    ###### end top #################################################################

    ################################################################################
    ###### bottom ##################################################################
    ################################################################################
    let equipment_boxes_v_space = 20 * $options.scale.y
    let empty_equipment_box_height = 60 * $options.scale.y
    let full_equipment_box_height = 105 * $options.scale.y

    # the most bottom "equipment" box, i.e. the "peripheral" one, used as a base for
    # the other "equipment" boxes
    let equipment_box = {
        x: $options.margins.left,
        y: ($options.margins.bottom - $full_equipment_box_height),
        w: (790 * $options.scale.x - $options.margins.left),
        h: null,
    }
    # the horizontal offset of text in "equipment" boxes
    let equipment_offset_x = 10 * $options.scale.x
    let equipment_title_pos = {
        x: ($equipment_box.x + $equipment_offset_x),
        y: ($equipment_box.y +  4 / 15 * $full_equipment_box_height),
        alignment: $TEXT_ALIGNMENT.left,
    }
    let equipment_pos = {
        x: ($equipment_box.x + $equipment_offset_x),
        y: ($equipment_box.y + 11 / 15 * $full_equipment_box_height),
        alignment: $TEXT_ALIGNMENT.left,
    }
    let equipment_font_size = 22 * $options.scale.x
    let equipment_title_font = { fontfile: $BOLD_FONT, fontcolor: "white", fontsize: ($equipment_font_size + 6 * $options.scale.x) }
    let equipment_font = { fontfile: $REGULAR_FONT, fontcolor: "white", fontsize: $equipment_font_size }

    # used to build lists of things dynamically
    let list_separator = ", "
    let list_separator_v_offset = 10 * $options.scale.y
    # the horizontal space a character takes in the "equipment" lists
    let equipment_char_size = $equipment_font.fontsize * 0.6

    # the vertical row positions in the bottom base "equipment" box, i.e. the "peripheral" box
    let bottom_first_row_y = 885 * $options.scale.y
    let bottom_second_row_y = 930 * $options.scale.y

    let melee_box = {
        x: ($equipment_box.x + $equipment_box.w + 20 * $options.scale.x),
        y: ($options.margins.bottom - $full_equipment_box_height),
        w: (1335 * $options.scale.x - ($equipment_box.x + $equipment_box.w + 20 * $options.scale.x)),
        h: $full_equipment_box_height,
    }
    # the horizontal offset of text in "melee" box
    let melee_offset_x = 10 * $options.scale.x
    let melee_weapons_title_pos = {
        x: ($melee_box.x + $melee_offset_x),
        y: ($melee_box.y +  4 / 15 * $full_equipment_box_height),
        alignment: $TEXT_ALIGNMENT.left,
    }
    let melee_weapons_pos = {
        x: ($melee_box.x + $melee_offset_x),
        y: ($melee_box.y + 11 / 15 * $full_equipment_box_height),
        alignment: $TEXT_ALIGNMENT.left,
    }
    let melee_font_size = 22 * $options.scale.x
    let melee_weapons_title_font  = { fontfile: $BOLD_FONT, fontcolor: "white", fontsize: ($melee_font_size + 6 * $options.scale.x) }
    let melee_weapons_font = { fontfile: $REGULAR_FONT, fontcolor: "white", fontsize: $melee_font_size }

    let swc_box = {
        x: ($melee_box.x + $melee_box.w + 20 * $options.scale.x),
        y: ($options.margins.bottom - $full_equipment_box_height),
        w: (1445 * $options.scale.x - ($melee_box.x + $melee_box.w + 20 * $options.scale.x)),
        h: $full_equipment_box_height,
    }
    let swc_title_pos = {
        x: ($swc_box.x + $swc_box.w // 2),
        y: ($swc_box.y +  4 / 15 * $full_equipment_box_height),
        alignment: $TEXT_ALIGNMENT.center,
    }
    let swc_pos = {
        x: ($swc_box.x + $swc_box.w // 2),
        y: ($swc_box.y + 11 / 15 * $full_equipment_box_height),
        alignment: $TEXT_ALIGNMENT.center,
    }
    let swc_font_size = 30 * $options.scale.x
    let swc_title_font = { fontfile: $BOLD_FONT, fontcolor: "white", fontsize: $swc_font_size }
    let swc_font = { fontfile: $REGULAR_FONT, fontcolor: "white", fontsize: $swc_font_size }

    let c_box = {
        x: ($swc_box.x + $swc_box.w + 15 * $options.scale.x),
        y: ($options.margins.bottom - $full_equipment_box_height),
        w: ($options.margins.right - ($swc_box.x + $swc_box.w + 15 * $options.scale.x)),
        h: $full_equipment_box_height,
    }
    let c_title_pos = {
        x: ($c_box.x + $c_box.w // 2),
        y: ($c_box.y +  4 / 15 * $full_equipment_box_height),
        alignment: $TEXT_ALIGNMENT.center,
    }
    let c_pos = {
        x: ($c_box.x + $c_box.w // 2),
        y: ($c_box.y + 11 / 15 * $full_equipment_box_height),
        alignment: $TEXT_ALIGNMENT.center,
}
    let c_font_size = 30 * $options.scale.x
    let c_title_font = { fontfile: $BOLD_FONT, fontcolor: "white", fontsize: $c_font_size }
    let c_font = { fontfile: $REGULAR_FONT, fontcolor: "white", fontsize: $c_font_size }

    let qr_code_size = 4              # passed to --size
    let qr_code_margin = 1            # passed to --margin
    let qr_code_width = 105 * $options.scale.x  # the final width of the qr code

    let name_2_box = {
        x: ($equipment_box.x + $equipment_box.w + 20 * $options.scale.x),
        y: ($melee_box.y - 15 * $options.scale.y - 55 * $options.scale.y),
        w: ($options.margins.right - ($qr_code_width + 10 * $options.scale.x) - ($equipment_box.x + $equipment_box.w + 20 * $options.scale.x)),
        h: (55 * $options.scale.y),
    }
    # the horizontal offset of text in "name 2" box
    let name_2_offset_x = 10 * $options.scale.x
    let name_2_pos = {
        x: ($name_2_box.x + $name_2_offset_x),
        y: ($name_2_box.y + $name_2_box.h / 2),
        alignment: $TEXT_ALIGNMENT.left,
    }
    let name_2_font = { fontfile: $REGULAR_FONT, fontcolor: "white", fontsize: (30 * $options.scale.x) }

    let qr_code_overlay = { kind: "overlay",  options: {
        x: $"($options.margins.right)-w",
        y: $"($name_2_box.y + $name_2_box.h)-h",
    } }
    ###### end bottom ##############################################################

    {
        base_image: {
            kind: "color",
            options: {
                c: $BASE_COLOR,
                s: $"($options.canvas.w)x($options.canvas.h)",
                d: 1,
            },
        },
        faction_pos: {
            x: ($options.margins.right - 105 * $options.scale.x),
            y: ($options.canvas.h / 2),
        },
        mini_overlay: {
            kind: "overlay",
            options: {
                x: $"(320 * $options.scale.x)-w/2",
                y: $"($options.canvas.h - 50 * $options.scale.y)-h",
            },
        },
        box_border: (5 * $options.scale.x),
        icon_box: $icon_box,
        characteristics_box: $characteristics_box,
        characteristics_v_space: $characteristics_v_space,
        characteristics_image_size: $characteristics_image_size,
        characteristics_type_pos: $characteristics_type_pos,
        characteristics_type_font: $characteristics_type_font,
        name_box: $name_box,
        name_offset_x: $name_offset_x,
        name_pos: $name_pos,
        name_font: $name_font,
        isc_font: $isc_font,
        isc_pos: $isc_pos,
        classification_pos: $classification_pos,
        stat_keys_box: $stat_keys_box,
        stat_vals_box: $stat_vals_box,
        stat_h_space: $stat_h_space,
        stat_offset_x: $stat_offset_x,
        stat_font: $stat_font,
        allowed_factions_offset: $allowed_factions_offset,
        allowed_factions_image_size: $allowed_factions_image_size,
        allowed_factions_image_h_space: $allowed_factions_image_h_space,
        special_skills_box: $special_skills_box,
        special_skills_offset: $special_skills_offset,
        special_skills_v_base: $special_skills_v_base,
        special_skills_v_space: $special_skills_v_space,
        special_skills_title_pos: $special_skills_title_pos,
        special_skills_title_font: $special_skills_title_font,
        special_skills_font      : $special_skills_font      ,
        equipment_boxes_v_space: $equipment_boxes_v_space,
        empty_equipment_box_height: $empty_equipment_box_height,
        full_equipment_box_height: $full_equipment_box_height,
        equipment_box: $equipment_box,
        equipment_offset_x: $equipment_offset_x,
        equipment_title_pos: $equipment_title_pos,
        equipment_pos: $equipment_pos,
        equipment_font_size: $equipment_font_size,
        equipment_title_font: $equipment_title_font,
        equipment_font: $equipment_font,
        list_separator: $list_separator,
        list_separator_v_offset: $list_separator_v_offset,
        equipment_char_size: $equipment_char_size,
        bottom_first_row_y: $bottom_first_row_y,
        bottom_second_row_y: $bottom_second_row_y,
        melee_box: $melee_box,
        melee_offset_x: $melee_offset_x,
        melee_weapons_title_pos: $melee_weapons_title_pos,
        melee_weapons_pos: $melee_weapons_pos,
        melee_font_size: $melee_font_size,
        melee_weapons_title_font : $melee_weapons_title_font ,
        melee_weapons_font: $melee_weapons_font,
        swc_box: $swc_box,
        swc_title_pos: $swc_title_pos,
        swc_pos: $swc_pos,
        swc_font_size: $swc_font_size,
        swc_title_font: $swc_title_font,
        swc_font: $swc_font,
        c_box: $c_box,
        c_title_pos: $c_title_pos,
        c_pos: $c_pos,
        c_font_size: $c_font_size,
        c_title_font: $c_title_font,
        c_font: $c_font,
        qr_code_size: $qr_code_size,
        qr_code_margin: $qr_code_margin,
        qr_code_width: $qr_code_width,
        name_2_box: $name_2_box,
        name_2_offset_x: $name_2_offset_x,
        name_2_pos: $name_2_pos,
        name_2_font: $name_2_font,
        qr_code_overlay: $qr_code_overlay,
    }
}

# marks "spec" equipments or skill in bold
def equipment-or-skill-to-text [
    equipment_or_skill,  # string | record<name: string, mod?: string, spec?: bool>
    base_font: record<fontfile: path, fontcolor: string, fontsize: number>,
    pos: record<x: number, y: number, alignment: record<x: string, y: string>>,
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
    options: record,
]: [ nothing -> list<record> ] {
    if $x.equipments == [] {
        return []
    }

    $x.equipments
        | iter intersperse $options.list_separator
        | reduce --fold { transforms: [], pos: $x.text_pos } { |it, acc|
            let pos = if $it == $options.list_separator {
                $acc.pos | update y { $"($in)+($options.list_separator_v_offset)" }
            } else {
                $acc.pos
            }
            let res = equipment-or-skill-to-text $it $options.equipment_font $pos
            let next_pos = $acc.pos
                | update x { $"($in) + (($res.text | str length) * $options.equipment_char_size)" }

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
    options: record,
] {
    # NOTE: this is required because of signature issues in Nushell
    let modifiers = $modifiers | transpose --header-row | into record

    let options = $options | merge (get-options $options)

    # NOTE: because we assume the box will be full at the start
    let equipment_box_delta_height = $options.full_equipment_box_height - $options.empty_equipment_box_height

    # first "equipment" box from bottom
    let peripheral = $troop.peripheral | if $in == [] {{
        equipments: $in,
        box: ($options.equipment_box | update h $options.empty_equipment_box_height | update y { $in + $equipment_box_delta_height }),
        title_pos: ($options.equipment_title_pos | update y { $in + $equipment_box_delta_height }),
        text_pos: ($options.equipment_pos | update y { $in + $equipment_box_delta_height }),
    }} else {{
        equipments: $in,
        box: ($options.equipment_box | update h $options.full_equipment_box_height),
        title_pos: $options.equipment_title_pos,
        text_pos: $options.equipment_pos,
    }}

    # second "equipment" box from bottom
    let equipment = $troop.equipment | if $in == [] {{
        equipments: $in,
        box: ($peripheral.box | update y { $in - ($options.equipment_boxes_v_space + $options.empty_equipment_box_height) } | update h $options.empty_equipment_box_height),
        title_pos: ($peripheral.title_pos | update y { $in - $options.equipment_boxes_v_space - $options.empty_equipment_box_height }),
        text_pos: ($peripheral.text_pos | update y { $in - $options.equipment_boxes_v_space - $options.empty_equipment_box_height }),
    }} else {{
        equipments: $in,
        box: ($peripheral.box | update y { $in - ($options.equipment_boxes_v_space + $options.full_equipment_box_height) } | update h $options.full_equipment_box_height),
        title_pos: ($peripheral.title_pos | update y { $in - $options.equipment_boxes_v_space - $options.full_equipment_box_height }),
        text_pos: ($peripheral.text_pos | update y { $in - $options.equipment_boxes_v_space - $options.full_equipment_box_height }),
    }}

    # third and last "equipment" box from bottom
    let weaponry = $troop.weaponry | if $in == [] {{
        equipments: $in,
        box: ($equipment.box | update y { $in - ($options.equipment_boxes_v_space + $options.empty_equipment_box_height) } | update h $options.empty_equipment_box_height),
        title_pos: ($equipment.title_pos | update y { $in - $options.equipment_boxes_v_space - $options.empty_equipment_box_height }),
        text_pos: ($equipment.text_pos | update y { $in - $options.equipment_boxes_v_space - $options.empty_equipment_box_height }),
    }} else {{
        equipments: $in,
        box: ($equipment.box | update y { $in - ($options.equipment_boxes_v_space + $options.full_equipment_box_height) } | update h $options.full_equipment_box_height),
        title_pos: ($equipment.title_pos | update y { $in - $options.equipment_boxes_v_space - $options.full_equipment_box_height }),
        text_pos: ($equipment.text_pos | update y { $in - $options.equipment_boxes_v_space - $options.full_equipment_box_height }),
    }}

    let characteristics_box = $options.characteristics_box | update h (
        $options.characteristics_box.w // 2 +  # because text is twice larger
        (if ($troop.characteristics | is-empty) { 0 } else { 2 * $options.characteristics_v_space }) +
        ($options.characteristics_image_size + $options.characteristics_v_space) * ($troop.characteristics | length)
    )
    let special_skills_box = $options.special_skills_box | update h (
        $options.special_skills_v_base + $options.special_skills_v_space * (($troop.special_skills | length) - 1)
    )

    let qrcode = mktemp --tmpdir infinity-XXXXXXX.png
    log info $"generating QR code in (ansi purple)($qrcode)(ansi reset)"
    qrencode --margin $options.qr_code_margin --size $options.qr_code_size -o $qrcode $troop.reference
    let qrcode = $qrcode
        | ffmpeg apply $"scale=($options.qr_code_width):($options.qr_code_width)" --output (mktemp --tmpdir infinity-XXXXXXX.png)

    let transforms = [
        (ffmpeg-text $"ISC: ($troop.isc)"  $options.isc_pos            $options.isc_font),
        (ffmpeg-text $troop.classification $options.classification_pos $options.isc_font),

        { kind: "drawbox",  options: { ...$options.name_box, color: $"($color)@1.0", t: "fill" } },
        { kind: "drawbox",  options: { ...$options.name_box, color: "black@0.4",     t: $"($options.box_border)" } },
        (ffmpeg-text $troop.name $options.name_pos $options.name_font),

        { kind: "drawbox",  options: { ...$options.name_2_box, color: $"($color)@1.0", t: "fill" } },
        { kind: "drawbox",  options: { ...$options.name_2_box, color: "black@0.4",     t: $"($options.box_border)" } },
        (ffmpeg-text $troop.short_name $options.name_2_pos $options.name_2_font),

        { kind: "drawbox",  options: { ...$options.icon_box, color: "black@0.5", t: "fill" } },
        { kind: "drawbox",  options: { ...$options.icon_box, color: "black@0.5", t: $"($options.box_border)" } },

        { kind: "drawbox",  options: { ...$characteristics_box, color: "black@0.5", t: "fill" } },
        { kind: "drawbox",  options: { ...$characteristics_box, color: "black@0.5", t: $"($options.box_border)" } },
        (ffmpeg-text $troop.type $options.characteristics_type_pos $options.characteristics_type_font),

        { kind: "drawbox",  options: { ...$options.stat_keys_box, color: $"($color)@1.0", t: "fill" } },
        { kind: "drawbox",  options: { ...$options.stat_keys_box, color: "black@0.4",     t: $"($options.box_border)" } },

        { kind: "drawbox",  options: { ...$options.stat_vals_box, color: "black@0.5",     t: "fill" } },
        { kind: "drawbox",  options: { ...$options.stat_vals_box, color: "black@0.5",     t: $"($options.box_border)" } },
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
                    (ffmpeg-text $"($it.item.k)" {
                        x: ($options.stat_keys_box.x + $options.stat_offset_x + $it.index * $options.stat_h_space),
                        y: ($options.stat_keys_box.y + $options.stat_keys_box.h / 2),
                        alignment: $TEXT_ALIGNMENT.center,
                    } $options.stat_font),
                    (ffmpeg-text $"($stat)" {
                        x: ($options.stat_vals_box.x + $options.stat_offset_x + $it.index * $options.stat_h_space),
                        y: ($options.stat_vals_box.y + $options.stat_vals_box.h / 2),
                        alignment: $TEXT_ALIGNMENT.center,
                    } $options.stat_font),
                ]
            } | flatten
        ),

        ...(
            if ($troop.special_skills | is-empty) {
                []
            } else {
                let box = [
                    { kind: "drawbox",  options: { ...$special_skills_box, color: "black@0.5", t: "fill" } },
                    { kind: "drawbox",  options: { ...$special_skills_box, color: "black@0.5", t: $"($options.box_border)" } },
                    (ffmpeg-text "Special skills" $options.special_skills_title_pos $options.special_skills_title_font),
                ]
                let skills = $troop.special_skills | enumerate | each { |it|
                    let pos = {
                        x: ($options.special_skills_box.x + $options.special_skills_offset.x),
                        y: ($options.special_skills_box.y + $options.special_skills_offset.y + $options.special_skills_v_space * $it.index),
                        alignment: $TEXT_ALIGNMENT.left,
                    }

                    [(equipment-or-skill-to-text $it.item $options.special_skills_font $pos).transform]
                }
                $box | append ($skills | flatten)
            }
        ),

        { kind: "drawbox",  options: { ...$weaponry.box, color: "black@0.5", t: "fill" } },
        { kind: "drawbox",  options: { ...$weaponry.box, color: "black@0.5", t: $"($options.box_border)" } },
        (ffmpeg-text "WEAPONRY" $weaponry.title_pos $options.equipment_title_font),
        ...(equipments-to-text $weaponry $options),

        { kind: "drawbox",  options: { ...$equipment.box, color: "black@0.5", t: "fill" } },
        { kind: "drawbox",  options: { ...$equipment.box, color: "black@0.5", t: $"($options.box_border)" } },
        (ffmpeg-text "EQUIPMENT" $equipment.title_pos $options.equipment_title_font),
        ...(equipments-to-text $equipment $options),

        { kind: "drawbox",  options: { ...$peripheral.box, color: "black@0.5", t: "fill" } },
        { kind: "drawbox",  options: { ...$peripheral.box, color: "black@0.5", t: $"($options.box_border)" } },
        (ffmpeg-text "PERIPHERAL" $peripheral.title_pos $options.equipment_title_font),
        ...(equipments-to-text $peripheral $options),

        { kind: "drawbox",  options: { ...$options.melee_box, color: "black@0.5", t: "fill" } },
        { kind: "drawbox",  options: { ...$options.melee_box, color: "black@0.5", t: $"($options.box_border)" } },
        (ffmpeg-text "MELEE WEAPONS" $options.melee_weapons_title_pos  $options.melee_weapons_title_font),
        (do {
            let text = $troop.melee_weapons | each { |it|
                match ($it | describe --detailed).type {
                    "string" => $it,
                    "record" => $"($it.name) \(($it.mod)\)",
                }
            } | str join ", "
            ffmpeg-text $text $options.melee_weapons_pos $options.melee_weapons_font
        }),

        { kind: "drawbox",  options: { ...$options.swc_box, color: "black@0.5", t: "fill" } },
        { kind: "drawbox",  options: { ...$options.swc_box, color: "black@0.5", t: $"($options.box_border)" } },
        (ffmpeg-text "SWC"           $options.swc_title_pos  $options.swc_title_font),
        (ffmpeg-text $"($troop.SWC)" $options.swc_pos        $options.swc_font),

        { kind: "drawbox",  options: { ...$options.c_box, color: "black@0.5", t: "fill" } },
        { kind: "drawbox",  options: { ...$options.c_box, color: "black@0.5", t: $"($options.box_border)" } },
        (ffmpeg-text "C"           $options.c_title_pos  $options.c_title_font),
        (ffmpeg-text $"($troop.C)" $options.c_pos        $options.c_font),
    ]

    let tmp = ffmpeg create ($options.base_image | ffmpeg options) --output (mktemp --tmpdir infinity-XXXXXXX.png)
        | [$in, ({ parent: $DIRS.minis, stem: $troop.asset, extension: "png" } | path join)]
            | ffmpeg combine ($options.mini_overlay | ffmpeg options) --output (mktemp --tmpdir infinity-XXXXXXX.png)
        | if $troop.faction != null {
            [$in, ({ parent: $DIRS.factions, stem: $troop.faction, extension: "png" } | path join)]
                | ffmpeg combine $"[1:v]format=rgba,colorchannelmixer=aa=0.5[ol];[0:v][ol]overlay=x=($options.faction_pos.x)-w/2:y=($options.faction_pos.y)-h/2" --output (mktemp --tmpdir infinity-XXXXXXX.png)
        } else {
            $in
        }
        | [$in, $qrcode] | ffmpeg combine ($options.qr_code_overlay | ffmpeg options) --output (mktemp --tmpdir infinity-XXXXXXX.png)
        | ffmpeg mapply ($transforms | compact | each { ffmpeg options })

    let tmp = $troop.characteristics
        | enumerate
        | reduce --fold $tmp { |it, acc|
            [$acc, ({ parent: $DIRS.characteristics, stem: $it.item, extension: "png" } | path join)] | ffmpeg combine ({
                kind: "overlay",
                options: {
                    x: $"($characteristics_box.x + $characteristics_box.w // 2)-w/2",
                    # FIXME: the first vertical offset is a bit magical
                    y: $"($characteristics_box.y + 2 * $options.characteristics_v_space + $options.characteristics_image_size)+($it.index * ($options.characteristics_image_size + $options.characteristics_v_space))-h/2",
                },
            } | ffmpeg options) --output (mktemp --tmpdir infinity-XXXXXXX.png)
        }
        | [$in, ({ parent: $DIRS.icons, stem: ($troop.asset | str replace --regex '\..*$' ''), extension: "png" } | path join) ] | ffmpeg combine ({
            kind: "overlay",
            options: { x: $"($options.icon_box.x + $options.icon_box.w // 2)-w/2", y: $"($options.icon_box.y + $options.icon_box.h // 2)-h/2" },
        } | ffmpeg options) --output (mktemp --tmpdir infinity-XXXXXXX.png)

    let tmp = $troop.allowed_factions
        | enumerate
        | reduce --fold $tmp { |it, acc|
            [$acc, ({ parent: $DIRS.allowed_factions, stem: $it.item, extension: "png" } | path join)] | ffmpeg combine ({
                kind: "overlay",
                options: {
                    x: $"($options.stat_vals_box.x)+($options.allowed_factions_offset.x)+($it.index * ($options.allowed_factions_image_size + $options.allowed_factions_image_h_space))-w/2",
                    y: $"($options.stat_vals_box.y)+($options.stat_vals_box.h)+($options.allowed_factions_offset.y)-h/2",
                },
            } | ffmpeg options) --output (mktemp --tmpdir infinity-XXXXXXX.png)
        }

    let tmp = $tmp | put-version $troop $options.version

    let out = $output | path parse | update stem { $in ++ ".1" } | path join
    cp $tmp $out
    log info $"\t(ansi purple)($out)(ansi reset)"
}
