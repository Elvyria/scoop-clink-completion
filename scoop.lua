local scoop_dir = os.getenv('HOME')..'/scoop'

local function trim_extensions (apps)
	for k, v in pairs(apps) do
		apps[k] = string.match(v, '[%w-]*')
	end
	return apps
end

local function find_dirs (path)
	dirs = clink.find_dirs(path)
	-- Remove .. and . from table of directories
	table.remove(dirs, 1)
	table.remove(dirs, 1)
	return dirs
end

local function get_cache ()
	cache = clink.find_files(scoop_dir..'/cache/*')
	-- Remove .. and . from table of directories
	table.remove(cache, 1)
	table.remove(cache, 1)
	for i, name in pairs(cache) do
		cache[i] = string.sub(name, 0, string.find(name, "#") - 1)
	end
	return cache
end

local Buckets = {}

function Buckets.get_local ()
	return find_dirs(scoop_dir..'/buckets/*')
end

function Buckets.get_known ()
	json = io.open(scoop_dir..'/apps/scoop/current/buckets.json')
	known = {}
	for line in json:lines() do
		bucket = string.match(line, '\"(.-)\"')
		if bucket then
			table.insert(known, bucket)
		end
	end
	return known
end

local Apps = {}

function Apps.get_local ()
	return find_dirs(scoop_dir..'/apps/*')
end

function Apps.get_known ()
	apps = trim_extensions(clink.find_files(scoop_dir..'/apps/scoop/current/bucket/*.json'))
	for _, dir in pairs(Buckets.get_local()) do
		for u, app in pairs(trim_extensions(clink.find_files(scoop_dir..'/buckets/'..dir..'/*.json'))) do
			table.insert(apps, app)
		end
	end
	return apps
end

local parser = clink.arg.new_parser

local boolean_parser = parser({'true', 'false'})

local apps_known_parser = parser({Apps.get_known})
local apps_local_parser = parser({Apps.get_local})

local bucket_known_parser = parser({Buckets.get_known})
local bucket_local_parser = parser({Buckets.get_local})

local config_parser = parser({
	'MSIEXTRACT_USE_LESSMSI' ..boolean_parser,
	'aria2-enabled' ..boolean_parser,
	'aria2-retry-wait',
	'aria2-split',
	'aria2-max-connection-per-server',
	'aria2-min-split-size',
	'aria2-options',
	'NO_JUNCTIONS' ..boolean_parser,
	'show_update_log' ..boolean_parser,
	'virustotal_api_key',
	'proxy'
})

local scoop_parser = parser({
	{'install', 'info', 'depends', 'virustotal', 'home'} ..apps_known_parser:loop(0),
	{'uninstall', 'cleanup', 'update', 'prefix', 'reset'} ..apps_local_parser:loop(0),
	'alias' ..parser({'add', 'list', 'rm'}),
	'bucket' ..parser({'add' ..bucket_known_parser, 'list', 'known', 'rm' ..bucket_local_parser}),
	'cache' ..parser({'show', 'rm'} ..parser({get_cache})),
	'checkup',
	'config' ..config_parser,
	'create',
	'export',
	'list',
	'search',
	'status',
	'which'
})

local help_parser = parser({
	'help' ..parser(scoop_parser:flatten_argument(1))
})

clink.arg.register_parser('scoop', scoop_parser)
clink.arg.register_parser('scoop', help_parser)
