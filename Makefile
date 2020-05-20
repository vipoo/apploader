

apploader: apploader.js
	@cat apploader.js | ./node_modules/.bin/nexe -t 12.15.0 -r loader.asm --verbose -o apploader
	@gzexe apploader
	@rm -f apploader~
