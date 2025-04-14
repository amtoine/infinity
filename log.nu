export def "log info" [msg: string] {
    print $"[(ansi cyan)INFO(ansi reset)] ($msg)"
}

export def "log debug" [msg: string] {
    print $"[(ansi default_dimmed)DEBUG(ansi reset)] ($msg)"
}
