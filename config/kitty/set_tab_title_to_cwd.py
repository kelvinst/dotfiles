from kittens.tui.handler import result_handler


def main(args):
    pass


@result_handler(no_ui=True)
def handle_result(args, result, target_window_id, boss):
    w = boss.active_tab.active_window
    if w:
        procs = w.child.foreground_processes
        if procs:
            cwd = procs[0].get('cwd', '')
            title = cwd.rstrip('/').split('/')[-1] if cwd else ''
            boss.active_tab.set_title(title)
