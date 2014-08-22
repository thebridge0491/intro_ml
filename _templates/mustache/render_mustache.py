from __future__ import (absolute_import, division, print_function,
	unicode_literals)

import os, sys, glob, argparse, re, json, time
from future.builtins import (ascii, str, filter, hex, map, oct, zip)

import pystache

SCRIPTPARENT = os.path.dirname(os.path.abspath(__file__))
CUR_DIR = os.path.abspath(os.curdir)

def regex_checks(nameX, data=None):
	if data.get('parentregex') and not re.match(data['parentregex'], data.get('parent', '')):
		print("ERROR: Parent regex match failure (re.match({0}, {1})) for package ({2}).".format(
			data['parentregex'], data.get('parent', ''), nameX))
		sys.exit(1)
	if data.get('projectregex') and not re.match(data['projectregex'], data['project']):
		print("ERROR: Project regex match failure (re.match({0}, {1})) for package ({2}).".format(
			data['projectregex'], data['project'], nameX))
		sys.exit(1)	

def config_data(data_json, kvset=None):
	str_data = ''
	
	with open(data_json) as fIn:
		str_data = fIn.read()
	#initdata, cfg = json.loads(str_data.decode(encoding='utf-8')), {}
	initdata, cfg = json.loads(str_data), {}
	initdata.update({'date': time.strftime('%Y-%m-%d')})
	
	cfg.update(initdata)
	cfg.update(kvset if kvset else {})
	
	namespace = '{0}{1}.{2}'.format(cfg['groupid'] + '.' if cfg.get('groupid')
		else '', cfg.get('parent', ''), cfg['project'])
	name = '{0}{1}{2}'.format(cfg.get('parent', ''), cfg.get('separator', ''),
		cfg['project'])
	parentcap = str.join(cfg.get('joiner', ''), map(lambda e: e.capitalize(),
		cfg.get('parent', '').split(cfg.get('separator', '-'))))
	
	cfg.update({'year': cfg['date'].split('-')[0], 'namespace': namespace,
		'nesteddirs': namespace.replace('.', '/'), 'name': name,
		'parentcap': parentcap, 'projectcap': cfg['project'].capitalize()})
	regex_checks(cfg['name'], cfg)
	return cfg

def render_skeleton(skeleton='skeleton-rb', data=None):
	data.update({'skeletondir': os.path.join(SCRIPTPARENT, skeleton)})
	start_dir = os.path.join(data['skeletondir'], '{{name}}')
	
	files_skel = map(lambda p: os.path.relpath(p, start=start_dir), 
		filter(lambda p: os.path.isfile(p), glob.glob(start_dir + '/**/*',
		recursive=True)  + glob.glob(start_dir + '/**/.*', recursive=True)))
	inouts = {}
	for skelX in files_skel:
		inouts[skelX] = re.sub('\.mustache$', '', pystache.render(
			os.path.join(CUR_DIR, data['name'], skelX), data))
	print('... {0} files processing ...'.format(len(inouts)))
	
	for dirX in [os.path.dirname(pathX) for pathX in set(inouts.values())]:
		if not os.path.exists(os.path.join(CUR_DIR, data['name'], dirX)):
			os.makedirs(os.path.join(CUR_DIR, data['name'], dirX))
	for src, dst in inouts.items():
		with open(os.path.join(CUR_DIR, data['name'], dst), 'w+') as fOut, open(os.path.join(start_dir, src)) as fIn:
			fOut.write(pystache.render(fIn.read(), data))
	
	print('Post rendering message')
	os.chdir(data['name'])
	os.system('python choices/post_render.py')

def parse_cmdopts(args=None):
	opts_parser = argparse.ArgumentParser()
	
	opts_parser.add_argument('data_json', nargs='?', default='data.json')
	opts_parser.add_argument('-s', '--skeleton', default='skeleton-rb')
	opts_parser.add_argument('-i', '--fileIn', type=argparse.FileType('r'),
		default=sys.stdin)
	opts_parser.add_argument('-o', '--fileOut', type=argparse.FileType('w'),
		default=sys.stdout)
	opts_parser.add_argument('--kvset', metavar='KEY=VALUE', nargs='+',
		help='Set key=value pairs' 'Ex: --kvset key1="val1"')
	opts_parser.add_argument('-f', '--func', default='skeleton',
		choices=[None, 'skeleton', 'file'], help='Specify render method')
	
	return opts_parser.parse_args(args)

if '__main__' == __name__:
	opts_hash = parse_cmdopts(sys.argv[1:])
	kvset = dict(kv.split('=', 1) for kv in opts_hash.kvset) if opts_hash.kvset else None
	
	if 'file' == opts_hash.func:
		cfg = config_data(os.path.join(CUR_DIR, opts_hash.data_json), kvset)
	else:
		cfg = config_data(os.path.join(SCRIPTPARENT, opts_hash.skeleton, 
			opts_hash.data_json), kvset)
	
	switcher = {
		None: lambda: render_skeleton(opts_hash.skeleton, cfg),
		'skeleton': lambda: render_skeleton(opts_hash.skeleton, cfg),
		'file': lambda: opts_hash.fileOut.write(pystache.render(
			opts_hash.fileIn.read(), cfg))
	}
	func = switcher.get(opts_hash.func, lambda:
		print('Invalid render method: {0}'.format(opts_hash.func)))
	sys.exit(func())
