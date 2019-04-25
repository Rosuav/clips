import json
import subprocess
import sys

dir = ""
if len(sys.argv) > 1: dir = sys.argv[1] + "/"

while True:
	try: fn = input("Enter .json file name: ").strip()
	except EOFError: break
	if not fn: break
	with open(dir + fn) as f: meta = json.load(f)
	print()
	print("Clip taken by", meta["curator"]["display_name"], "at", meta["created_at"])
	print(meta["title"])
	subprocess.check_call(["google-chrome", dir + fn.replace(".json", "") + ".mp4"])
