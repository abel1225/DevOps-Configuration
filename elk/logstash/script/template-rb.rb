pkmap = {
"8796093085014":"0000"
}

def filter(event)
    event.set('id', event.get('pk'))
	target = event.get("storelist");
	targets = target.split(",")
	storelist = event.get('storelist')
	for e in targets
		uid = pkmap.fetch(e) || "#1"
		storelist = storelist.gsub(e, uid)))
	end
	event.set('storeuidlist', storelist);
	return [event]
end