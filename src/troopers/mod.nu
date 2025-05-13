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
    --canvas: record<w: int, h: int>,
    --margin: int,
    --debug,
    --color: string,
    --output: path = "output.png",
    --stats,
    --charts,
] {
    let modifiers = $troop.special_skills | each { |skill|
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

    match [$stats, $charts] {
        [true, true] | [false, false] => {
            gen-stats-page $troop $color $output $modifiers $options
            gen-charts-page $troop $color $output $modifiers $options
        },
        [true, false] => {
            gen-stats-page $troop $color $output $modifiers $options
        },
        [false, true] => {
            gen-charts-page $troop $color $output $modifiers $options
        },
    }
}
