VERSION=0.1.0
LOVE_VERSION=11.3
NAME=space-dwarf
ITCH_ACCOUNT=alexjgriffith
URL=https://gitlab.com/alexjgriffith/fennel-love
AUTHOR="Alexander Griffith"
DESCRIPTION="Deliver those packages steve!"


LIBS_LUA := $(wildcard lib/*)
LIBS_FNL := $(wildcard lib/*.fnl)
LUA := $(wildcard *.lua)
SRC := $(wildcard src/*.fnl)
LEVELS := $(wildcard assets/levels/*.fnl)
OUT_LEVELS := $(patsubst assets/levels/%.fnl,%.lua,$(LEVELS))
OUT := $(patsubst src/%.fnl,%.lua,$(SRC))
OUT_LIBS := $(patsubst %.fnl,%.lua,$(LIBS_FNL))

run: $(OUT) $(OUT_ENTS) $(OUT_LEVELS); love .

count: ; cloc src/*.fnl --force-lang=clojure

clean: ; rm -rf releases/* $(OUT) $(OUT_LIBS) $(OUT_LEVELS)

cleansrc: ; rm -rf $(OUT) $(OUT_LIBS) $(OUT_LEVELS)

%.lua: src/%.fnl; lua lib/fennel --compile --correlate $< > $@

lib/%.lua: lib/%.fnl; lua lib/fennel --compile --correlate $< > $@

%.lua: assets/levels/%.fnl; lua lib/fennel --compile --correlate $< > $@

LOVEFILE=releases/$(NAME)-$(VERSION).love

$(LOVEFILE): $(LUA) $(OUT) $(OUT_LIBS) $(OUT_LEVELS) $(LIBS_LUA) assets
	mkdir -p releases/
	find $^ -type f | LC_ALL=C sort | env TZ=UTC zip -r -q -9 -X $@ -@

love: $(LOVEFILE)

# platform-specific distributables

REL=$(PWD)/buildtools/love-release.sh # https://p.hagelb.org/love-release.sh
FLAGS=-a "$(AUTHOR)" --description $(DESCRIPTION) \
	--love $(LOVE_VERSION) --url $(URL) --version $(VERSION) --lovefile $(LOVEFILE)

releases/$(NAME)-$(VERSION)-x86_64.AppImage: $(LOVEFILE)
	cd buildtools/appimage && ./build.sh $(LOVE_VERSION) $(PWD)/$(LOVEFILE)
	mv buildtools/appimage/game-x86_64.AppImage $@

releases/$(NAME)-$(VERSION)-web.zip: $(LOVEFILE)
	cd releases && ../buildtools/love-js/love-js.sh $(PWD)/releases $(NAME) $(VERSION)

releases/$(NAME)-$(VERSION)-macos.zip: $(LOVEFILE)
	$(REL) $(FLAGS) -M
	mv releases/$(NAME)-macos.zip $@

releases/$(NAME)-$(VERSION)-win.zip: $(LOVEFILE)
	$(REL) $(FLAGS) -W32
	mv releases/$(NAME)-win32.zip $@

linux: releases/$(NAME)-$(VERSION)-x86_64.AppImage
mac: releases/$(NAME)-$(VERSION)-macos.zip
windows: releases/$(NAME)-$(VERSION)-win.zip
web: releases/$(NAME)-$(VERSION)-web.zip

# If you release on itch.io, you should install butler:
# https://itch.io/docs/butler/installing.html

uploadlinux: releases/$(NAME)-$(VERSION)-x86_64.AppImage
	butler push $^ $(ITCH_ACCOUNT)/$(NAME):linux --userversion $(VERSION)
uploadmac: releases/$(NAME)-$(VERSION)-macos.zip
	butler push $^ $(ITCH_ACCOUNT)/$(NAME):mac --userversion $(VERSION)
uploadwindows: releases/$(NAME)-$(VERSION)-win.zip
	butler push $^ $(ITCH_ACCOUNT)/$(NAME):windows --userversion $(VERSION)
uploadlove: releases/$(NAME)-$(VERSION).love
	butler push $^ $(ITCH_ACCOUNT)/$(NAME):love --userversion $(VERSION)
uploadweb: releases/$(NAME)-$(VERSION)-web.zip
	butler push $^ $(ITCH_ACCOUNT)/$(NAME):web --userversion $(VERSION)

upload: uploadlinux uploadwindows uploadmac uploadlove uploadweb

release: linux windows mac web upload cleansrc
