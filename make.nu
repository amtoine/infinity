def "main git" [] {
    git config diff.exif.textconv exiftool
}

def "main" [] {
    use build_card.nu

    build_card (open troops/panoceania/orc.nuon) --color "0x66b6d7" --output assets/panoceania-orc.png

    build_card (open troops/jsa/shikami.nuon)    --color "0xe79799" --output assets/jsa-shikami.png

    build_card (open troops/nomads/tunguska-cheerkiller.1.nuon) --color "0xdb6c72" --output assets/nomads-tunguska-cheerkiller.1.png
    build_card (open troops/nomads/tunguska-cheerkiller.2.nuon) --color "0xdb6c72" --output assets/nomads-tunguska-cheerkiller.2.png
    build_card (open troops/nomads/tunguska-cheerkiller.3.nuon) --color "0xdb6c72" --output assets/nomads-tunguska-cheerkiller.3.png
    build_card (open troops/nomads/tunguska-grenzer.nuon) --color "0xdb6c72" --output assets/nomads-tunguska-grenzer.png

    build_card (open troops/aleph/danavas.nuon) --color "0xafa7bc" --output assets/aleph-danavas.png
    build_card (open troops/aleph/maruts-karkata.nuon) --color "0xafa7bc" --output assets/aleph-maruts-karkata.png

    build_card (open troops/mercenaries/diggers.nuon) --color "0x88a5b7" --output assets/mercenary-diggers.png

    build_card (open troops/o-12/starmada-bronze.nuon) --color "0xdece67" --output assets/o-12-starmada-bronze.png
    build_card (open troops/o-12/starmada-bronze.nuon) --color "0xdece67" --output assets/o-12-starmada-bronze.png
    build_card (open troops/o-12/starmada-nyoka.1.nuon) --color "0xdece67" --output assets/o-12-starmada-nyoka.1.png
    build_card (open troops/o-12/starmada-nyoka.2.nuon) --color "0xdece67" --output assets/o-12-starmada-nyoka.2.png
    build_card (open troops/o-12/starmada-nyoka.3.nuon) --color "0xdece67" --output assets/o-12-starmada-nyoka.3.png
}
