local scoop_dir = os.getenv('SCOOP')

if not scoop_dir then
	scoop_dir = os.getenv('USERPROFILE')..'/scoop'
end

local scoop_global = os.getenv('SCOOP_GLOBAL')

if not scoop_global then
	scoop_global = os.getenv('ProgramData')..'/scoop'
end

local function trim_extensions (apps)
	for k, v in pairs(apps) do
		apps[k] = string.match(v, '(.+)%.')
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

local function find_files (path)
	files = clink.find_files(path)
	-- Remove .. and . from table of files
	table.remove(files, 1)
	table.remove(files, 1)
	return files
end

local function get_cache ()
	cache = find_files(scoop_dir..'/cache/*')
	for i, name in pairs(cache) do
		signPos = string.find(name, "#")
		cache[i] = signPos and string.sub(name, 0, signPos - 1) or nil
	end
	return cache
end

function get_installed_buckets ()
	return find_dirs(scoop_dir..'/buckets/*')
end

function get_known_buckets ()
	json = io.open(scoop_dir..'/apps/scoop/current/buckets.json')
	known = {}
	i = 0
	for line in json:lines() do
		known[i] = string.match(line, '\"(.-)\"')
		i = i + 1
	end
	return known
end

function get_installed_apps ()
	installed = find_dirs(scoop_dir..'/apps/*')
	i = #installed
	if scoop_global then
		for _, dir in pairs(find_dirs(scoop_global..'/apps/*')) do
			installed[i] = dir
			i = i + 1
		end
	end
	return installed
end

function get_known_apps ()
	apps = {}
	i = 0
	for _, dir in pairs(get_installed_buckets()) do
		for u, app in pairs(trim_extensions(clink.find_files(scoop_dir..'/buckets/'..dir..'/*.json'))) do
			apps[i] = app
			i = i + 1
		end
		for u, app in pairs(trim_extensions(clink.find_files(scoop_dir..'/buckets/'..dir..'/bucket/*.json'))) do
			apps[i] = app
			i = i + 1
		end
	end
	return apps
end

local parser = clink.arg.new_parser

local boolean_parser = parser({'true', 'false'})
local architecture_parser = parser({'32bit', '64bit'})

local config_parser = parser({
	'7ZIPEXTRACT_USE_EXTERNAL' ..boolean_parser,
	'MSIEXTRACT_USE_LESSMSI' ..boolean_parser,
	'aria2-enabled' ..boolean_parser,
	'aria2-retry-wait',
	'aria2-split',
	'aria2-max-connection-per-server',
	'aria2-min-split-size',
	'aria2-retry-wait',
	'aria2-options',
	'debug' ..boolean_parser,
	'rootPath',
	'globalPath',
	'default-architecture' ..architecture_parser,
	'cachePath',
	'shim' ..parser({'71', 'kiennq', 'default'}),
	'NO_JUNCTIONS' ..boolean_parser,
	'show_update_log' ..boolean_parser,
	'virustotal_api_key',
	'proxy'
})

local scoop_parser = parser({
	{'info', 'depends', 'home'} ..parser({get_known_apps}),
	'alias' ..parser({'add', 'list' ..parser({'-v', '--verbose'}), 'rm'}),
	'bucket' ..parser({'add' ..parser({get_known_buckets}), 'list', 'known', 'rm' ..parser({get_installed_buckets})}),
	'cache' ..parser({'show', 'rm'} ..parser({get_cache})),
	'checkup',
	'cleanup' ..parser({get_installed_apps},
		'-g', '--global'):loop(1),
	'config' ..config_parser,
	'create',
	'export',
	'list',
	'install' ..parser({get_known_apps},
		'-g', '--global',
		'-i', '--independent',
		'-k', '--no-cache',
		'-s', '--skip',
		'-a' ..architecture_parser, '--arch' ..architecture_parser
		):loop(1),
	'prefix' ..parser({get_installed_apps}),
	{'reset', 'hold', 'unhold'} ..parser({get_installed_apps}):loop(1),
	'search',
	'status',
	'uninstall' ..parser({get_installed_apps},
		'-g', '--global',
		'-p', '--purge'):loop(1),
	'update' ..parser({get_installed_apps},
		'-g', '--global',
		'-f', '--force',
		'-i', '--independent',
		'-k', '--no-cache',
		'-s', '--skip',
		'-q', '--quite'):loop(1),
	'virustotal' ..parser({get_known_apps},
		'-a' ..architecture_parser, '--arch' ..architecture_parser,
		'-s', '--scan',
		'-n', '--no-depends'):loop(1),
	'which'
})

local help_parser = parser({
	'help' ..parser(scoop_parser:flatten_argument(1))
})

clink.arg.register_parser('scoop', scoop_parser)
clink.arg.register_parser('scoop', help_parser)
