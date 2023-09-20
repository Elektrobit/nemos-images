# SPDX-License-Identifier: GPL-2.0-or-later

SERIES = \
	lunar \
	mantic

CONFIGURATIONS = \
	minimal \
	reference

PLATFORMS = \
	qemu-amd64 \
	qemu-arm64 \
	s32g274ardb2

TARGETS = \
	$(foreach platform,$(PLATFORMS), \
		$(addsuffix -$(platform), \
			$(foreach series,$(SERIES), \
				$(addsuffix -$(series), \
					$(addprefix nemos-images-,$(CONFIGURATIONS)) \
				) \
			) \
		) \
	)

.PHONY: all
all: $(TARGETS)

.PHONY: $(TARGETS)
$(TARGETS):
	@CONFIG="$$(echo $(@) | cut -f 3 -d-)"; \
	SERIES="$$(echo $(@) | cut -f 4 -d-)"; \
	PLATFORM="$$(echo $(@) | cut -f 5- -d-)"; \
		echo "Generating $${SERIES}/$${CONFIG}/$${PLATFORM}"; \
		keg -v --disable-multibuild -f -r . -d \
			"nemos-images-$${CONFIG}-$${SERIES}/$${PLATFORM}" \
			"$${SERIES}/$${CONFIG}/$${PLATFORM}"; \
		mv nemos-images-$${CONFIG}-$${SERIES}/$${PLATFORM}/config.kiwi \
			nemos-images-$${CONFIG}-$${SERIES}/$${PLATFORM}/appliance.kiwi
