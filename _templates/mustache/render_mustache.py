from __future__ import (absolute_import, division, print_function,
	unicode_literals)

import os, sys, glob, argparse, re, time
from future.builtins import (ascii, str, filter, hex, map, oct, zip)

#import pystache
import chevron

SCRIPTPARENT = os.path.dirname(os.path.abspath(__file__))
CUR_DIR = os.path.abspath(os.curdir)

def deserialize_file(datapath, fmt='yaml', date_key='date'):
	initdata = {}
	
	if fmt in ['yaml', 'json']:
		try:
			import yaml						# [Base|Safe|Full]Loader
			with open(datapath) as fIn:
				initdata.update(yaml.load(fIn, Loader=yaml.SafeLoader))
		except ImportError as exc:
			print(repr(exc))
	elif 'toml' == fmt:
		try:
			import toml
			with open(datapath) as fIn:
				initdata.update(toml.load(fIn))
		except ImportError as exc:
			print(repr(exc))
	#elif 'json' == fmt:
	#	import json
	#	with open(datapath) as fIn:
	#		#initdata = json.load(fIn)
	#		initdata.update(json.load(fIn))
	
	initdata.update({date_key: time.strftime('%Y-%m-%d')})
	return initdata

def deserialize_str(datastr, fmt='yaml', date_key='date'):
	initdata = {}
	
	if datastr is not None:
		if fmt in ['yaml', 'json']:
			try:
				import yaml						# [Base|Safe|Full]Loader
				initdata.update(yaml.load(datastr, Loader=yaml.SafeLoader))
			except ImportError as exc:
				print(repr(exc))
		elif 'toml' == fmt:
			try:
				import toml
				initdata.update(toml.loads(datastr))
			except ImportError as exc:
				print(repr(exc))
		#elif 'json' == fmt:
		#	import json
		#	#initdata = json.loads(datastr.decode(encoding='utf-8'))
		#	initdata.update(json.loads(datastr))
	
	initdata.update({date_key: time.strftime('%Y-%m-%d')})
	return initdata

def regex_checks(pat, substr, txt):
	if not re.match(pat, substr):
		print("ERROR: Regex match failure (re.match({0}, {1})) for ({2}).".format(
			pat, substr, txt))
		sys.exit(1)

def derive_skel_vars(ctx=None):
	name = '{0}{1}{2}'.format(ctx.get('parent', ''), ctx.get('separator', ''),
		ctx['project'])
	parentcap = str.join(ctx.get('joiner', ''), map(lambda e: e.capitalize(),
		ctx.get('parent', '').split(ctx.get('separator', '-'))))
	namespace = '{0}{1}.{2}'.format(ctx['groupid'] + '.' if ctx.get('groupid')
		else '', ctx.get('parent', ''), ctx['project'])
	
	ctx.update({'year': ctx['date'].split('-')[0], 'name': name, 'parentcap': parentcap,
		'projectcap': ctx['project'].capitalize(), 'namespace': namespace,
		'nesteddirs': namespace.replace('.', '/')})
	return ctx

def render_skeleton(skeleton='skeleton-ml', ctx=None):
	ctx.update({'skeletondir': os.path.join(SCRIPTPARENT, skeleton)})
	start_dir = os.path.join(ctx['skeletondir'], '{{name}}')
	files_skel = map(lambda p: os.path.relpath(p, start=start_dir), 
		filter(lambda p: os.path.isfile(p), glob.glob(start_dir + '/**/*',
		recursive=True)  + glob.glob(start_dir + '/**/.*', recursive=True)))
	renderouts, copyouts, pat_mustache = {}, {}, re.compile('\.mustache$')
	for skelX in files_skel:
		if pat_mustache.search(skelX) :
			#renderouts[skelX] = re.sub(pat_mustache, '', pystache.render(
			#	os.path.join(CUR_DIR, ctx['name'], skelX), ctx))
			renderouts[skelX] = re.sub(pat_mustache, '', chevron.render(
				os.path.join(CUR_DIR, ctx['name'], skelX), ctx))
		else:
			#copyouts[skelX] = pystache.render(os.path.join(CUR_DIR, ctx['name'], skelX),
			#	ctx)
			copyouts[skelX] = chevron.render(os.path.join(CUR_DIR, ctx['name'], skelX),
				ctx)
	print('... processing files -- rendering {0} ; copying {1} ...'.format(
		len(renderouts), len(copyouts)))
	
	for dirX in [os.path.dirname(pathX) for pathX in 
			set(renderouts.values()) | set(copyouts.values())]:
		if not os.path.exists(os.path.join(CUR_DIR, ctx['name'], dirX)):
			os.makedirs(os.path.join(CUR_DIR, ctx['name'], dirX))
	for srcR, dstR in renderouts.items():
		with open(os.path.join(CUR_DIR, ctx['name'], dstR), 'w+') as fOut, \
				open(os.path.join(start_dir, srcR)) as fIn:
			#fOut.write(pystache.render(fIn.read(), ctx))
			fOut.write(chevron.render(fIn.read(), ctx))
	for srcC, dstC in copyouts.items():
		with open(os.path.join(CUR_DIR, ctx['name'], dstC), 'w+') as fOut, \
				open(os.path.join(start_dir, srcC)) as fIn:
			fOut.write(fIn.read())
	
	print('Post rendering message')
	os.chdir(ctx['name'])
	os.system('python choices/post_gen_project.py') # python ___.py | sh ___.sh

def parse_cmdopts(args=None):
	opts_parser = argparse.ArgumentParser()
	
	opts_parser.add_argument('template', nargs='?', default='skeleton-ml',
		help='Template path')
	opts_parser.add_argument('-d', '--data', default='data.yaml',
		help='Data path or - (for stdin)')
	opts_parser.add_argument('-f', '--datafmt', default='yaml',
		choices=[None, 'yaml', 'json', 'toml'], help='Specify data file format')
	#opts_parser.add_argument('-i', '--fileIn', type=argparse.FileType('r'),
	#	default=sys.stdin, help='File in - (for stdin) or path')
	opts_parser.add_argument('-o', '--fileOut', type=argparse.FileType('w'),
		default=sys.stdout, help='File out - (for stdout) or path')
	opts_parser.add_argument('-k', '--kvset', metavar='KEY=VALUE', nargs='+',
		help='Set key=value pairs (Ex: -k key1="val1")')
	
	return opts_parser.parse_args(args)

def main(argv=None):
	opts_hash, cfg = parse_cmdopts(argv), {}
	
	if not os.path.exists(opts_hash.template) and \
			not os.path.exists(os.path.join(SCRIPTPARENT, opts_hash.template)):
		print('Non-existent template: {0}'.format(opts_hash.template))
		sys.exit(1)
	kvset = dict(kv.split('=', 1) for kv in opts_hash.kvset) if opts_hash.kvset else None
	is_dir = os.path.isdir(opts_hash.template) or \
			os.path.isdir(os.path.join(SCRIPTPARENT, opts_hash.template))
	if '-' == opts_hash.data:
		cfg = deserialize_str(sys.stdin.read(), fmt=opts_hash.datafmt, date_key='date')
	
	if not is_dir:
		if not '-' == opts_hash.data:
			cfg = deserialize_file(opts_hash.data, fmt=opts_hash.datafmt, date_key='date')
		cfg.update(kvset if kvset else {})
	else:
		if not '-' == opts_hash.data:
			cfg = deserialize_file(os.path.join(SCRIPTPARENT, opts_hash.template,
				opts_hash.data), fmt=opts_hash.datafmt, date_key='date')
		cfg.update(kvset if kvset else {})
		cfg = derive_skel_vars(cfg)
		regex_checks(cfg.get('parentregex', ''), cfg.get('parent', ''), cfg.get('name', ''))
		regex_checks(cfg.get('projectregex', ''), cfg.get('project', ''), cfg.get('name', ''))
		
	switcher = {
		None: lambda: render_skeleton(opts_hash.template, cfg),
		True: lambda: render_skeleton(opts_hash.template, cfg),
		#False: lambda: opts_hash.fileOut.write(pystache.render(
		#	open(opts_hash.template, 'r'), cfg))
		False: lambda: opts_hash.fileOut.write(chevron.render(
			open(opts_hash.template, 'r'), cfg))
	}
	func = switcher.get(is_dir, lambda:
		print('(is_dir: {0}) Invalid template: {1}'.format(is_dir, opts_hash.template)))
	return func()


if '__main__' == __name__:
	import sys
	#raise SystemExit(main(sys.argv[1:]))
	sys.exit(main(sys.argv[1:]))
	