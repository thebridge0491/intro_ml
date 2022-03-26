/*
exec groovy $0 $@
exit
*/
//#!/usr/bin/env groovy

@Grab(group='info.picocli', module='picocli', version='[4.3.2,)')
//groovy.grape.Grape.grab(group:'com.github.spullara.mustache.java',
//	module:'compiler', version:'[0.8.12,)')
//@Grab(group='com.github.spullara.mustache.java', module='compiler', version='[0.8.12,)')
@Grab(group='com.github.jknack', module='handlebars', version='[4.1.3,)')
@Grab(group='org.yaml', module='snakeyaml', version='[1.26,)')
@Grab(group='com.moandjiezana.toml', module='toml4j', version='[0.7.2,)')

//@picocli.CommandLine.Command(
//        description = "Simple Groovy script to render templates(mustache).",
//        version = '0.1.0', showDefaultValues = true
//)
//@picocli.groovy.PicocliScript

import java.nio.file.Paths
import java.nio.file.Files
//import com.github.mustachejava.DefaultMustacheFactory
import com.github.jknack.handlebars.io.FileTemplateLoader
import com.github.jknack.handlebars.Handlebars
import groovy.transform.Field
//import static picocli.CommandLine.*
import picocli.CommandLine.Command
import picocli.CommandLine.Option
import picocli.CommandLine.Parameters
import picocli.CommandLine.ParameterException
import picocli.CommandLine.ITypeConverter

this.scriptFile = new File(this.class.protectionDomain.codeSource.location.path)

def run_cmd(String cmd, File dir) {
	def proc = cmd.execute(null, dir)
	proc.waitForProcessOutput((Appendable)System.out, System.err)
	if (0 != proc.exitValue()) {
		throw new Exception("Command '${cmd}' exited with code: ${proc.exitValue()}")
	}
}

def deserializeFile(String dataPath, String fmt, String dateKey) {
	def initData = [:]
	
	if (fmt in ['yaml', 'json']) {
		try {
			def yaml = new org.yaml.snakeyaml.Yaml()
			initData << yaml.load(new java.io.FileInputStream(dataPath))
		} catch (java.io.IOException exc) {
			exc.printStackTrace()
			System.exit 1
		}
	} else if ('toml' == fmt) {
		try {
			def toml = new com.moandjiezana.toml.Toml()
			initData << toml.read(new java.io.InputStreamReader(
				new java.io.FileInputStream(dataPath))).toMap()
		} catch (java.io.IOException exc) {
			exc.printStackTrace()
			System.exit 1
		}
	} /*else if ('json' == fmt) {
		try {
			def rdr = new groovy.json.JsonSlurper()
			//initData = rdr.parse(new java.io.InputStreamReader(
			//	new java.io.FileInputStream(dataPath)))
			initData << rdr.parse(new java.io.InputStreamReader(
				new java.io.FileInputStream(dataPath)))
		} catch (java.io.IOException exc) {
			exc.printStackTrace()
			System.exit 1
		}
	}*/
	
	initData[dateKey] = (new Date()).format('yyyy-MM-dd')
	return initData
}

def deserializeStr(String dataStr, String fmt, String dateKey) {
	def initData = [:]
	
	if (0 != dataStr.length()) {
		if (fmt in ['yaml', 'json']) {
			def yaml = new org.yaml.snakeyaml.Yaml()
			initData << yaml.load(dataStr)
		} else if ('toml' == fmt) {
			def toml = new com.moandjiezana.toml.Toml()
			initData << toml.read(dataStr).toMap()
		} /*else if ('json' == fmt) {
			def rdr = new groovy.json.JsonSlurper()
			//initData = rdr.parseText(dataStr)
			initData << rdr.parseText(dataStr)
		}*/
	}
	
	initData[dateKey] = (new Date()).format('yyyy-MM-dd')
	return initData
}

def regex_checks(String pat, String substr, String txt) {
	if (!(substr =~ pat)) {
		println "ERROR: Regex match failure (${substr} =~ ${pat}) for (${txt})."
		System.exit 1
	}
}

def deriveSkelVars(Map<String, String> ctx) {
	def name = sprintf("%s%s%s", ctx.get('parent', ''), ctx.get('separator', ''),
		ctx['project'])
	def parentcap = ctx.get('parent', '').split(/ctx.get('separator', '-')/).collect{s -> 
		s.capitalize()}.join(ctx.get('joiner', ''))
	def namespace = sprintf("%s%s.%s", ctx['groupid'] ? 
		ctx['groupid'] + '.' : '', ctx.get('parent', ''), ctx['project'])
	
	ctx << ['year': ctx['date'].split('-')[0], 'name': name, 'parentcap': parentcap,
		'projectcap': ctx['project'].capitalize(), 'namespace': namespace, 
		'nesteddirs': namespace.replace('.', '/')]
	return ctx
}

def render_skeleton(String skeleton, Map<String, String> ctx) {
	ctx << ['skeletondir': Paths.get(scriptFile.parent, skeleton).toString()]
	def start_dir = Paths.get(ctx['skeletondir'], '{{name}}').toString()
	def files_skel = []
	(new File(start_dir)).eachFileRecurse (groovy.io.FileType.FILES) {
		f -> files_skel << f.path.replace(start_dir, '')}
	def (renderouts, copyouts, pat_mustache) = [[:], [:], /\.mustache$/]
	//def mf = new DefaultMustacheFactory()
	def hb = new Handlebars(new FileTemplateLoader(start_dir, ".mustache"))
	
	for (skelX in files_skel) {
		def writerOut = new StringWriter()
		
		// using com.github.spullara.mustache.java:compiler
		//def template = mf.compile(new StringReader(skelX), "skeletonX")
		//template.execute(writerOut, ctx)
		
		// using com.github.jknack:handlebars
		def template = hb.compileInline(skelX)
		template.apply(ctx, writerOut)
		
		if (skelX =~ pat_mustache) {
			renderouts[skelX.toString()] = writerOut.toString().replaceFirst(
				pat_mustache, '')
			//writerOut.flush()
		} else {
			copyouts[skelX.toString()] = writerOut.toString()
			//writerOut.flush()
		}
	}
	printf("... processing files -- rendering %d ; copying %d ...\n", renderouts.size(),
		copyouts.size())
	
	for (pathX in (renderouts.values() + copyouts.values())) {
		def dirX = Paths.get(ctx['name'], pathX).getParent().toFile()
		if (!(dirX).exists())
			run_cmd(sprintf("mkdir -p %s", dirX), new File('.'))
	}
	renderouts.each{srcR, dstR -> 
		def writerOut = new FileWriter(Paths.get(ctx['name'], dstR).toFile())
		
		// using com.github.spullara.mustache.java:compiler
		//def template = mf.compile(new FileReader(
		//	Paths.get(start_dir, srcR).toFile()), "templateX")
		//template.execute(writerOut, ctx)
		
		// using com.github.jknack:handlebars
		def template = hb.compile(srcR.replaceFirst(pat_mustache, ''))
		template.apply(ctx, writerOut)
		
		writerOut.close() // writerOut.flush()
		}
	copyouts.each{srcC, dstC -> 
		def writerOut = new FileWriter(Paths.get(ctx['name'], dstC).toFile())
		writerOut.write(new File(Paths.get(start_dir, srcC).toString()).getText('UTF-8'))
		writerOut.close() // writerOut.flush()
		}
	
	println 'Post rendering message'
	run_cmd(sprintf("groovy %s/choices/post_gen_project.groovy", ctx['name']), 
		new File('.')) // groovy ___.groovy | sh ___.sh
}

def parse_cmdoptsCliBldr(Map<String, String> optsMap, String[] args) {
	def cli = new CliBuilder(usage: sprintf("groovy %s [OPTS]\n", scriptFile.name))
	cli.with {
		h longOpt: 'help', 'print this message'
		t longOpt: 'template', 'template', type: String, args: '1', argName: 'TEMPLATE',
			description: 'Template path (default: skeleton-ml)'
		d longOpt: 'data', 'data', type: String, args: 1, argName: 'DATA',
			description: 'Data path or - (for stdin) (default: data.yaml)'
		f longOpt: 'datafmt', 'datafmt', type: String, args: 1, argName: 'FMT',
			description: 'Specify data file format (default: yaml, [yaml, json, toml])'
		//i longOpt: 'fileIn', 'fileIn', args: '1', argName: 'FILEIN',
		//	description: 'File in - (for stdin) or path (default: System.in)'
		o longOpt: 'fileOut', 'fileOut', args: '1', argName: 'FILEOUT',
			description: 'File out - (for stdout) or path (default: System.out)'
		k longOpt: 'kvset', 'kvset', type: Map, args: '+',
			argName: 'Set key=value pairs (key1=val1,..,keyN=valN)'
	}
	def options = cli.parse(args) //; println options.arguments()
	if (options['help']) {
		cli.usage()
		//System.err.println("???")
		System.exit(1)
	}
	if (options['kvset'])
		for (kv in options['kvset'].split(','))
			optsMap['kvset'][kv.split('=')[0]] = kv.split('=')[1]
	for (el in ['datafmt', 'template'])
		if (options[el])
			optsMap[el] = options[el]
	
	//if (options['fileIn'] && '-' != options['fileIn'])
	//	optsMap['fileIn'] = new FileInputStream(options['fileIn'])
	if (options['fileOut'] && '-' != options['fileOut'])
		optsMap['fileOut'] = new PrintStream(new FileOutputStream(options['fileOut']),
			true)
	optsMap['data'] = (!options['data'] || '-' == options['data']) ? System.in :
		new FileInputStream(options['data'])
}

class InputStreamConverter implements ITypeConverter<FileInputStream> {
	FileInputStream convert(String filename) {
        new FileInputStream(filename)
    }
}

class PrintStreamConverter implements ITypeConverter<PrintStream> {
	PrintStream convert(String filename) {
		new PrintStream(new FileOutputStream(filename), true)
	}
}

class RenderOptions implements Runnable {
	@Parameters(arity = "1", paramLabel = "TEMPLATE", defaultValue = "skeleton-ml",
		description = "Template path (default: \${DEFAULT-VALUE})")
	def template = "skeleton-ml"
		
	@Option(names = ["-h", "--help"], usageHelp = true, description = "...")
    boolean help = false //helpRequested
    
    //enum ChoicesFmt { yaml, json, toml }
    
    @Option(names = ["-d", "--data"], defaultValue = "data.yaml",
    	description = "Data path or - (for stdin) (default: \${DEFAULT-VALUE})")
    def data = "data.yaml"
    
    @Option(names = ["-f", "--datafmt"], defaultValue = "yaml",
    	completionCandidates = {["yaml", "json", "toml"]},
    	description = "Specify data file format (default: \${DEFAULT-VALUE}) (choices: \${COMPLETION-CANDIDATES})")
    def datafmt = "yaml"
    //ChoicesFmt datafmt = ChoicesFmt.yaml  // str --> options['datafmt'].name()
    
    //@Option(names = ["-i", "--fileIn"],
    //	//defaultValue = "-",
    //	converter = InputStreamConverter.class,
    //	description = "File in - (for stdin) or path (default: System.in)")
    //def fileIn = System.in
    
    @Option(names = ["-o", "--fileOut"],
    	//defaultValue = "-",
    	converter = PrintStreamConverter.class,
    	description = "File out - (for stdout) or path (default: System.out)")
    def fileOut = System.out
    
    @Option(names = ["-k", "--kvset"], arity = "1..*", split = ",",
    	description = "Set key=value pairs (key1=val1,..,keyN=valN)")
    Map<String, String> kvset = [:]
    
    void run() {
    	//print ""
    }
}

def parse_cmdopts(Map<String, String> optsMap, String[] args) {
	def (options, res) = [new RenderOptions(), null]
	def cmdline = new picocli.CommandLine(options)
	
	cmdline.unmatchedArgumentsAllowed = true
	try {
		res = cmdline.parseArgs(args)
	} catch (ParameterException ex) {
    	println ex.message
    	cmdline.usage(System.out)
	}
	//cmdline.execute(args) //;println cmdline.unmatchedArguments
	
	if (cmdline.usageHelpRequested) {
		cmdline.usage(System.out)
		//System.err.println("???")
		System.exit(1)
	}
	for (el in ['data', 'datafmt', 'fileOut', 'kvset', 'template'])
		if (options[el])
			optsMap[el] = options[el]
}

def optsMap = ['data': 'data.yaml', 'datafmt': 'yaml', 'fileOut': System.out,
	'kvset': [:], 'template': 'skeleton-ml']
parse_cmdopts(optsMap, args)

def cfg = [:]

if (!Files.exists(Paths.get(optsMap['template'])) &&
		!Files.exists(Paths.get(scriptFile.parent, optsMap['template']))) {
	System.err.println("Non-existent template: %s", optsMap['template'])
	System.exit(1)
}
def isDir = Files.isDirectory(Paths.get(optsMap['template'])) || 
	Files.isDirectory(Paths.get(scriptFile.parent, optsMap['template']))
if ('-' == optsMap['data'])
	cfg = deserializeStr(System.in.getText('UTF-8'), optsMap['datafmt'], 'date')
	
if (!isDir) {
	if ('-' != optsMap['data'])
		cfg = deserializeFile(optsMap['data'], optsMap['datafmt'], 'date')
	cfg << optsMap['kvset']
	def writerOut = new BufferedWriter(new OutputStreamWriter(optsMap['fileOut']))
	
	// using com.github.spullara.mustache.java:compiler
	//def mf = new DefaultMustacheFactory()
	//def template = mf.compile(new FileReader(Paths.get(optsMap['template']).toFile()),
	//	"templateX")
	//template.execute(writerOut, cfg)
	
	// using com.github.jknack:handlebars
	def hb = new Handlebars(new FileTemplateLoader('.', ".mustache"))
	def template = hb.compile(optsMap['template'].replaceFirst(/\.mustache$/, ''))
	template.apply(cfg, writerOut)
	
	writerOut.close() //writerOut.flush()
} else {
	if ('-' != optsMap['data'])
		cfg = deserializeFile(Paths.get(scriptFile.parent, optsMap['template'], 
			optsMap['data']).toString(), optsMap['datafmt'], 'date')
	cfg << optsMap['kvset']
	cfg = deriveSkelVars(cfg)
	regex_checks(cfg.get('parentregex', ''), cfg.get('parent', ''), cfg.get('name', ''))
	regex_checks(cfg.get('projectregex', ''), cfg.get('project', ''), cfg.get('name', ''))
	render_skeleton(optsMap['template'], cfg)
}
