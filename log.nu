const LOG_LEVELS = {
    "CRITICAL": 0,
    "FATAL":    1,
    "ERROR":    2,
    "WARNING":  3,
    "INFO":     4,
    "DEBUG":    5,
    "TRACE":    6,
}

def "into log-level" []: [ string -> int, int -> int ] {
    let level = $in
    match ($level | describe --detailed).type {
        "int" => $level,
        "string" => ($LOG_LEVELS | get --ignore-errors $level | default $LOG_LEVELS.INFO),
    }
}

def __log [msg: string, min_level: int, color: string, label: string] {
    let level = try { $env.LOG_LEVEL? | into int }
        | default $env.LOG_LEVEL?
        | default $LOG_LEVELS.INFO
        | into log-level

    if $level >= $min_level {
        print $"[(ansi $color)($label)(ansi reset)] ($msg)"
    }
}

export def "log info" [msg: string] {
    __log $msg $LOG_LEVELS.INFO "cyan" "INFO"
}

export def "log debug" [msg: string] {
    __log $msg $LOG_LEVELS.DEBUG "default_dimmed" "DEBUG"
}
