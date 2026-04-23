import os
import re
import subprocess

from kittens.tui.handler import result_handler
from kitty.key_encoding import KeyEvent, parse_shortcut

VIM_ID = "n?vim"

# kitty's subprocess PATH doesn't inherit our login shell's additions, so the
# bare `orbit` name isn't resolvable. Use the absolute path instead.
ORBIT = os.path.expanduser("~/.local/bin/orbit")

# kitty uses top/bottom/left/right; aerospace uses up/down/left/right.
AEROSPACE_DIRECTION = {
    "top": "up",
    "bottom": "down",
    "left": "left",
    "right": "right",
}


def is_window_vim(window):
    fp = window.child.foreground_processes
    return any(
        re.search(VIM_ID, p["cmdline"][0] if len(p["cmdline"]) else "", re.I)
        for p in fp
    )


def encode_key_mapping(window, key_mapping):
    mods, key = parse_shortcut(key_mapping)
    event = KeyEvent(
        mods=mods,
        key=key,
        shift=bool(mods & 1),
        alt=bool(mods & 2),
        ctrl=bool(mods & 4),
        super=bool(mods & 8),
        hyper=bool(mods & 16),
        meta=bool(mods & 32),
    ).as_window_system_event()

    return window.encoded_key(event)


def main():
    pass


@result_handler(no_ui=True)
def handle_result(args, result, target_window_id, boss):
    window = boss.window_id_map.get(target_window_id)
    direction = args[2]
    key_mapping = args[3]

    if window is None:
        return
    if is_window_vim(window):
        for keymap in key_mapping.split(">"):
            encoded = encode_key_mapping(window, keymap)
            window.write_to_child(encoded)
    else:
        before = boss.active_window.id if boss.active_window else None
        boss.active_tab.neighboring_window(direction)
        after = boss.active_window.id if boss.active_window else None
        if before is not None and before == after:
            # No kitty pane in this direction — escalate to aerospace focus.
            aero_dir = AEROSPACE_DIRECTION.get(direction)
            if aero_dir:
                subprocess.Popen(
                    [
                        ORBIT,
                        "focus",
                        "--boundaries-action",
                        "sibling-workspace",
                        aero_dir,
                    ]
                )
