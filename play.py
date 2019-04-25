import json
import os
import subprocess
import sys

dir = ""
if len(sys.argv) > 1: dir = sys.argv[1] + "/"

while True:
	try: fn = input("Enter .json file name: ")
	except EOFError: break
	if not fn: break
	if fn == "rm":
		# Delete the last-named file (will bomb if no last file)
		subprocess.check_call(["git", "rm", base + ".json"])
		os.unlink(base + ".mp4")
		continue
	base = dir + fn.strip().replace(".json", "")
	with open(base + ".json") as f: meta = json.load(f)
	print()
	print("Clip taken by", meta["curator"]["display_name"], "at", meta["created_at"])
	print(meta["title"])
	subprocess.check_call(["google-chrome", base + ".mp4"])
