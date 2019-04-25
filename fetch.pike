int main(int argc, array(string) argv)
{
	if (argc < 2) exit(1, "USAGE: pike %s channelname\n", argv[0]);
	array files = get_dir(argv[1]);
	if (!files) exit(1, "Unable to find files in dir %s\n", argv[1]);
	array json = glob("*.json", files)[*] - ".json";
	if (!sizeof(json)) exit(1, "Cannot find %s/*.json\n", argv[1]);
	array mp4 = glob("*.mp4", files)[*] - ".mp4";
	json -= mp4;
	write("%d clips to download.\n", sizeof(json));
	if (has_value(argv, "--simulate"))
	{
		foreach (json, string slug)
			write("%s: %s\n", slug, string_to_utf8(Standards.JSON.decode_utf8(Stdio.read_file(sprintf("%s/%s.json", argv[1], slug)))->title));
		return 0;
	}
	while (sizeof(json))
	{
		string slug = random(json);
		string fn = sprintf("%s/%s.mp4", argv[1], slug);
		Process.create_process(({"youtube-dl", "https://clips.twitch.tv/" + slug, "-o", fn}))->wait();
		if (!file_stat(fn)) exit(1, "File doesn't exist after download: %s\n", fn);
		json -= ({slug});
	}
}
