local scoop_dir = clink.get_env('HOME')..'/scoop'

local function trim_extensions (apps)
	for k, v in pairs(apps) do
		apps[k] = string.match(v, '[%w-]*')
	end
	return apps
end

local function find_dirs (path)
	result = clink.find_dirs(path)
	-- Remove .. and . from table of directories
	table.remove(result, 1)
	table.remove(result, 1)
	return result
end

local function exec_result_table (command)
	result = {}
	stream = assert (io.popen(command))
	for line in stream:lines() do
		table.insert(result, line)
	end
	stream:close()
	return result
end

local Buckets = {}

function Buckets.get_local ()
	return find_dirs(scoop_dir..'/buckets/*')
end

function Buckets.get_remote ()
	return exec_result_table('scoop bucket known')
end

local function apps ()
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
		{'install', 'info', 'uninstall', 'cleanup', 'update', 'prefix', 'reset', 'depends', 'virustotal'}	..parser({apps}),
		'alias' 	..parser({'add', 'list', 'rm'}),
		'bucket'	..parser({'add'..parser({Buckets.get_remote}), 'list', 'known', 'rm'..parser({Buckets.get_local})}),
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

clink.arg.register_parser('scoop', scoop_parser)
