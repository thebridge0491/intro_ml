/*
exec groovy $0 $@
exit
*/
//#!/usr/bin/env groovy

//groovy.grape.Grape.grab(group:'com.github.spullara.mustache.java',
//	module:'compiler', version:'[0.8.12,)')
@Grab(group='com.github.spullara.mustache.java', module='compiler',
	version='[0.8.12,)')

import java.nio.file.Paths
import com.github.mustachejava.DefaultMustacheFactory

this.scriptFile = new File(this.class.protectionDomain.codeSource.location.path)

def run_cmd(String cmd, File dir) {
	def proc = cmd.execute(null, dir)
	proc.waitForProcessOutput((Appendable)System.out, System.err)
	if (0 != proc.exitValue()) {
		throw new Exception("Command '${cmd}' exited with code: ${proc.exitValue()}")
	}
}

def regex_checks(String nameX, Map<String, String> data) {
	if (data.get('parentregex') && !(data.get('parent', '') =~ data['parentregex'])) {
		println "ERROR: Parent regex match failure (${data.get('parent', '')} =~ ${data['parentregex']}) for package (${nameX})."
		System.exit 1
	}
	if (data.get('projectregex') && !(data['project'] =~ data['projectregex'])) {
		println "ERROR: Project regex match failure (${data['project']} =~ ${data['projectregex']}) for package (${nameX})."
		System.exit 1
	}
}

def configData(String dataPath, Map<String, String> kvset) {
	def (initData, cfg) = [[:], [:]]
	
	try {
		def rdr = new groovy.json.JsonSlurper()
		initData = rdr.parse(new java.io.InputStreamReader(
			new java.io.FileInputStream(dataPath)))
	} catch (java.io.IOException exc) {
		exc.printStackTrace()
		System.exit 1
	}
	
	initData['date'] = (new Date()).format('yyyy-MM-dd')
	initData << kvset
	cfg << initData
	
	def namespace = sprintf("%s%s.%s", cfg['groupid'] ? 
		cfg['groupid'] + '.' : '', cfg.get('parent', ''), cfg['project'])
	def name = sprintf("%s%s%s", cfg.get('parent', ''), cfg.get('separator', ''),
		cfg['project'])
	def parentcap = cfg.get('parent', '').split(/cfg.get('separator', '-')/).collect{s -> 
		s.capitalize()}.join(cfg.get('joiner', ''))
	
	cfg << ['year': cfg['date'].split('-')[0], 'namespace': namespace, 
		'nesteddirs': namespace.replace('.', '/'), 'name': name,
		'parentcap': parentcap, 'projectcap': cfg['project'].capitalize()]
	regex_checks(cfg['name'], cfg)
	return cfg
}

def render_skeleton(String skeleton, Map<String, String> data) {
	def files_skel = []
	data['skeletondir'] = Paths.get(scriptFile.parent, skeleton).toString()
	start_dir = Paths.get(data['skeletondir'], '{{name}}').toString()
	
	(new File(start_dir)).eachFileRecurse (groovy.io.FileType.FILES) {
		f -> files_skel << f.path.replace(start_dir, '')}
	def inouts = [:]
	def mf = new DefaultMustacheFactory()
	
	for (f in files_skel) {
		def writerOut = new StringWriter()
		def render = mf.compile(new StringReader(f), "skeletonX")
		render.execute(writerOut, data)
		inouts[f.toString()] = writerOut.toString().replaceFirst(
			/\.mustache$/, '')
		//writerOut.flush()
	}
	printf("... %d files processing ...\n", inouts.size())
	
	for (pathX in inouts.values()) {
		def dirX = Paths.get(data['name'], pathX).getParent().toFile()
		if (!(dirX).exists())
			run_cmd(sprintf("mkdir -p %s", dirX), new File('.'))
	}
	inouts.each{src, dst -> 
		def writerOut = new FileWriter(Paths.get(data['name'], dst).toFile())
		def render = mf.compile(new FileReader(
			Paths.get(start_dir, src).toFile()), "templateX")
		render.execute(writerOut, data)
		writerOut.close() // writerOut.flush()
		}
	
	println 'Post rendering message'
	run_cmd(sprintf("groovy %s/choices/post_render.groovy", data['name']), 
		new File('.'))
}

def printUsage(String str, int status) {
	System.err.format("Usage: groovy %s [-h][-d datajson][-s skeleton][-i fileIn][-o fileOut][-f func][-k key1=val1,...,keyN=valN]\n",
		scriptFile.name)
	System.err.println(str)
	System.exit(status)
}

def parse_cmdopts(Map<String, String> optsMap, String[] args) {
	def option = null
	for (int i = 0; args.length > i; ++i) {
		option = args[i]
		  
		if ('-' != option.charAt(0) || 1 == option.length())
			printUsage('Not an option: ' + option, 1)
		switch (option.charAt(1)) {
			case 'h': printUsage('', 0)
				break
			case 'd': 
				if ((args.length <= i + 1) || ('-' == args[i + 1].charAt(0)))
					printUsage('Missing argument for ' + option, 1)
				optsMap['datajson'] = args[++i]
				break
			case 's': 
				if ((args.length <= i + 1) || ('-' == args[i + 1].charAt(0)))
					printUsage('Missing argument for ' + option, 1)
				optsMap['skeleton'] = args[++i]
				break
			case 'i': 
				if ((args.length <= i + 1))
					printUsage('Missing argument for ' + option, 1)
				argI = args[++i]
				optsMap['fileIn'] = '-' == argI ? System.in : 
					new FileInputStream(argI)
				break
			case 'o': 
				if ((args.length <= i + 1))
					printUsage('Missing argument for ' + option, 1)
				argO = args[++i]
				optsMap['fileOut'] = '-' == argO ? System.out : 
					new PrintStream(new FileOutputStream(argO), true)
				break
			case 'f': 
				if ((args.length <= i + 1) || ('-' == args[i + 1].charAt(0)))
					printUsage('Missing argument for ' + option, 1)
				optsMap['func'] = args[++i]
				break
			case 'k': 
				if ((args.length <= i + 1) || ('-' == args[i + 1].charAt(0)))
					printUsage('Missing argument for ' + option, 1)
				argsK = args[++i].split(',')
				for (kv in argsK)
					optsMap['kvset'][kv.split('=')[0]] = kv.split('=')[1]
				break
			default: printUsage('Unknown option: ' + option, 1)
		}
	}
}

def optsMap = ['datajson': 'data.json', 'skeleton': 'skeleton-rb',
	'fileIn': System.in, 'fileOut': System.out, 'func': 'skeleton',
	'kvset': [:]]
parse_cmdopts(optsMap, args)

if ('file' == optsMap['func']) {
	def cfg = configData(optsMap['datajson'], optsMap['kvset'])
	def writerOut = new BufferedWriter(new OutputStreamWriter(optsMap['fileOut']))
	def render = (new DefaultMustacheFactory()).compile(
		new InputStreamReader(optsMap['fileIn']), 'templateX')
	render.execute(writerOut, cfg)
	writerOut.close() //writerOut.flush()
} else {
	def cfg = configData(Paths.get(scriptFile.parent, optsMap['skeleton'], 
		optsMap['datajson']).toString(), optsMap['kvset'])
	render_skeleton(optsMap['skeleton'], cfg)
}
