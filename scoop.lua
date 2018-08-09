local scoop_dir = clink.get_env('HOME')..'/scoop'

local function trim_extensions (apps)
	for k, v in pairs(apps) do
		apps[k] = string.match(v, '[%w-]*')
	end
	return apps
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

local buckets_local = clink.find_dirs(scoop_dir..'/buckets/*')
table.remove(buckets_local, 1)
table.remove(buckets_local, 1)

local buckets_remote = exec_result_table('scoop bucket known')

local apps = trim_extensions(clink.find_files(scoop_dir..'/apps/scoop/current/bucket/*.json'))
for k, dir in pairs(buckets_local) do
	for u, app in pairs(trim_extensions(clink.find_files(scoop_dir..'/buckets/'..dir..'/*.json'))) do
		table.insert(apps, app)
	end
end

local parser = clink.arg.new_parser

local scoop_parser = parser(
	{
		{'install', 'info', 'uninstall', 'cleanup', 'update', 'prefix', 'reset', 'depends', 'virustotal'}..parser(apps),
		'alias' 	..parser({'add', 'list', 'rm'}),
		'bucket'	..parser({'add'..parser(buckets_remote), 'list', 'known', 'rm'..parser(buckets_local)}),
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
