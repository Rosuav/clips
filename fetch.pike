#if constant(G)
//This part needs to be invoked with some StilleBot functionality available. TODO: Make
//that possible somehow. It might involve importing ../stillebot/poll.pike, but that
//will also require some globals and such.
void clips_display(string channel)
{
	string dir = "../clips/" + channel;
	array files = get_dir(dir);
	multiset unseen;
	if (files) unseen = (multiset)glob("*.json", files);
	get_user_id(channel)->then(lambda (int userid) {
		return get_helix_paginated("https://api.twitch.tv/helix/clips",
			(["broadcaster_id": (string)userid, "first": "100"]));
	})->then(lambda (array clips) {
		foreach (clips, mapping clip)
		{
			if (unseen)
			{
				unseen[clip->id + ".json"] = 0;
				Stdio.write_file(dir + "/" + clip->id + ".json", Standards.JSON.encode(clip, 7));
			}
			write(string_to_utf8(sprintf("[%s] %s %s - %s\n", clip->created_at, clip->id, clip->creator_name, clip->title)));
		}
		if (unseen && sizeof(unseen))
			write("%d deleted clips:\n%{\t%s\n%}", sizeof(unseen), sort((array)unseen));
	}, lambda (mapping err) {
		write("Error fetching clips: %O\n", err);
	});
}
#endif

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
