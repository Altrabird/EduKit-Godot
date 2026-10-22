"""Serve a Godot web export locally and load it in headless Chromium.
Fails on page errors, a missing canvas, or the engine not starting.
Usage: python tools/web_smoke.py build/web/<game> <screenshot.png> [seconds] [click x,y ...]
Clicks (in 1280x720 page pixels) run in order after start, ~1.5 s apart."""
import functools, http.server, sys, threading, time
from playwright.sync_api import sync_playwright

folder, shot = sys.argv[1], sys.argv[2]
wait = float(sys.argv[3]) if len(sys.argv) > 3 else 12
clicks = [tuple(map(int, c.split(","))) for c in sys.argv[4:]]

handler = functools.partial(http.server.SimpleHTTPRequestHandler, directory=folder)
handler.log_message = lambda *a: None
srv = http.server.ThreadingHTTPServer(("127.0.0.1", 0), handler)
threading.Thread(target=srv.serve_forever, daemon=True).start()
url = f"http://127.0.0.1:{srv.server_address[1]}/index.html"

errors, logs = [], []
with sync_playwright() as p:
    b = p.chromium.launch(args=["--use-angle=swiftshader", "--enable-unsafe-swiftshader", "--autoplay-policy=no-user-gesture-required"])
    page = b.new_page(viewport={"width": 1280, "height": 720})
    page.on("pageerror", lambda e: errors.append(str(e)))
    page.on("console", lambda m: logs.append(f"{m.type}: {m.text}"))
    page.goto(url)
    page.wait_for_selector("canvas", timeout=20000)
    time.sleep(wait)
    for x, y in clicks:
        page.mouse.click(x, y)
        time.sleep(1.5)
    page.screenshot(path=shot)
    b.close()
srv.shutdown()

bad = [l for l in logs if l.startswith("error") or "SCRIPT ERROR" in l or "ERROR:" in l]
started = any("Godot Engine" in l for l in logs)
print(f"engine started: {started}, console lines: {len(logs)}, errors: {len(bad) + len(errors)}")
for l in (errors + bad)[:15]:
    print("  ", l[:300])
sys.exit(0 if started and not errors and not bad else 1)
