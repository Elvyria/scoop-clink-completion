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

local scoop_parser = parser(
	{
		{'install', 'info', 'depends', 'virustotal'} ..parser({Apps.get_known}):loop(0),
		{'uninstall', 'cleanup', 'update', 'prefix', 'reset'} ..parser({Apps.get_local}):loop(0),
		'alias' ..parser({'add', 'list', 'rm'}),
		'bucket' ..parser({'add' ..parser({Buckets.get_known}), 'list', 'known', 'rm' ..parser({Buckets.get_local})}),
		'cache',
		'checkup',
		'config',
		'create',
		'export',
		'help',
		'home',
		'list',
		'search',
		'status',
		'which'
	}
)

local help_parser = parser(
	{
        'help' .. parser(scoop_parser:flatten_argument(1))
	}
)

clink.arg.register_parser('scoop', scoop_parser)
clink.arg.register_parser('scoop', help_parser)
