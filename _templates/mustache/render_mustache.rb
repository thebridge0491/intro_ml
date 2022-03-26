#!/usr/bin/env ruby -w

require 'English'
require 'json'
require 'psych'
require 'toml'
require 'mustache'
require 'fileutils'

module RenderMustache
	extend self
	
	SCRIPTPARENT = File.dirname(File.absolute_path(__FILE__))

	def deserialize_file(datapath, fmt='yaml', date_key='date')
		initdata = {}
	
		keys2sym = proc {|h| h.map{|k, v|
		  [k.to_sym, v.is_a?(Hash) ? keys2sym.call(v) : v]}.to_h}
	
		if ['yaml', 'json'].include? fmt
			initdata = initdata.merge(keys2sym.call Psych.load_file(datapath))
		elsif 'toml' == fmt
			initdata = initdata.merge(keys2sym.call TOML.load_file(datapath))
		#elsif 'json' == fmt
		#	#initdata = JSON.parse(File.read(datapath), {:symbolize_names => true})
		#	initdata = initdata.merge(JSON.parse(File.read(datapath), {:symbolize_names => true}))
		end
	
		initdata = initdata.merge(date_key.to_sym => Time.new.strftime('%Y-%m-%d'))
		return initdata
	end

	def deserialize_str(datastr, fmt='yaml', date_key='date')
		initdata = {}
	
		keys2sym = proc {|h| h.map{|k, v|
		  [k.to_sym, v.is_a?(Hash) ? keys2sym.call(v) : v]}.to_h}
	
		if ['yaml', 'json'].include? fmt
			initdata = initdata.merge(Psych.load(datastr, {:symbolize_names => true}))
		elsif 'toml' == fmt
			initdata = initdata.merge(keys2sym.call TOML.load(datastr))
		#elsif 'json' == fmt
		#	#initdata = JSON.parse(datastr, {:symbolize_names => true})
		#	initdata = initdata.merge(JSON.parse(datastr, {:symbolize_names => true}))
		end
	
		initdata = initdata.merge(date_key.to_sym => Time.new.strftime('%Y-%m-%d'))
		return initdata
	end

	def regex_checks(pat, substr, txt)
		if (!(%r"#{pat}".match(substr)))
			puts "ERROR: Regex match failure (%r'#{pat}'.match(#{substr})) for (#{txt})."
			exit 1
		end
	end

	def derive_skel_vars(ctx={})
		name = "#{ctx[:parent]}#{ctx.fetch(:separator, '')}#{ctx[:project]}"
		parentcap = ctx.fetch(:parent, '').split(ctx.fetch(:separator, '-')).map{|s| s.capitalize
			}.join(ctx.fetch(:joiner, ''))
		namespace = "#{ctx[:groupid] ? ctx[:groupid] + '.' : ''}#{ctx.fetch(:parent, '')}.#{ctx[:project]}"
	
		ctx = ctx.merge(:year => ctx[:date].split('-')[0], :name => name,
			:parentcap => parentcap, :projectcap => ctx[:project].capitalize,
			:namespace => namespace, :nesteddirs => namespace.tr('.', '/'))
		return ctx
	end

	def render_skeleton(skeleton='skeleton-ml', ctx={})
		ctx = ctx.merge(:skeletondir => File.expand_path(skeleton, SCRIPTPARENT))
		start_dir = File.join(ctx[:skeletondir], '{{name}}')
		files_skel = Dir["{**/*,**/.*}", base: start_dir
			].filter{|p| File.file? File.join(start_dir, p)}
		renderouts, copyouts, pat_mustache = {}, {}, /\.mustache$/
		files_skel.each{|skelX|
			if pat_mustache.match(skelX)
				renderouts[skelX] = Mustache.render(skelX, ctx).sub(pat_mustache, '')
			else
				copyouts[skelX] = Mustache.render(skelX, ctx)
			end
			}
		puts "... processing files processing -- rendering #{renderouts.size} ; copying #{copyouts.size} ..."
	
		(renderouts.values() + copyouts.values()).uniq.each{|pathX|
			dirX = File.dirname(pathX)
			if not File.exist?(File.join(ctx[:name], dirX))
				FileUtils.mkdir_p(File.join(ctx[:name], dirX))
			end}
		renderouts.each{|srcR, dstR| File.open(File.join(ctx[:name], dstR), 'w+') {|f|
			f.write(Mustache.render(File.read(File.join(start_dir, srcR)), ctx))}}
		copyouts.each{|srcC, dstC| File.open(File.join(ctx[:name], dstC), 'w+') {|f|
			f.write(File.read(File.join(start_dir, srcC)))}}
	
		puts 'Post rendering message'
		Dir.chdir(ctx[:name])
		system('ruby choices/post_gen_project.rb') # ruby ___.rb | sh ___.sh
	end

	def parse_cmdopts(args=[])
		require 'optparse'
	
		opts_hash = {'data': 'data.yaml', 'datafmt': 'yaml', 'fileOut': STDOUT,
		  'template': 'skeleton-ml'}
		usage_str = <<EOF
Usage: #{File.basename $PROGRAM_NAME} [OPTIONS] [TEMPLATE] [KEY1=VAL1 KEYN=VALN]

Example: #{File.basename $PROGRAM_NAME} -d data.yaml LICENSE.mustache
EOF
		opts_parser = OptionParser.new {|opts|
			opts.separator nil
			opts.separator 'Specific options:'
		
			opts.on('-d DATA', '--data DATA', String, 'Data path or - (for stdin)') {
				|data| opts_hash[:data] = data}
			opts.on('-f FMT', '--datafmt FMT', ['yaml', 'json', 'toml'],
				'Specify data file format (yaml, json, toml)') {
				|datafmt| opts_hash[:datafmt] = datafmt}
			#opts.on('-t TEMPLATE', '--template TEMPLATE', String, 'Template path') {
			#	|template| opts_hash[:template] = template}
			#opts.on('-i IN', '--fileIn IN', String, 'File in - (for stdin) or path') {
			#	|fileIn| opts_hash[:fileIn] = File.open(fileIn)}
			opts.on('-o FILEOUT', '--fileOut FILEOUT', String,
			  'File out - (for stdout) or path') {
				|fileOut| opts_hash[:fileOut] = File.open(fileOut, mode = 'w+')}
		
			opts.banner = usage_str
			opts.separator nil
			opts.separator 'Common options:'
		
			opts.on_tail('-h', 'help message') {
				$stderr.print opts
				exit 0 }
		}.parse!(args) or raise
		#raise usage_str unless 0 == args.size
		opts_hash
	end

	def main(args=[])
		opts_hash, cfg = parse_cmdopts(args), {}
		
		kvset, rest = {}, []
		while extra = args.shift
			if extra.match(/\w+=\w+/)
				key1, val1 = *extra.split('=', 2)
				(kvset ||= {})[key1.to_sym] = val1
			else
			  rest += [extra]
			end
		end
		if 0 < rest.length
		  opts_hash[:template] = rest.shift
		end
		if (not File.exist?(opts_hash[:template]) and 
		    not File.exist?(File.expand_path(opts_hash[:template], SCRIPTPARENT)))
		  puts "Non-existent template: #{opts_hash[:template]}"
		  exit 1
		end
		is_dir = (File.directory?(opts_hash[:template]) or 
		  File.directory?(File.expand_path(opts_hash[:template], SCRIPTPARENT)))
	  if '-' == opts_hash[:data]
	    cfg = deserialize_str($stdin.read, opts_hash[:datafmt], 'date')
	  end
	  
	  if not is_dir
	    if not '-' == opts_hash[:data]
	      cfg = deserialize_file(opts_hash[:data], opts_hash[:datafmt], 'date')
	    end
	    cfg = cfg.merge(kvset)
			opts_hash[:fileOut].write(Mustache.render(File.read(opts_hash[:template]), cfg))
	  else
	    if not '-' == opts_hash[:data]
	      cfg = deserialize_file(File.expand_path(
				  "#{opts_hash[:template]}/#{opts_hash[:data]}", SCRIPTPARENT),
				  opts_hash[:datafmt], 'date')
	    end
			cfg = cfg.merge(kvset)
			cfg = derive_skel_vars(cfg)
			regex_checks(cfg.fetch(:parentregex, ''), cfg.fetch(:parent, ''),
				cfg.fetch(:name, ''))
			regex_checks(cfg.fetch(:projectregex, ''), cfg.fetch(:project, ''), 
			  cfg.fetch(:name, ''))
			render_skeleton(opts_hash[:template], cfg)
	  end
		0
	end
end


if __FILE__ == $PROGRAM_NAME
  exit RenderMustache.main(ARGV)
end
