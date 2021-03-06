build/gz_2010_us_050_00_20m.zip:
	mkdir -p $(dir $@)
	curl -o $@ http://www2.census.gov/geo/tiger/GENZ2010/$(notdir $@)

build/gz_2010_us_050_00_20m.shp: build/gz_2010_us_050_00_20m.zip
	unzip -od $(dir $@) $<
	touch $@

# build/counties.json: build/gz_2010_us_050_00_20m.shp
# 	node_modules/.bin/topojson \
# 		-o $@ \
# 		--projection='width = 960, height = 600, d3.geo.albersUsa() \
# 			.scale(1280) \
# 			.translate([width / 2, height / 2])' \
# 		--simplify=.5 \
# 		-- counties=$<


	# topojson \
	# -o build/counties.json \
	# -e shootings.csv \
	# --id-property STATE+COUNTY,+id \
	# -p \
	# -p name=cty \
	# -p victims=+victims \
	# -s .5 \
	# -- build/gz_2010_us_050_00_20m.shp

	# topojson \
	# -o build/states.json \
	# -e build/counties.json



build/counties.json: build/gz_2010_us_050_00_20m.shp shootings_year.csv
	node_modules/.bin/topojson \
		-o $@ \
		--id-property STATE+COUNTY,+id \
		--external-properties=shootings_year.csv \
		--p name=cty \
		--p year=+year \
		--p victims=+victims \
		--projection='width = 960, height = 600, d3.geo.albersUsa() \
			.scale(1280) \
			.translate([width / 2, height / 2])' \
		--simplify=.5 \
		-- counties=$<

# build/states.json: build/counties.json
# 	node_modules/.bin/topojson-merge \
# 		-o $@ \
# 		--in-object=counties \
# 		--out-object=states \
# 		--key='d.id.substring(0, 2)' \
# 		-- $<

build/states.json: build/counties.json
	node_modules/.bin/topojson-merge \
		-o $@ \
		--in-object=counties \
		--out-object=states \
		--key='d.id.substring(0, 2)' \
		-- $<

us.json: build/states.json
	node_modules/.bin/topojson-merge \
		-o $@ \
		--in-object=states \
		--out-object=nation \
		-- $<