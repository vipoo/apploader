

apploader: apploader.js loader.asm
	@cat apploader.js | ./node_modules/.bin/nexe -t 12.15.0 -r loader.asm --verbose -o apploader
	@gzexe apploader
	@rm -f apploader~
	@chmod +x ./apploader
