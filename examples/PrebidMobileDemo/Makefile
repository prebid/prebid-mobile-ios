all:
	$(MAKE) ipa

clean:
	rm -rf build
	rm -rf Products

  # Legacy
	#rm -rf CalSmoke*.ipa
	#rm -rf CalSmoke*.app.dSYM
	#rm -rf CalSmoke*.app
	#rm -rf xtc-staging

# Builds an ipa with no Calabash server.
ipa:
	bin/make/ipa.sh

# Builds an app with no Calabash server.
#app:
	#bin/make/app.sh

# Run the XCTest (unit) tests
#xct:
	#bundle exec bin/make/xctest.rb