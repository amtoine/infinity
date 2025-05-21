use ../ffmpeg.nu *
use ../log.nu [ "log info", "log warning", "log error", "log debug" ]

use ../common.nu [
    BOLD_FONT, REGULAR_FONT, put-version, ffmpeg-text,
    "parse modifier-from-skill", get-options
]
use charts.nu gen-charts-page
use stats.nu gen-stats-page

# skills that do not modify stats directly but rather change the way the game is
# played
const UNSUPPORTED_SKILLS = [
    "NCO", "Booty", "Dodge", "Dogged", "Frenzy", "Hacker", "Sensor", "Courage",
    "Stealth", "Commlink", "Discover", "Immunity", "Mimetism", "No Cover",
    "Number 2", "Warhorse", "Impetuous", "Minelayer", "Paramedic", "Lieutenant",
    "Peripheral", "Super-Jump", "Combat Jump", "Parachutist", "Infiltration",
    "Marksmanship", "Climbing Plus", "Transmutation", "Combat Instinct",
    "Religious Troop", "Chain of Command", "Forward Observer",
    "Forward Deployment", "Natural Born Warrior", "Specialist Operative",
]

# skills that modify the stats directly
const SUPPORTED_SKILLS = [ "BS Attack", "CC Attack", "Martial Arts", "Terrain" ]

export def build-trooper-card [
    trooper: record<
        isc: string,
        name: string,
        short_name: string,
        faction: any, # string or null
        allowed_factions: list<string>,
        classification: string,
        reference: string,
        type: string,
        characteristics: list<string>,
        stats: record,
        special_skills: list<any>, # table<name: string, mod: any>, # string or null
        profiles: list<any>, # record<
                             #     weaponry: table<name: string, mod: any>, # string or null
                             #     equipment: table<name: string, mod: any>, # string or null
                             #     peripheral: table<name: string, mod: any>, # string or null
                             #     melee_weapons: table<name: string, mod: any>, # string or null
                             #     SWC: number,
                             #     C: int
                             # >
    >,
    --canvas: record<w: int, h: int>,
    --margin: int,
    --debug,
    --color: string,
    --output: path = "output.png",
    --stats,
    --charts,
] {
    let modifiers = $trooper.special_skills | each { |skill|
        let skill = if ($skill | describe --detailed).type == "record" {
            $skill | default null mod | reject spec?
        } else {
            { name: $skill, mod: null }
        }

        if $skill.name in $SUPPORTED_SKILLS {
            $skill
        } else if $skill.name in $UNSUPPORTED_SKILLS {
            log debug $"skipping skill '($skill)'"
        } else {
            log warning $"skipping skill '($skill)'"
        }
    }
    | upsert mod { |it| $it | parse modifier-from-skill }
    | where $it.mod != null
    | reject pos?

    let options = get-options $canvas.w $canvas.h $margin $debug

    def merge-common-and-profile [common: cell-path, profile: cell-path] {
        upsert $common { |it|
            let common = $it | get $common
                | each { |it|
                    match ($it | describe --detailed).type {
                        "string" => { name: $it },
                        "record" => $it,
                    }
                }
                | upsert spec { default false }
            let profile = $it | get $profile | default []
                | each { |it|
                    match ($it | describe --detailed).type {
                        "string" => { name: $it },
                        "record" => $it,
                    }
                }
                | upsert spec { default true }
            $common | append $profile | default null mod
        }
        | reject $profile
    }

    let profiles = $trooper
        | default [] special_skills                                              # give defaults to common skills and equipments
        | default [] equipment
        | default [] weaponry
        | default [] melee_weapons
        | default [] peripheral
        | update profiles {                                                      # give defaults to profile skills and equipments
            default [] special_skills
                | default [] equipment
                | default [] weaponry
                | default [] melee_weapons
                | default [] peripheral
                | rename --column {
                    special_skills : profile_special_skills,
                    equipment      : profile_equipment,
                    weaponry       : profile_weaponry,
                    melee_weapons  : profile_melee_weapons,
                    peripheral     : profile_peripheral,
                }
        }
        | flatten --all profiles
        | merge-common-and-profile special_skills? profile_special_skills?
        | merge-common-and-profile equipment?      profile_equipment?
        | merge-common-and-profile weaponry?       profile_weaponry?
        | merge-common-and-profile melee_weapons?  profile_melee_weapons?
        | merge-common-and-profile peripheral?     profile_peripheral?
    let total = $profiles | length

    for p in ($profiles | enumerate) {
        let output = $output | path parse | update stem { $in ++ $".($p.index + 1)" } | path join
        {
            current: (
                $p.index + 1
                    | fill --alignment "right" --width ($total | into string | str length) --character ' '
            ),
            total: $total,
        } | log info $"    \(($in.current) / ($in.total)\)"

        match [$stats, $charts] {
            [true, true] | [false, false] => {
                gen-stats-page $p.item $color $output $modifiers $options
                gen-charts-page $p.item $color $output $modifiers $options
            },
            [true, false] => {
                gen-stats-page $p.item $color $output $modifiers $options
            },
            [false, true] => {
                gen-charts-page $p.item $color $output $modifiers $options
            },
        }
    }
}
